# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CustomFormBuilder, type: :helper do
  let(:errors) { double('errors') } # rubocop:disable RSpec/VerifiedDoubles
  let(:object) { double('object', errors:) } # rubocop:disable RSpec/VerifiedDoubles
  let(:builder) { described_class.new(:object_name, object, helper, {}) }
  let(:method) { :attribute }

  shared_examples 'a text field' do |params = {}|
    let(:default_tailwind_class) { params[:default_tailwind_class] || CustomFormBuilder::TEXT_FIELD_CLASS }

    before do
      allow(object).to receive(:attribute).and_return(method.to_sym)
      allow(errors).to receive(:[]).with(method.to_s).and_return([])
      allow(errors).to receive(:[]).with(method).and_return([])
    end

    describe 'when options are blank' do
      it 'returns an input field with the default tailwind class' do
        expect(field_tag).to match(/class="(.*)#{default_tailwind_class}(.*)"/)
      end

      it 'wraps the input field in a div' do
        expect(field_tag).to match(%r{\A<div.*?>.*</div>\z}m)
      end

      context 'when there are errors' do
        before do
          allow(errors).to receive(:[]).with(method.to_s).and_return(['Error message'])
          allow(errors).to receive(:[]).with(method).and_return(['Error message'])
        end

        it 'returns an input field with the error class' do
          expect(field_tag).to match(/class="#{default_tailwind_class}(.*)border-red-500(.*)"/)
        end

        it 'returns an input field with the error message' do
          expect(field_tag).to match(%r{<div(.*?)>Error message</div>})
        end
      end
    end

    describe 'when options are present' do
    end
  end

  describe '#email_field' do
    let(:field_tag) { builder.email_field(method) }

    before do
      allow(object).to receive(:attribute).and_return(method.to_sym)
      allow(errors).to receive(:[]).with(method.to_s).and_return([])
      allow(errors).to receive(:[]).with(method).and_return([])
    end

    it 'returns an email field' do
      expect(field_tag).to match(%r{<input(.*)type="email"(.*)/>})
    end

    describe 'when options are blank' do
      it_behaves_like 'a text field'
    end

    describe 'when options are present' do
      it 'returns an email field with overidden options' do
        expect(
          builder.email_field(method, class: 'text-red-900 dark:text-green-400')
        ).to match(/class="(.*)text-red-900 dark:text-green-400(.*)"/)
      end

      it 'does not include overidden default options' do
        expect(
          builder.email_field(method, class: 'text-red-900 dark:text-green-400')
        ).not_to match(/class="(.*)text-gray-900 dark:text-white(.*)"/)
      end

      it 'preserves any other options' do
        expect(
          builder.email_field(method, id: 'custom-id', class: 'text-red-900 dark:text-green-400')
        ).to match(/id="custom-id"/)
      end
    end
  end

  describe '#label' do
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
        ).to match(%r{<label id=".*" class=".*" for="object_name_attribute">Label Text</label>})
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
        ).to match(%r{<label id=".*" class=".*" other=".*" for="object_name_attribute">Attribute</label>})
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

  describe '#text_area' do
    let(:field_tag) { builder.text_area(method) }

    describe 'when options are blank' do
      it_behaves_like 'a text field', default_tailwind_class: CustomFormBuilder::TEXT_AREA_CLASS
    end
  end

  describe '#text_field' do
    let(:field_tag) { builder.text_field(method) }

    describe 'when options are blank' do
      it_behaves_like 'a text field', default_tailwind_class: CustomFormBuilder::TEXT_AREA_CLASS
    end
  end
end
