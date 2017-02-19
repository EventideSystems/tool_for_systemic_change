module AccountsHelper
  
  def current_account_name
    return 'No account selected' unless controller.current_account.present?
    controller.current_account.name
  end
  
  #
  def account_selector
    accounts = policy_scope(Account)
    
    if accounts.count == 1
      content_tag(:p, current_account_name)
    else
      selected_path = controller.current_account ? switch_account_path(controller.current_account) : ''
      
      options = {
        class: 'form-control',
        onchange: 'top.location.href=this.options[this.selectedIndex].value;' 
      }
      
      option_tags = options_for_select(
        accounts.map do |account| [
          account.name, switch_account_path(account)] 
        end, 
        selected_path
      )
      
      default_options.merge!(include_blank: true, prompt: 'No account selected') if selected_path.blank?
      
      content_tag(:form, '', class: 'account-select') do
        select_tag(:account_selector, option_tags, options)
      end
    end
  end
    
end


# <form name="cityselect">
#     <select name="menu" onChange="top.location.href=this.options[this.selectedIndex].value;" value="GO">
#         <option selected="selected">Select One</option>
#         <option value="http://www.leeds.com">Leeds</option>
#         <option value="http://www.manchester.com">Manchester</option>
#     </select>
# </form>