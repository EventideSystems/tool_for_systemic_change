# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or create!d alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create!([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create!(name: 'Emanuel', city: cities.first)


User.delete_all

staff_user = User.new(
  email: 'staff@example.com', password: 'password',
  name: 'John Staff',
  password_confirmation: 'password', role: "staff"
)
staff_user.save!

Client.delete_all
Organisation.delete_all

client = Client.create!(name: 'Example Admin Organisation')

Organisation.create!(name: "First Example Organisation", administrating_organisation: client)
Organisation.create!(name: "Second Example Organisation", administrating_organisation: client)

admin_user = User.new(
  email: 'admin@example.com', password: 'password',
  name: 'John Admin',
  password_confirmation: 'password', role: "admin",
  client_id: client.id
)
admin_user.save!

user = User.new(
  email: 'user@example.com', password: 'password',
  name: 'John User',
  password_confirmation: 'password', role: "user",
  client_id: client.id
)
user.save!


Sector.delete_all

Sector.create!(name: 'Local government')
Sector.create!(name: 'State government')
Sector.create!(name: 'Federal government')
Sector.create!(name: 'Education')
Sector.create!(name: 'NGO')

# Problem.delete_all
#
# Problem.create!(name: "Climate change")
# Problem.create!(name: "Obesity")
# Problem.create!(name: "Indigenous disadvantage")

load "#{Rails.root}/db/model_seeds.rb"
