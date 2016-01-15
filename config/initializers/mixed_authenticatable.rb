require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class MixedAuthenticatable < Authenticatable
      def authenticate!
        authenticator.authenticate!
      end

      private

      def authenticator
        authenticator_factory.new(@env, @scope)
      end

      def authenticator_factory
        if user_requires_ldap_authentication
          LdapAuthenticatable
        else
          DatabaseAuthenticatable
        end
      end

      def user_requires_ldap_authentication
      	user = User.find_by_username(username)
        if user
          user.requires_ldap?
        else
          true
        end
      end

      def username
        params[:user][:username]
      end
    end
  end
end

Warden::Strategies.add(:mixed_authenticatable, Devise::Strategies::MixedAuthenticatable)
