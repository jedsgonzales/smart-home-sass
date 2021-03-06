module Types::Objects
  class AuthResultType < Types::BaseObject
    description "User Auth Result"

    field       :client, String, null: false
    field       :token, String, null: false
    field       :expiry, String, null: false
  end
end
