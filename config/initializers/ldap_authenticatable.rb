require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        if params[:user]
          ldap = Net::LDAP.new
          ldap.host = "10.220.1.40"
          ldap.port = 389
          domain = "ou=users,dc=kannan,dc=com"
          dn = "cn=#{params[:user][:username]},#{domain}"
          ldap.auth dn, params[:user][:password]

          if ldap.bind
            user = User.new(:username => username, :password => password, :password_confirmation => password) rescue User.find_by_username(username)
            user.save!(validate: false)
            user.roles << Role.find(1)
            user.save!(validate: false)
            # user = User.find_or_create_by_username(user_data)
            success!(user)
          else
            fail(:invalid_login)
          end
        end
      end

      def email
        params[:user][:email]
      end

      def username
        params[:user][:username]
      end

      def password
        params[:user][:password]
      end

      def user_data
        {:username => username, :password => password, :password_confirmation => password}
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
