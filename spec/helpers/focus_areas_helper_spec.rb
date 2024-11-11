# frozen_string_literal: true

# spec/helpers/focus_areas_helper_spec.rb
require 'rails_helper'

RSpec.describe(FocusAreasHelper, type: :helper) do
  describe '#focus_area_model_name' do
    let(:account) { double('Account') } # rubocop:disable RSpec/VerifiedDoubles
    let(:focus_area) { double('FocusArea', account:, model_name: double('ModelName', human: 'FocusArea')) } # rubocop:disable RSpec/VerifiedDoubles

    context 'when scorecard_type is TransitionCard' do
      before do
        allow(focus_area).to(receive(:scorecard_type).and_return('TransitionCard'))
        allow(account).to(receive(:transition_card_focus_area_model_name).and_return('Transition Card Model Name'))
      end

      it 'returns the transition card focus area model name' do
        expect(helper.focus_area_model_name(focus_area)).to(eq('Transition Card Model Name'))
      end
    end

    context 'when scorecard_type is SustainableDevelopmentGoalAlignmentCard' do
      before do
        allow(focus_area).to(
          receive(:scorecard_type)
          .and_return('SustainableDevelopmentGoalAlignmentCard')
        )

        allow(account).to(
          receive(:sdgs_alignment_card_focus_area_model_name)
            .and_return('SDGs Alignment Card Model Name')
        )
      end

      it 'returns the SDGs alignment card focus area model name' do
        expect(helper.focus_area_model_name(focus_area)).to(eq('SDGs Alignment Card Model Name'))
      end
    end

    context 'when scorecard_type is not recognized' do
      before do
        allow(focus_area).to(receive(:scorecard_type).and_return('UnknownCard'))
      end

      it 'returns the humanized and titleized model name' do
        expect(helper.focus_area_model_name(focus_area)).to(eq('Focus Area'))
      end
    end

    context 'when account is nil' do
      let(:focus_area) { double('FocusArea', account: nil, model_name: double('ModelName', human: 'FocusArea')) } # rubocop:disable RSpec/VerifiedDoubles

      before do
        allow(focus_area).to(receive(:scorecard_type).and_return('TransitionCard'))
      end

      it 'returns the humanized and titleized model name' do
        expect(helper.focus_area_model_name(focus_area)).to(eq('Focus Area'))
      end
    end
  end
end
