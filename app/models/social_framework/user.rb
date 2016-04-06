module SocialFramework

  # User class based in devise, represents the user entity to authenticate in system
  class User < ActiveRecord::Base

    has_one :schedule

    # Username or email to search
    attr_accessor :login

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    # Get all related edges with origin or destiny equal self
    # Returns Related edges with self
    def edges
      Edge.where(["(origin_id = :id AND bidirectional = :not_bidirectional) OR
        (bidirectional = :bidirectional AND (origin_id = :id OR destiny_id = :id))",
        { id: id, bidirectional: true, not_bidirectional: false }])
    end

    # Get login if not blank, username or email
    # Used to autenticate in system
    # Returns login, username or email
    def login
      if not @login.nil? and not @login.blank?
        @login
      elsif not self.username.nil? and not self.username.empty?
        self.username
      else
        self.email
      end
    end

    # In authentication get user with key passed.
    # ====== Params:
    # +warden_conditions+:: +Hash+ with login, email or username to authenticate user, if login search users by username or email
    # Returns User in case user found or nil if not
    def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
     
      if login = conditions.delete(:login)
        where(conditions.to_h).where(["username = :value OR email = :value", { :value => login }]).first
      elsif conditions.has_key?(:username) || conditions.has_key?(:email)
        where(conditions.to_h).first
      end
    end

    # Create relationship beteween users
    # ====== Params:
    # +destiny+:: +User+ relationship destiny
    # +label+:: +String+ relationship type
    # +bidirectional+:: +Boolean+ define relationship is bidirectional or not
    # +active+:: +Boolean+ define relationship like active or inactive
    # Returns true if relationship created or false if no
    def create_relationship(destiny, label, bidirectional=true, active=false)
      return false if destiny.nil? or destiny == self
      
      edge = Edge.where(["(origin_id = :origin_id AND destiny_id = :destiny_id OR 
        destiny_id = :origin_id AND origin_id = :destiny_id) AND label = :label",
        { origin_id: self.id, destiny_id: destiny.id, label: label }]).first

      if edge.nil?
        edge = Edge.create origin: self, destiny: destiny, active: active,
          bidirectional: bidirectional, label: label

        return (not edge.nil?)
      end

      return false
    end

    # Remove relationship beteween users
    # ====== Params:
    # +destiny+:: +User+ relationship destiny
    # +label+:: +String+ relationship type
    # Returns Edge destroyed between the users
    def remove_relationship(destiny, label)
      return if destiny.nil? or destiny == self

      edge = Edge.where(["(origin_id = :origin_id AND destiny_id = :destiny_id OR 
        destiny_id = :origin_id AND origin_id = :destiny_id) AND label = :label",
        { origin_id: self.id, destiny_id: destiny.id, label: label }]).first

      self.edges.destroy(edge.id) unless edge.nil?
    end

    # Confirm relationship
    # ====== Params:
    # +user+:: +User+ to confirm
    # +label+:: +String+ to confirm
    # Returns true if relationship confirmed or false if no
    def confirm_relationship(user, label)
      return false if user.nil? or user == self

      edge = self.edges.select { |edge| edge.origin == user and edge.label == label }.first

      unless edge.nil? 
        edge.active = true
        return edge.save
      end

      return false
    end

    # Get all users with specific relationship
    # ====== Params:
    # +label+:: +String+ to search
    # +status:: +Boolean+ to get active or inactive edges
    # +created_by:: +String+ represent type relationships created by self or not. Pass self, any or other 
    # Returns Array with users found
    def relationships(label, status = true, created_by = "any")
      edges = self.edges.select do |edge|
        creation_condiction = true

        if created_by == "self"
          creation_condiction = edge.origin == self
        elsif created_by == "other"
          creation_condiction = edge.destiny == self
        end
        
        edge.label == label and edge.active == status and creation_condiction
      end

      users = Array.new

      edges.each do |edge|
        users << (edge.origin != self ? edge.origin : edge.destiny)
      end

      return users
    end

    # Get my intance graph
    # Returns Graph instance
    def graph
      graph = NetworkHelper::Graph.get_instance(id)

      if graph.network.empty?
        graph.build(self)
      end

      return graph
    end

    # Create user schedule if not exists
    # Return user schedule
    def schedule
      Schedule.find_or_create_by(user: self)
    end
  end
end
