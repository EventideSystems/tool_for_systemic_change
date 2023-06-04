# frozen_string_literal: true

class TotalTransitionCardInitiatives
  class << self
    def execute(transition_card_id, date_from, date_to)
      fetch_initiative_totals(transition_card_id, date_from, date_to)
    end

    private

    INITIATIVE_TOTALS_SQL = <<~SQL
      select
        count(initiatives.id) filter(
          where created_at < $1 and (deleted_at is null or deleted_at > $1)
        ) as initial,
        count(initiatives.id) filter(
          where created_at between $1 and $2
        ) as additions,
        count(initiatives.id) filter(
          where deleted_at between $1 and $2
        ) as removals
      from initiatives
      where scorecard_id=$3
      and (initiatives.archived_on > $1 or initiatives.archived_on is null)
    SQL

    def bind_vars(transition_card_id, date_from, date_to)
      [
        ActiveRecord::Relation::QueryAttribute.new('date_from', date_from, ActiveRecord::Type::DateTime.new),
        ActiveRecord::Relation::QueryAttribute.new('date_to', date_to, ActiveRecord::Type::DateTime.new),
        ActiveRecord::Relation::QueryAttribute.new('transition_card_id', transition_card_id,
                                                   ActiveRecord::Type::Integer.new)
      ]
    end

    def fetch_initiative_totals(transition_card_id, date_from, date_to)
      ApplicationRecord.connection.exec_query(
        INITIATIVE_TOTALS_SQL,
        '-- INITIATIVE TOTALS --',
        bind_vars(transition_card_id, date_from, date_to),
        prepare: true
      ).first.then do |totals|
        totals.symbolize_keys!
        totals[:final] = totals[:initial] + totals[:additions] - totals[:removals]
        totals
      end
    end
  end
end
