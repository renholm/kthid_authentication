config.gem "ruby-net-ldap", :lib => "net/ldap"
config.to_prepare do
  ActionController::Base.send :include, KthidAuthentication
end