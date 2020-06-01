class NetworksController < ApplicationController

  skip_after_action :verify_policy_scoped
  
  add_breadcrumb "Networks", :networks_path

  def index
    @nodes = load_nodes
    @links = load_links
  end

  private

  def load_nodes
    current_account.organisations.all.map do |org|
      { id: org.id, group: 0, label: org.name.truncate(20), level: 1 }
    end.to_json
  end

  def load_links
    query = <<~SQL
      select org1.id, org2.id from initiatives
      inner join scorecards on scorecards.id = initiatives.scorecard_id
      inner join initiatives_organisations io1 on io1.initiative_id = initiatives.id
      inner join organisations org1 on org1.id = io1.organisation_id
      inner join initiatives_organisations io2 on io2.initiative_id = initiatives.id
      inner join organisations org2 on org2.id = io2.organisation_id
      where org1.id <> org2.id and scorecards.account_id = #{current_account.id};
    SQL

    results = ActiveRecord::Base.connection.exec_query(query).rows

    results = results + results.map{|r| [r[1], r[0]]}

    results.uniq.map do |row|
      { target: row[0], source: row[1], strength: 0.7 }
    end.to_json
  end
end