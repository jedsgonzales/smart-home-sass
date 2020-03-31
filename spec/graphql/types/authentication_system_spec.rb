require "rails_helper"
require "faker"

RSpec.describe Types::MutationType do
  describe "authentication system" do
    let!(:users) { create_pair(:user) }

    context "when logging in with correct identification" do
      let(:login) do
        %(mutation {
          authUser( email: "#{users.first.email}", password: "#{users.first.password}" ) {
            authResult {
              client
              token
              expiry
            }
            uid
          }
        })
      end

      subject(:result) do
        GraphqlAppSchema.execute(login).as_json
      end

      it "should return token string" do

        # pre-parse response
        token_hash = result.dig("data", "authUser", "authResult", "token")
        client_id = result.dig("data", "authUser", "authResult", "client")

        first_user = User.first
        expect( BCrypt::Password.new( first_user.tokens[client_id]['token'] ).is_password?(token_hash) ).to be true
      end

      it "should return expiry greater than current date" do
        # pre-parse response
        expiry = result.dig("data", "authUser", "authResult", "expiry")

        expect( expiry.to_i - Time.now.to_i ).to be > 10.days.to_i
      end
    end

    context "when logging with incorrect identification" do
      let(:login) do
        %(mutation {
          authUser( email: "#{users.first.email}", password: "#{Faker::String.random}") {

          }
        })
      end

      subject(:result) do
        GraphqlAppSchema.execute(login).as_json
      end

      it "should return failure" do
        expect(result.dig("errors").size).to be > 0
      end

    end
  end
end
