module SocialFramework

  # User class based in devise, represents the user entity to authenticate in system
  class User < ActiveRecord::Base
    has_many :edges, class_name: "SocialFramework::Edge", foreign_key: "origin_id"

    # Username or email to search
    attr_accessor :login

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

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

    # Follow someone user
    # ====== Params:
    # +user+:: +User+ to follow
    # Returns Relationship types between the users
    def follow(user)
      return if user.nil? or user == self
      
      edge = Edge.create(origin: self, destiny: user)
      relationship = Relationship.find_or_create_by(label: "following")
      edge.relationships << relationship
    end

    # Unfollow someone user
    # ====== Params:
    # +user+:: +User+ to unfollow
    # Returns Relationship types between the users
    def unfollow(user)
      return if user.nil? or user == self

      edge = Edge.find_by destiny: user
      unless edge.nil?
        edge.relationships.each { |r| edge.relationships.destroy(r) if r.label == "following" }
        self.edges.destroy(edge) if edge.relationships.empty?
      end
    end
  end
end
