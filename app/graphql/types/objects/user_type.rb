module Types::Objects
  class UserType < Types::BaseObject
    description "User Type"

    field       :id, ID, null: false
    field       :full_name, String, null: false
    field       :nick_name, String, null: true
    field       :email, String, null: true

    def full_name
      "#{object.title_name} #{object.first_name} #{object.middle_name} #{object.last_name}".strip
    end
  end
end
