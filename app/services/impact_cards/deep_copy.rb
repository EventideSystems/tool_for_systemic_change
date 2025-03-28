# frozen_string_literal: true

module ImpactCards
  # rubocop:disable Metrics/ClassLength,Style/Documentation,Metrics/AbcSize,Metrics/MethodLength,Metrics/BlockLength
  class DeepCopy
    attr_accessor :impact_card, :new_name, :target_workspace

    def self.call(impact_card:, new_name: nil, target_workspace: nil)
      new(impact_card:, new_name:, target_workspace:).call
    end

    def initialize(impact_card:, new_name: nil, target_workspace: nil)
      @impact_card = impact_card
      @new_name = new_name.presence || "#{impact_card.name} (copy)"
      @target_workspace = target_workspace.presence || impact_card.workspace
    end

    def call
      assert_valid_target_workspace!

      ActiveRecord::Base.transaction do
        copy_wicked_problem
        copy_community
        copy_subsystem_tags
        copy_stakeholders

        impact_card.dup.tap do |new_impact_card|
          new_impact_card.name = new_name
          new_impact_card.shared_link_id = impact_card.new_shared_link_id
          new_impact_card.wicked_problem = find_matching_wicked_problem(impact_card.wicked_problem)
          new_impact_card.community = find_matching_community(impact_card.community)
          new_impact_card.workspace = target_workspace
          new_impact_card.save!

          copy_initiatives(impact_card, new_impact_card)
        end
      end
    end

    private

    # Ensure that the target workspace has a compatible data model
    def assert_valid_target_workspace! # rubocop:disable Metrics/CyclomaticComplexity
      return if target_workspace == impact_card.workspace

      target_workspace_impact_card_data_model = target_workspace.impact_card_data_models.find_by(
        name: impact_card.impact_card_data_model.name
      )

      if target_workspace_impact_card_data_model.blank?
        raise(ArgumentError, 'Target workspace does not have a compatible data model')
      end

      target_workspace_impact_card_data_model.focus_area_groups.find_each do |focus_area_group|
        target_group = find_target_focus_area_group(focus_area_group.name, target_workspace_impact_card_data_model)

        if target_group.blank?
          raise(ArgumentError, "Missing focus area group '#{focus_area_group.name}' in target workspace")
        end

        focus_area_group.focus_areas.each do |focus_area|
          target_area = target_group.focus_areas.find_by(name: focus_area.name)

          raise(ArgumentError, "Missing focus area '#{focus_area.name}' in target workspace") if target_area.blank?

          focus_area.characteristics.each do |characteristic|
            target_characteristic = target_area.characteristics.find_by(name: characteristic.name)

            next if target_characteristic.present?

            raise(ArgumentError, "Missing characteristic '#{characteristic.name}' in target workspace")
          end
        end
      end
    end

    # NOTE: We are using Initiative.where(scorecard: source_impact_card) to as the source of the initiatives to copy as
    # source_impact_card.initiatives will return the list ordered by name, which is not guaranteed to be the order in
    # which they appear in the grid. We need to maintain the order of the initiatives in the grid, otherwise we may
    # confuse users.
    def copy_initiatives(source_impact_card, target_impact_card)
      Initiative.where(scorecard: source_impact_card).find_each do |initiative|
        initiative.dup.tap do |new_initiative|
          new_initiative.scorecard = target_impact_card
          new_initiative.subsystem_tags = fetch_subsystem_tags(initiative)
          new_initiative.organisations = fetch_stakeholders(initiative)
          new_initiative.save!
          new_initiative.reload

          initiative.checklist_items.each do |checklist_item|
            next if checklist_item.status == 'no_comment'

            # TODO: Refactor this to use a more efficient method
            new_checklist_item =
              new_initiative.checklist_items.find do |item|
                item.characteristic.name == checklist_item.characteristic.name
              end

            # SMELL: Relaxing validations here as there are cases where the checklist items are not valid (old data)
            new_checklist_item.update_columns( # rubocop:disable Rails/SkipsModelValidations
              status: checklist_item.status,
              comment: checklist_item.comment,
              user_id: checklist_item.user_id,
              created_at: checklist_item.created_at,
              updated_at: checklist_item.updated_at
            )

            checklist_item.checklist_item_changes.each do |change|
              new_checklist_item.checklist_item_changes.create!(
                user: change.user,
                starting_status: change.starting_status,
                ending_status: change.ending_status,
                comment: change.comment,
                action: change.action,
                activity: change.activity,
                created_at: change.created_at
              )
            end
          end
        end
      end
    end

    def copy_stakeholders
      return if target_workspace == impact_card.workspace

      impact_card.organisations.uniq.each do |organisation|
        next if target_workspace.organisations.find_by(name: [organisation.name, organisation.name.strip])

        stakeholder_type = fetch_stakeholder_type(organisation.stakeholder_type)

        organisation.dup.tap do |new_organisation|
          new_organisation.name = organisation.name.strip
          new_organisation.workspace = target_workspace
          new_organisation.stakeholder_type = stakeholder_type
          new_organisation.save!
        end
      end
    end

    def copy_subsystem_tags
      return if target_workspace == impact_card.workspace

      impact_card.subsystem_tags.uniq.each do |tag|
        next if target_workspace.subsystem_tags.find_by(name: [tag.name, tag.name.strip])

        target_workspace.subsystem_tags.create!(name: tag.name.strip)
      end
    end

    def copy_wicked_problem
      return if impact_card.wicked_problem.blank?
      return if target_workspace == impact_card.workspace

      wicked_problem = impact_card.wicked_problem

      return if target_workspace.wicked_problems.find_by(name: wicked_problem.name)

      wicked_problem.dup.tap do |new_wicked_problem|
        new_wicked_problem.workspace = target_workspace
        new_wicked_problem.save!
      end
    end

    def copy_community
      return if impact_card.community.blank?
      return if target_workspace == impact_card.workspace

      community = impact_card.community

      return if target_workspace.communities.find_by(name: community.name)

      community.dup.tap do |new_community|
        new_community.workspace = target_workspace
        new_community.save!
      end
    end

    def fetch_stakeholder_type(stakeholder_type)
      target_stakeholder_type = target_workspace.stakeholder_types.find_by(name: stakeholder_type.name)

      return target_stakeholder_type if target_stakeholder_type.present?

      stakeholder_type.dup.tap do |new_stakeholder_type|
        new_stakeholder_type.workspace = target_workspace
        new_stakeholder_type.save!
      end
    end

    def fetch_stakeholders(initiative)
      target_workspace.organisations.where(name: initiative.organisations.pluck(:name).map(&:strip))
    end

    def fetch_subsystem_tags(initiative)
      target_workspace.subsystem_tags.where(name: initiative.subsystem_tags.pluck(:name).map(&:strip))
    end

    # Find a community in the target workspace that matches the source community
    def find_matching_community(community)
      return nil if community.blank?

      target_workspace.communities.find_by(name: community.name)
    end

    def find_matching_wicked_problem(wicked_problem)
      return nil if wicked_problem.blank?

      target_workspace.wicked_problems.find_by(name: wicked_problem.name)
    end

    def find_target_focus_area_group(name, target_workspace_impact_card_data_model)
      target_workspace_impact_card_data_model.focus_area_groups.find_by(name:)
    end
  end
  # rubocop:enable Metrics/ClassLength,Style/Documentation,Metrics/AbcSize,Metrics/MethodLength,Metrics/BlockLength
end
