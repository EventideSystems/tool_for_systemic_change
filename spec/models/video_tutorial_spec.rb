# frozen_string_literal: true

# == Schema Information
#
# Table name: video_tutorials
#
#  id                   :integer          not null, primary key
#  deleted_at           :datetime
#  description          :text
#  link_url             :string
#  linked_type          :string
#  name                 :string
#  position             :integer
#  promote_to_dashboard :boolean
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  linked_id            :integer
#
# Indexes
#
#  index_video_tutorials_on_deleted_at                 (deleted_at)
#  index_video_tutorials_on_linked_type_and_linked_id  (linked_type,linked_id)
#
require 'rails_helper'

RSpec.describe VideoTutorial, type: :model do
  subject { described_class.new(link_url: link_url) }

  let(:link_url) { 'https://vimeo.com/208056324' }
  let(:thumbnail_iframe) { subject.thumbnail_iframe }
  let(:iframe) { subject.iframe }

  context 'with thumbnail_iframe' do
    it { # rubocop:disable RSpec/ExampleLength
      expect(thumbnail_iframe).to eq(
        <<~HTML
          <iframe
            src="https://player.vimeo.com/video/208056324"
            width="90"
            height="90"
            frameborder="0"
            webkitallowfullscreen
            mozallowfullscreen
            allowfullscreen>
          </iframe>
        HTML
      )
    }
  end

  context 'with iframe' do
    it { # rubocop:disable RSpec/ExampleLength
      expect(iframe).to eq(
        <<~HTML
          <iframe
            src="https://player.vimeo.com/video/208056324"
            width="570"
            height="380"
            frameborder="0"
            webkitallowfullscreen
            mozallowfullscreen
            allowfullscreen>
          </iframe>
        HTML
      )
    }
  end

  context 'with private vimeo link' do
    let(:link_url) { 'https://vimeo.com/208056324/607c549a71' }

    context 'with thumbnail_iframe' do
      it { # rubocop:disable RSpec/ExampleLength
        expect(thumbnail_iframe).to eq(
          <<~HTML
            <iframe
              src="https://player.vimeo.com/video/208056324"
              width="90"
              height="90"
              frameborder="0"
              webkitallowfullscreen
              mozallowfullscreen
              allowfullscreen>
            </iframe>
          HTML
        )
      }
    end
  end
end
