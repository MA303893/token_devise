# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
u=User.new(:username => "admin", :firstname => "Admin", :email => "admin@wipro.com", :password => "D1g1taLHu6", :password_confirmation => "D1g1taLHu6") rescue User.find_by_username('admin')
u.save!(validate: false)
u.save(validate: false)