require 'rails_helper'
require 'shared_contexts'

RSpec.describe "Scorecard Initiatives", type: :request do

  include_context "api request authentication helper methods"
  include_context "api request global before and after hooks"
  include_context "setup common data"

  describe "scorecard initiatives (aka scorecard report)" do

    let!(:initiative_1) { create(:initiative, scorecard: scorecard, organisations: [organisation]) }
    let!(:initiative_2) { create(:initiative, scorecard: scorecard, organisations: [organisation]) }

    # NOTE Used to ensure relationships / includes aren't greedy and included
    # data from unrelated initiatives
    let!(:other_initiative) { create(:initiative, scorecard: other_scorecard, organisations: [other_organisation]) }


    before(:each) do
      initiative_1.checklist_items.each do |checklist_item|
        checklist_item.checked = true
        checklist_item.save!
      end

      sign_in(staff)
      get scorecard_initiatives_path(scorecard)

      @data = JSON.parse(response.body)['data']
      @included = JSON.parse(response.body)['included']
    end

    specify "retrieves initiatives" do
      expect(@data.count).to be(2)
    end

    describe "relationships" do

      specify "scorecard" do
        scorecard_data = @data.first['relationships']['scorecard']['data']
        expect(scorecard_data['id'].to_i).to eq(scorecard.id)
      end

      specify "checklist items" do
        items_data = @data[0]['relationships']['checklistItems']['data']

        expect(items_data.count).to be(initiative_1.checklist_items.count)
      end

      specify "organisations" do
        organisation_data = @data[0]['relationships']['organisations']['data']

        expect(organisation_data.count).to be(1)
        expect(organisation_data[0]['id'].to_i).to be(organisation.id)
      end

    end

    describe "included" do

      def select_included_data(type)
        @included.select { |data| data['type'] == type }
      end

      specify "characteristics" do
        expect(Characteristic.count).to satisfy { |c| c > 1 }

        expect(
          select_included_data('characteristics').count
        ).to be(Characteristic.count)
      end

      specify "focus areas" do
        expect(FocusArea.count).to satisfy { |c| c > 1 }

        expect(
          select_included_data('focus_areas').count
        ).to be(FocusArea.count)
      end

      specify "focus area groups" do
        expect(FocusAreaGroup.count).to satisfy { |c| c > 1 }

        expect(
          select_included_data('focus_area_groups').count
        ).to be(FocusAreaGroup.count)
      end

      describe "checklist items" do

        before(:each) do
          @checklist_items = select_included_data('checklist_items')
        end

        specify "count equals " do
          expect(@checklist_items.count).to be(scorecard.checklist_items.count)
        end

        specify "checklist items - checked" do
          expect(@checklist_items.first['attributes']['checked']).to be(true)
          expect(@checklist_items.last['attributes']['checked']).to_not be(true)
        end
      end
    end
  end

end
