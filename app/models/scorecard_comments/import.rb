# frozen_string_literal: true

# == Schema Information
#
# Table name: imports
#
#  id           :integer          not null, primary key
#  import_data  :text
#  status       :integer          default("pending")
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :integer
#  workspace_id :integer
#
# Indexes
#
#  index_imports_on_user_id       (user_id)
#  index_imports_on_workspace_id  (workspace_id)
#
module ScorecardComments
  # Import class for importing comments for checklist items
  #
  # NOTE: This, like other imports, is a bit of a mess. We should refactor this to be more modular and easier to read.
  # We can probably look at moving the logic into an ETL class or something similar.
  class Import < Import # rubocop:disable Metrics/ClassLength
    def process(current_user, workspace) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
      scorecard = nil
      initiatives = {}

      focus_area_group_names = FocusAreaGroup.all.pluck(:name)
      focus_area_names = FocusArea.all.pluck(:name)
      characteristic_names = Characteristic.all.pluck(:name).map { |name| name.gsub(/\A\d+\.\d+\s/, '').downcase }

      data_rows.each.with_index(1) do |raw_row, row_index| # rubocop:disable Metrics/BlockLength
        row = sanitize_row(raw_row)

        next if row.compact.empty?

        # Find Scorecard
        if row_index == 1
          scorecard_name = row[1]
          scorecard = find_scorecard_by_name(workspace, scorecard_name)
          Rails.logger.info "ScorecardComments::Import: Scorecard identified: #{scorecard_name}"

          if scorecard.nil?
            processing_errors << build_processing_errors(
              row_data: row,
              row_index: row_index,
              error_messages: ["#{Scorecard.model_name.human} is invalid"]
            )
            return false
          end
          next
        end

        next if row[0].nil?

        # Find Initiatives
        if initiatives.empty? && row[0].downcase == 'name of initiative'
          initiative_names = row[1..].select(&:present?)

          initiative_names.each_with_index do |initiative_name, index|
            initiative = find_initiative_by_name(scorecard, initiative_name)
            if initiative.nil?
              processing_errors << build_processing_errors(
                row_data: row,
                row_index: row_index,
                error_messages: ["#{Initiative.model_name.human} '#{initiative_name}' is invalid"]
              )
              return false
            end

            initiatives[index + 1] = initiative
          end
        end

        if initiatives.empty?
          processing_errors << build_processing_errors(
            row_data: row,
            row_index: row_index,
            error_messages: ['Initiatives cannot be found. Cancelling import.']
          )
          return false
        end

        next if row[0].strip.in?(focus_area_group_names) || row[0].strip.in?(focus_area_names)

        if row[0].strip.downcase.in?(characteristic_names)

          characteristic_name = row[0].strip

          row[1..].each_with_index do |cell, index| # rubocop:disable Metrics/BlockLength
            comment = cell&.strip

            next if comment.blank?

            characteristic = Characteristic.find_by('characteristics.name ilike :name', name: "%#{characteristic_name}")
            initiative = initiatives[index + 1]

            if initiative.present? && characteristic.present?

              checklist_item = initiative
                               .checklist_items
                               .includes(:checklist_item_comments)
                               .find_by(characteristic: characteristic)

              if checklist_item.present?
                checklist_item.assign_attributes(
                  status: 'actual',
                  comment: comment
                )

                if checklist_item.changed? # rubocop:disable Metrics/BlockNesting
                  checklist_item.checklist_item_changes.build(
                    user: current_user,
                    starting_status: checklist_item.status_was,
                    ending_status: checklist_item.status,
                    comment: checklist_item.comment,
                    action: 'save_new_comment',
                    activity: checklist_item_activity(checklist_item)
                  )
                end

                checklist_item.user = current_user if checklist_item.user.nil?
                checklist_item.save
              end
            else
              missing_data = []

              missing_data << "Cannot find initiative ##{index + 1}" if initiative.nil?
              missing_data << "Cannot find characteristic '#{characteristic_name}''" if characteristic.nil?

              processing_errors << build_processing_errors(
                row_data: row,
                row_index: row_index,
                error_messages: [
                  "Unable to match '#{cell}': #{missing_data.join(' ')} . Skipping."
                ]
              )
            end
          end
        end
      end
      processing_errors.empty?
    end

    protected

    def data_rows
      rows
    end

    private

    # NOTE: Similar to code in checklist_items_controller.rb
    def checklist_item_activity(checklist_item)
      if new_comments_saved_assigned_actuals?(checklist_item)
        'new_comments_saved_assigned_actuals'
      else
        checklist_item.status_was != 'actual' && checklist_item.status == 'actual' ? 'addition' : 'none'
      end
    end

    # NOTE: Similar to code in checklist_items_controller.rb
    def new_comments_saved_assigned_actuals?(checklist_item)
      checklist_item.comment.present? &&
        checklist_item.status_was == 'actual' &&
        checklist_item.status == 'actual'
    end

    def find_scorecard_by_name(workspace, name)
      workspace.scorecards.where('lower(name) = :name', { name: name&.downcase }).first
    end

    def find_initiative_by_name(scorecard, name)
      scorecard
        .initiatives
        .where('lower(name) = :name', { name: name&.downcase })
        .includes(:checklist_items)
        .first
    end
  end
end
