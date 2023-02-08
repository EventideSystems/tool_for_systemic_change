# frozen_string_literal: true

module AccountsHelper
  def lookup_accounts
    policy_scope(Account).all
  end

  def lookup_account_roles
    AccountsUser.account_roles.keys
  end

  def lookup_system_roles
    User.system_roles.keys
  end

  def account_selector
    accounts = policy_scope(Account).order(:name)

    if accounts.count == 1
      content_tag(:p, current_account_name)
    else
      selected_path = controller.current_account ? switch_account_path(controller.current_account) : ''

      options = {
        class: 'form-control sidebar-form',
        onchange: 'top.location.href=this.options[this.selectedIndex].value;'
      }

      option_tags = options_for_select(
        accounts.map do |account|
          [
            account.name, switch_account_path(account)
          ]
        end,
        selected_path
      )

      options.merge!(include_blank: true, prompt: 'No account selected') if selected_path.blank?

      content_tag(:form, '', class: 'account-select') do
        content_tag(:div, '', class: 'input-group') do
          select_tag(:account_selector, option_tags, options)
        end
      end
    end
  end

  private

  def current_account_name
    return 'No account selected' unless controller.current_account.present?

    controller.current_account.name
  end
end
