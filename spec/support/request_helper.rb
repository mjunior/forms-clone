module Request
  module JsonHelpers
    def expect_status(expectation_status)
      expect(response.status).to eql(expectation_status)
    end

    def json
      JSON.parse(response.body, symbolize_names: true)
    end
  end

  #
  module HeaderHelpers
    def header_with_authentication(user)
      user.create_new_auth_token.merge({'HTTP_ACCEPT': 'application/json'})
    end

    def header_without_authentication
      { 'content-type' => 'application/json' }
    end
  end
end