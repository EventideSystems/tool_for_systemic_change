class AddProfilePictureToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :profile_picture, :string
  end
end
