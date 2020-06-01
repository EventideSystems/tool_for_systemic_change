class NetworksController < ApplicationController

  skip_after_action :verify_policy_scoped
  
  add_breadcrumb "Networks", :networks_path

  def index
    link_data = load_link_data
    @nodes = load_nodes(link_data)
    @links = load_links(link_data)
  end

  private

  def load_nodes(link_data)
    level = 0
    current_account.organisations.where(id: link_data.flatten.uniq).map do |org|
      level += 1
      level = 0 if level > 1 
      { id: org.id, group: 0, label: org.name.truncate(20), level: level }
    end.to_json
  end

  def load_links(link_data)
    link_data.map do |row|
      { target: row[0], source: row[1], strength: 0.1 }
    end.to_json
  end

  def load_link_data
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

    (results + results.map{ |r| [r[1], r[0]] }).uniq
  end

end