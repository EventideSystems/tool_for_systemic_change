require 'rails_helper'

RSpec.describe DataModels::RepositionElement, type: :service do
  let(:element) { create(:focus_area_group, position: 2) }
  let(:sibling1) { create(:focus_area_group, position: 1) }
  let(:sibling2) { create(:focus_area_group, position: 3) }
  let(:siblings) { [sibling1, element, sibling2] }
  let(:new_position) { 1 }

  describe '#call' do
    it 'reorders the elements correctly' do
      service = described_class.new(element: element, new_position: new_position, siblings: siblings)
      service.call

      expect(element.position).to eq(new_position)
      expect(sibling1.position).to eq(2)
      expect(sibling2.position).to eq(3)
    end

    context 'new position is the same as the current position' do
      let(:new_position) { 2 }

      it 'does not change the positions' do
        service = described_class.new(element: element, new_position: new_position, siblings: siblings)
        service.call

        expect(element.position).to eq(2)
        expect(sibling1.position).to eq(1)
        expect(sibling2.position).to eq(3)
      end
    end

    context 'new position is out of bounds' do
      pending "add some examples to (or delete) #{__FILE__}"
    end

    context 'new element has not been persisted' do
      let(:element) { build(:focus_area_group, position: 2) }

      it 'reorders the elements correctly' do      
        service = described_class.new(element: element, new_position: new_position, siblings: siblings)
        service.call

        expect(element.position).to eq(new_position)
        expect(sibling1.position).to eq(2)
        expect(sibling2.position).to eq(3)
      end
    end
  end
end