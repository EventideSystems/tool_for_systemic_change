# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomFormBuilder, type: :helper do
  let(:object) { double('object') } # rubocop:disable RSpec/VerifiedDoubles
  let(:builder) { described_class.new(:object_name, object, helper, {}) }

  describe '#label' do
    let(:method) { :attribute }

    describe 'when options are blank and content is a string' do
      it 'returns a label tag with the provided contents' do
        expect(
          builder.label(method, 'Label Text')
        ).to match(%r{<label class=".*" for="object_name_attribute">Label Text</label>})
      end

      it 'returns a label tag with the default class' do
        expect(
          builder.label(method, 'Label Text')
        ).to match(/class="block text-sm font-medium leading-6 text-gray-900 dark:text-white"/)
      end
    end

    describe 'when options are blank and content is a hash' do
      it 'merges any class values from content with the default classes' do
        expect(
          builder.label(method, class: 'text-red-900 dark:text-green-400')
        ).to match(/class="block text-sm font-medium leading-6 text-red-900 dark:text-green-400"/)
      end

      it 'preserves any other options' do
        expect(
          builder.label(method, id: 'custom-id', class: 'text-red-900 dark:text-green-400')
        ).to match(/id="custom-id"/)
      end
    end

    describe 'when options are present and content is a string' do
      it 'returns a label tag with the provided contents' do
        expect(
          builder.label(method, 'Label Text', id: 'custom-id')
        ).to match(%r{<label class=".*" for="object_name_attribute">Label Text</label>})
      end

      it 'merges any class values from content with the default classes' do
        expect(
          builder.label(method, 'Label Text', class: 'text-red-900 dark:text-green-400')
        ).to match(/class="block text-sm font-medium leading-6 text-red-900 dark:text-green-400"/)
      end

      it 'preserves any other options' do
        expect(
          builder.label(method, 'Label Text', id: 'custom-id', class: 'text-red-900 dark:text-green-400')
        ).to match(/id="custom-id"/)
      end
    end

    describe 'when options are present and content is a hash' do
      it 'returns a label tag with the method name as the text' do
        expect(
          builder.label(method, { other: '1' }, { id: 'custom-id' })
        ).to match(%r{<label class=".*" for="object_name_attribute">Attribute</label>})
      end

      it 'merges any class values from content with the default classes' do
        expect(
          builder.label(method, { class: 'text-red-900 dark:text-green-400' }, { id: 'custom-id' })
        ).to match(/class="block text-sm font-medium leading-6 text-red-900 dark:text-green-400"/)
      end

      it 'merges any class values from options with the default classes' do
        expect(
          builder.label(method, { id: 'custom-id' }, { class: 'text-red-900 dark:text-green-400' })
        ).to match(/class="block text-sm font-medium leading-6 text-red-900 dark:text-green-400"/)
      end

      it 'preserves any other options' do
        expect(
          builder.label(method, { id: 'custom-id' }, { class: 'text-red-900 dark:text-green-400' })
        ).to match(/id="custom-id"/)
      end
    end
  end
end
