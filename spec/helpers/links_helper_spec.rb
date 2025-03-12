# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LinksHelper, type: :helper do
  describe '#link_to_external_url' do
    let(:valid_url) { 'http://example.com' }
    let(:invalid_url) { 'invalid-url' }
    let(:domain) { 'example.com' }

    context 'when the URL is blank' do
      it 'returns an empty string' do
        expect(helper.link_to_external_url('')).to eq('')
      end
    end

    # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
    context 'when the URL is valid' do
      it 'returns a link to the domain with the correct attributes' do
        link = helper.link_to_external_url(valid_url)
        expect(link).to include("href=\"#{valid_url}\"")
        expect(link).to include('target="_blank"')
        expect(link).to include('rel="noopener"')
        expect(link).to include("class=\"#{LinksHelper::EXTERNAL_LINK_CLASS}\"")
        expect(link).to include(domain)
      end
    end
    # rubocop:enable RSpec/ExampleLength,RSpec/MultipleExpectations

    # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
    context 'when the URL is missing the protocol' do
      it 'returns a link to the domain with the correct attributes' do
        link = helper.link_to_external_url('example.com')
        expect(link).to include('href="https://example.com"')
        expect(link).to include('target="_blank"')
        expect(link).to include('rel="noopener"')
        expect(link).to include("class=\"#{LinksHelper::EXTERNAL_LINK_CLASS}\"")
        expect(link).to include(domain)
      end
    end
    # rubocop:enable RSpec/ExampleLength,RSpec/MultipleExpectations

    context 'when the URL is invalid' do
      it 'returns a warning message' do
        expect(helper.link_to_external_url(invalid_url))
          .to eq('<span class="text-orange-950 dark:text-orange-500">invalid-url [invalid URL]</span>')
      end
    end

    context 'when the URL has an invalid domain' do
      it 'returns a warning message' do
        expect(helper.link_to_external_url('https://'))
          .to eq('<span class="text-orange-950 dark:text-orange-500">https:// [invalid URL]</span>')
      end
    end
  end
end
