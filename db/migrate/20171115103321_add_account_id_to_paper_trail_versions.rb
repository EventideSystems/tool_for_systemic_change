class AddAccountIdToPaperTrailVersions < ActiveRecord::Migration[5.0]
  
  class Version < ApplicationRecord; end;
    
  def up
    add_column :versions, :account_id, :integer
    add_index :versions, :account_id
    
    
    %w(Community Organisation WickedProblem Scorecard).each do |type|
      Version.where(item_type: type).each do |version|
        item = type.constantize.unscoped.where(id: version.item_id).first
        version.update_attribute(:account_id, item.account_id) if item
      end
    end
    
    %w(Initiative).each do |type|
      Version.where(item_type: type).each do |version|
        item = type.constantize.unscoped.where(id: version.item_id).first
        version.update_attribute(:account_id, item.scorecard.account_id) if item && item.scorecard
      end
    end
    
    %w(InitiativesOrganisation).each do |type|
      Version.where(item_type: type).each do |version|
        item = type.constantize.unscoped.where(id: version.item_id).first
        version.update_attribute(:account_id, item.initiative.scorecard.account_id) if item && item.initiative && item.initiative.scorecard
      end
    end
  end
  
  def down
    remove_index :versions, :account_id
    remove_column :versions, :account_id
  end
end
