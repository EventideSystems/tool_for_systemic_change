# frozen_string_literal: true

class CreateSectorsForAccounts < ActiveRecord::Migration[7.0]
  def up
    templates = Sector.templates

    Account.all.each do |account|
      templates.each do |template|
        sector = template.dup.tap { |s| s.account = account }
        sector.save!

        Organisation.where(account: account, sector: template).update_all(sector_id: sector.id)
      end
    end
  end

  def down
    Account.all.each do |account|
      account.sectors.each do |sector|
        template = Sector.templates.find_by(name: sector.name)

        Organisation.where(account: account, sector: sector).update_all(sector_id: template.id)
      end
    end

    Sector.where.not(account_id: nil).delete_all
  end

end
