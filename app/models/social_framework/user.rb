module SocialFramework

  # User class based in devise, represents the user entity to authenticate in system
  class User < ActiveRecord::Base
    include UserHelper

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

    # Follow someone user
    # ====== Params:
    # +user+:: +User+ to follow
    # +active+:: +Boolean+ define relationship like active or inactive
    # +bidirectional+:: +Boolean+ define relationship is bidirectional or not
    # Returns Relationship type or a new edge relationship
    def follow(user, active=true, bidirectional=false)
      UserHelper.create_relationship(self, user, "following", active, bidirectional)
    end

    # Unfollow someone user
    # ====== Params:
    # +user+:: +User+ to unfollow
    # Returns Edge of relationship between the users
    def unfollow(user)
      UserHelper.delete_relationship(self, user, "following")
    end

    # Add someone user as a friend
    # ====== Params:
    # +user+:: +User+ to add as a friend
    # +active+:: +Boolean+ define relationship like active or inactive
    # +bidirectional+:: +Boolean+ define relationship is bidirectional or not
    # Returns Relationship types between the users
    def add_friend(user, active=false, bidirectional=true)
      UserHelper.create_relationship(self, user, "friend", active, bidirectional)
    end

    # Confirm frindshipe
    # ====== Params:
    # +user+:: +User+ to add as a friend
    # Returns Relationship types between the users
    def confirm_friendship(user)
      return if user.nil? or user == self

      relationship = Relationship.find_by label: "friend"
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
