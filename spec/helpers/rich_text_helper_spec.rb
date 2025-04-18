# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RichTextHelper, type: :helper do
  describe '#rich_text' do
    context 'when the input text is blank' do
      it 'returns an empty string when the input text is nil' do
        expect(helper.rich_text(nil)).to eq('')
      end

      it 'returns an empty string when the input text is an empty string' do
        expect(helper.rich_text('')).to eq('')
      end
    end

    context 'when the input text contains allowed HTML tags' do
      it 'sanitizes and retains the allowed tags' do
        input = '<div><strong>Bold Text</strong> and <em>Italic Text</em></div>'
        output = '<div><strong>Bold Text</strong> and <em>Italic Text</em></div>'
        expect(helper.rich_text(input)).to eq(output)
      end
    end

    context 'when the input text contains disallowed HTML tags' do
      it 'removes the completely banned tags' do
        input = '<script>alert("XSS")</script><p>Safe Text</p>'
        output = '<p>Safe Text</p>'
        expect(helper.rich_text(input)).to eq(output)
      end

      it 'removes the disallowed tags and replaces them with their text content' do
        input = '<div><span>Safe Text</span></div>'
        output = '<div>Safe Text</div>'
        expect(helper.rich_text(input)).to eq(output)
      end
    end

    context 'when the input text contains allowed attributes' do
      it 'retains the allowed attributes' do
        input = '<a href="https://example.com" target="_blank" >Link</a>'
        output = '<a href="https://example.com" target="_blank" class="text-blue-600 hover:text-blue-700 dark:text-blue-500 dark:hover:text-blue-400">Link</a>' # rubocop:disable Layout/LineLength
        expect(helper.rich_text(input)).to eq(output)
      end
    end

    context 'when the input text contains a href without a target' do
      it 'retains the allowed attributes' do
        input = '<a href="https://example.com">Link</a>'
        output = '<a href="https://example.com" target="_blank" class="text-blue-600 hover:text-blue-700 dark:text-blue-500 dark:hover:text-blue-400">Link</a>' # rubocop:disable Layout/LineLength
        expect(helper.rich_text(input)).to eq(output)
      end
    end

    context 'when the input text contains disallowed attributes' do
      it 'removes the disallowed attributes' do
        input = '<a href="https://example.com" onclick="alert(\'XSS\')">Link</a>'
        output = '<a href="https://example.com" target="_blank" class="text-blue-600 hover:text-blue-700 dark:text-blue-500 dark:hover:text-blue-400">Link</a>' # rubocop:disable Layout/LineLength
        expect(helper.rich_text(input)).to eq(output)
      end
    end
  end
end
