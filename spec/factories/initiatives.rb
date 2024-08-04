# frozen_string_literal: true

# == Schema Information
#
# Table name: initiatives
#
#  id               :integer          not null, primary key
#  archived_on      :datetime
#  contact_email    :string
#  contact_name     :string
#  contact_phone    :string
#  contact_position :string
#  contact_website  :string
#  dates_confirmed  :boolean
#  deleted_at       :datetime
#  description      :string
#  finished_at      :date
#  linked           :boolean          default(FALSE)
#  name             :string
#  old_notes        :text
#  started_at       :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  scorecard_id     :integer
#
# Indexes
#
#  index_initiatives_on_archived_on   (archived_on)
#  index_initiatives_on_deleted_at    (deleted_at)
#  index_initiatives_on_finished_at   (finished_at)
#  index_initiatives_on_name          (name)
#  index_initiatives_on_scorecard_id  (scorecard_id)
#  index_initiatives_on_started_at    (started_at)
#
FactoryBot.define do
  factory :initiative do
    scorecard

    name { FFaker::Name.name }
    description { FFaker::Lorem.paragraph }
    started_at { Date.today - 1 }
    finished_at { Date.today + 1 }
    dates_confirmed { true }
    contact_name { FFaker::Name.name }
    contact_email { FFaker::Internet.email }
    contact_phone { FFaker::PhoneNumberAU.phone_number }
    contact_website { FFaker::Internet.http_url }
    contact_position { FFaker::Job }
  end
end
