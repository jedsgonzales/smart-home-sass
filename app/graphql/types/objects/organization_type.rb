module Types::Objects
  class OrganizationType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :short_name, String, null: true
    field :details, String, null: true
    field :site_url, String, null: true
    field :address, String, null: true
    field :contact_details, String, null: true
    field :private_info, Boolean, null: false
    field :public_list, Boolean, null: false
  end
end
