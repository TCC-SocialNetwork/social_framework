module SocialFramework

  # User class based in devise, represents the user entity to authenticate in system
  class User < ActiveRecord::Base
    # Username or email to search
    attr_accessor :login

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    # Get all related edges with origin or destiny equal self
    # Returns Related edges with self
    def edges
      Edge.where(["origin_id = :id OR destiny_id = :id", { id: id }])
    end

    # Get login if not blank, username or email
    # Used to autenticate in system
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
    # +active+:: +Boolean+ define relationship like active or inactive
    # +bidirectional+:: +Boolean+ define relationship is bidirectional or not
    # Returns Relationship type or a new edge relationship
    def create_relationship(destiny, label, active=false, bidirectional=true)
      return if destiny.nil? or destiny == self
      
      edge = Edge.where(["origin_id = :origin_id AND destiny_id = :destiny_id OR 
        destiny_id = :origin_id AND origin_id = :destiny_id",
        { origin_id: self.id, destiny_id: destiny.id }]).first

      edge = Edge.create origin: self, destiny: destiny, bidirectional: bidirectional if edge.nil?

      relationship = Relationship.find_or_create_by(label: label)
      unless edge.relationships.include? relationship
        EdgeRelationship.create(edge: edge, relationship: relationship, active: active)
      end
    end

    # Remove relationship beteween users
    # ====== Params:
    # +destiny+:: +User+ relationship destiny
    # +label+:: +String+ relationship type
    # Returns Edge of relationship between the users
    def remove_relationship(destiny, label)
      return if destiny.nil? or destiny == self

      edge = Edge.where(["origin_id = :origin_id AND destiny_id = :destiny_id OR 
        destiny_id = :origin_id AND origin_id = :destiny_id",
        { origin_id: self.id, destiny_id: destiny.id }]).first

      unless edge.nil?
        edge.relationships.each { |r| edge.relationships.destroy(r.id) if r.label == label }
        self.edges.destroy(edge.id) if edge.relationships.empty?
      end
    end

    # Confirm relationship
    # ====== Params:
    # +user+:: +User+ to confirm
    # +label+:: +Label+ to confirm
    # Returns Relationship types between the users
    def confirm_relationship(user, label)
      return if user.nil? or user == self

      relationship = Relationship.find_by label: label
      edge = self.edges.select { |edge| edge.origin == user }.first

      unless edge.nil? or relationship.nil?
        edge_relationship = edge.edge_relationships.select { |edge_relationship|
            edge_relationship.relationship == relationship }.first

        edge_relationship.active = true
        edge_relationship.save
      end
    end
  end
end
