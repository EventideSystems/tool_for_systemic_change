class AddContactDetailsToInitiative < ActiveRecord::Migration
  def change
    add_column :initiatives, :contact_name, :string
    add_column :initiatives, :contact_email, :string
    add_column :initiatives, :contact_phone, :string
    add_column :initiatives, :contact_website, :string
    add_column :initiatives, :contact_position, :string
  end
end
