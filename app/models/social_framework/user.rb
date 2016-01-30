module SocialFramework
  class User < ActiveRecord::Base
    attr_accessor :login

    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable

    def login=(login)
      @login = login
    end

    def login
      @login || self.username || self.email
    end

    def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
     
      if login = conditions.delete(:login)
        where(conditions.to_h).where(["username = :value OR email = :value", { :value => login }]).first
      elsif conditions.has_key?(:username) || conditions.has_key?(:email)
        where(conditions.to_h).first
      end
    end
  end
end
