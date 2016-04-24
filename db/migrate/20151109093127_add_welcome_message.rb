class AddWelcomeMessage < ActiveRecord::Migration

  class Client < ActiveRecord::Base; end
  
  def up
    add_column :clients, :welcome_message, :text

    Client.all.each do |client|
      client.welcome_message = <<-MESSAGE
Lorem ipsum dolor sit amet, consectetur adipisicing elit.

Obcaecati quisquam, dicta recusandae pariatur reprehenderit, possimus rem ipsam mollitia qui ipsum at atque provident facilis odio architecto quae quas perspiciatis ratione.
MESSAGE

      client.save!
    end
  end

  def down
    remove_column :clients, :welcome_message
  end
end
