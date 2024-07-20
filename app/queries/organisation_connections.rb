# frozen_string_literal: true

# Count the number of connections between organisations in a scorecard
class OrganisationConnections
  # Returns a hash of organisation_id => count of connections
  def self.execute(scorecard_id)
    ActiveRecord::Base.connection.execute(connection_sql(scorecard_id)).each_with_object({}) do |result, memo|
      memo[result['organisation_id']] = result['count']
    end
  end

  def self.connection_sql(scorecard_id)
    <<~SQL
      select
        io1.organisation_id,
        count(distinct io2.organisation_id)
      from initiatives_organisations io1
      join initiatives i on i.id = io1.initiative_id
      join initiatives_organisations io2
        on io2.initiative_id = io1.initiative_id
        and io2.organisation_id <> io1.organisation_id
      where i.scorecard_id = #{scorecard_id}
      group by io1.organisation_id
    SQL
  end
end
