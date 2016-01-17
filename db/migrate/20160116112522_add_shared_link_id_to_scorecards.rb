class AddSharedLinkIdToScorecards < ActiveRecord::Migration

  class Scorecard < ActiveRecord::Base; end

  def up
    add_column :scorecards, :shared_link_id, :string

    Scorecard.all.each do |scorecard|
      scorecard.update!(shared_link_id: SecureRandom.uuid)
    end
  end

  def down
    remove_column :scorecards, :shared_link_id
  end
end
