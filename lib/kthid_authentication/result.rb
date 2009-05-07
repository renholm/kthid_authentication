module KthidAuthentication
  class Result
    ERROR_MESSAGES = {
      :invalid_ticket => "Sorry, could not validate your authentication ticket. Ticket is invalid.",
      :account_not_found => "Sorry, your account could not be found in the LDAP-server. This should never happen.",
    }

    ERROR_MESSAGES.keys.each do |state| 
      define_method("#{state}?") { @code == state }
    end

    def initialize(code)
      @code = code
    end

    def status
      @code
    end

    def successful?
      @code == :successful
    end

    def unsuccessful?
      ERROR_MESSAGES.keys.include?(@code)
    end

    def message
      ERROR_MESSAGES[@code]
    end
  end
end