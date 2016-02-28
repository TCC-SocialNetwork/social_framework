module SocialFramework

  # User class based in devise, represents the user entity to authenticate in system
  class User < ActiveRecord::Base
    include UserHelper

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
    # +active+:: +Boolean+ define relationship like active or inactive
    # Returns Relationship type or a new edge relationship
    def follow(user, active=true)
      UserHelper.create_relationship(self, user, "following", active)
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
    # Returns Relationship types between the users
    def add_friend(user, active=false)
      UserHelper.create_relationship(self, user, "friend", active)
      UserHelper.create_relationship(user, self, "friend", active)
    end

    # Confirm frindshipe
    # ====== Params:
    # +user+:: +User+ to add as a friend
    # Returns Relationship types between the users
    def confirm_friendship(user)
      return if user.nil? or user == self

      relationship = Relationship.find_by label: "friend"
      edge_origin = self.edges.select { |edge| edge.destiny == user }.first
      edge_destiny = user.edges.select { |edge| edge.destiny == self }.first

      unless edge_origin.nil? or edge_destiny.nil? or relationship.nil?
        edge_relationship_origin = edge_origin.edge_relationships.select { |edge_relationship|
            edge_relationship.relationship == relationship }.first
        edge_relationship_destiny = edge_destiny.edge_relationships.select { |edge_relationship|
            edge_relationship.relationship == relationship }.first

        edge_relationship_origin.active = true
        edge_relationship_origin.save
        
        edge_relationship_destiny.active = true
        edge_relationship_destiny.save
      end
    end    
  end
end
