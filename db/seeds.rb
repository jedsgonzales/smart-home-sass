# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(
  name: 'Administrator',
  first_name: 'Vecom',
  last_name: 'Soln',
  nick_name: 'Admin',
  email: 'tech@v-ecom.com',
  password: 'ap0theos1s'
)
