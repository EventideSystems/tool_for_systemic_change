class RenameAdministratingOrganisations < ActiveRecord::Migration

  class Client < ActiveRecord::Base; end

  class Organisation < ActiveRecord::Base
    self.inheritance_column = 'dummy'
    self.table_name = 'organisations'
  end

  class Community < ActiveRecord::Base; end

  class User < ActiveRecord::Base; end

  class WickedProblem < ActiveRecord::Base; end

  CLASSES_TO_MODIFY = [Organisation, Community, User, WickedProblem]

  def up
    create_table :clients do |t|
      t.string :name
      t.string :description
      t.string :weblink
      t.references :sector
      t.timestamps null: false
    end

    # Create new clients and map existing client_ids over
    old_admin_organisations = Organisation.where(type: 'Client').all
    old_admin_organisations.each do |admin_org|

      new_client = Client.create!(
        name:         admin_org.name,
        description:  admin_org.description,
        sector_id:    admin_org.sector_id,
        weblink:      admin_org.weblink
      )

      CLASSES_TO_MODIFY.each do |klass|
        klass.where(client_id: admin_org.id)
          .update_all(client_id: new_client.id)

        rename_column klass.table_name.to_sym, :client_id, :client_id
      end
    end

    Organisation.delete_all(type: 'Client')

    # Remove old type field
    remove_column :organisations, :type
  end

  def down
    add_column :organisations, :type, :string

    old_clients = Client.all

    old_clients.each do |client|
      new_admin_org = Organisation.create!(
        name:         client.name,
        description:  client.description,
        sector_id:    client.sector_id,
        weblink:      client.weblink,
        type:         'Client'
      )

      CLASSES_TO_MODIFY.each do |klass|
        klass.where(client_id: client.id)
          .update_all(client_id: new_admin_org.id)

        rename_column klass.table_name.to_sym, :client_id, :client_id
      end
    end

    drop_table :clients
  end
end
