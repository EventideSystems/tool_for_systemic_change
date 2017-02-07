# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


User.delete_all

staff_user = User.new(
  email: 'staff@example.com', password: 'password',
  name: 'John Staff',
  password_confirmation: 'password'
)
staff_user.save!

admin_user = User.new(
  email: 'admin@example.com', password: 'password',
  name: 'John Admin',
  password_confirmation: 'password'
)
admin_user.save!

user = User.new(
  email: 'user@example.com', password: 'password',
  name: 'John User',
  password_confirmation: 'password'
)
user.save!
