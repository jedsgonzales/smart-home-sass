require "rails_helper"

RSpec.describe "List Users", :type => :request do
  before(:all) do
    @users = create_pair(:user)
    @auth_result = GraphqlAppSchema.execute( login(email: @users.first.email, password: @users.first.password) ).as_json
  end

  context "user listing" do
    it "gives out the list with proper headers" do
      token_hash = @auth_result.dig("data", "authUser", "authResult", "token")
      client_id = @auth_result.dig("data", "authUser", "authResult", "client")
      expiry = @auth_result.dig("data", "authUser", "authResult", "expiry")
      uid = @auth_result.dig("data", "authUser", "uid")

      headers = {
        "ACCEPT" => "application/json",     # This is what Rails 4 accepts
        "HTTP_ACCEPT" => "application/json", # This is what Rails 3 accepts
        "client" => client_id,
        "access-token" => token_hash,
        "expiry" => expiry,
        "uid" => uid
      }

      post "/graphql", params: { query: list_users_query }, headers: headers
      json = JSON.parse(response.body)

      expect(json.dig("data", "listUsers").size).to eq(2)
    end
  end

  def login(email:, password:)
    <<~GQL
    mutation {
      authUser( email: "#{email}", password: "#{password}" ) {
        authResult {
          client
          token
          expiry
        }
        uid
      }
    }
    GQL
  end

  def list_users_query
    <<~GQL
      query {
        listUsers () {
          id
          fullName
          nickName
        }
      }
    GQL
  end

end
