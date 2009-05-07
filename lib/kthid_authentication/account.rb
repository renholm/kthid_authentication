module KthidAuthentication
  class Account
    attr_accessor :identifier, :first_name, :last_name, :emails, :username

    def inspect
      "#<#{self.class} identifier: #{identifier}, first_name: #{first_name}, last_name: #{last_name}, emails: #{emails}, username: #{username}>"
    end
  end
end