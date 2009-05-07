require File.dirname(__FILE__) + '/kthid_authentication/result'
require File.dirname(__FILE__) + '/kthid_authentication/account'

module KthidAuthentication
  protected
    def authenticate_with_kthid(options = {}, &block)
      options[:login_hostname] ||= 'login.kth.se'
      options[:ldap_hostname] ||= 'ldap.sys.kth.se'
      options[:ldap_basedn] ||= 'ou=Addressbook,dc=kth,dc=se'

      if (ticket = params[:ticket]).nil?
        begin_kthid_authentication(options)
      else
        complete_kthid_authentication(ticket, options, &block)
      end
    end
    
  private
    def begin_kthid_authentication(options)
      hostname = options.delete(:login_hostname)
      service = options.delete(:service)

      redirect_to("https://#{hostname}/login?service=#{service}")
    end

    def complete_kthid_authentication(ticket, options)
      if (identifier = validate_ticket(ticket, options)).nil?
        yield Result.new(:invalid_ticket)
      elsif (account = lookup_account(identifier, options)).nil?
        yield Result.new(:account_not_found)
      else
        yield Result.new(:successful), account
      end
    end
    
    def validate_ticket(ticket, options)
      hostname = options.delete(:login_hostname)
      service = options.delete(:service)
      result = nil
      
      https = Net::HTTP.new(hostname, 443)
      https.use_ssl = true
      https.start { |w| result = w.get("/validate?service=#{service}&ticket=#{ticket}") }
      
      result.body =~ /yes\n(\w{8})/ ? $1 : nil
    end

    def lookup_account(identifier, options)
      hostname = options.delete(:ldap_hostname)
      basedn = options.delete(:ldap_basedn)

      filter = Net::LDAP::Filter.eq('ugKthid', identifier)

      ldap = Net::LDAP.new(:host => hostname, :base => basedn)
      ldap.search(:filter => filter) do |entry|
        user = Account.new
        user.identifier = identifier
        user.first_name = entry.givenname.first
        user.last_name = entry.sn.first
        user.username = entry.ugusername.first
        user.emails = entry.mail.first

        return user
      end

      return nil
    end
end