module DashboardHelper
  
  def menu_item_tag(resources, icon, options={})
    controller_name = '/' + (options[:controller].try(:to_s) || resources.to_s)
    title = options[:title] || resources.to_s.titleize
    
    menu_item_class = controller.controller_name == controller_name.to_s ? 'active' : ''
    link_class = options[:disabled] == true ? 'link-disabled' : ''
    
    content_tag(:li, class: menu_item_class) do
      link_to({controller: controller_name, action: 'index'}, {class: link_class}) do
        concat content_tag(:i, '', class: "fa fa-#{h icon}")
        concat content_tag(:span, title)
      end
    end
  end
  
  def content_title
    content_tag(:h1) do
      concat controller.content_title
      concat content_tag(:small, controller.content_subtitle)
      concat yield if block_given?
    end
  end

  def breadcrumb
    content_tag(:ol, class: 'breadcrumb') do
      # concat content_tag(:li, content_tag(:a, '', content_tag(:i, ' Home', class: 'fa fa-dashboard')))
      concat content_tag(
        :li, 
        link_to(safe_join([
          content_tag(:i, '', class: 'fa fa-dashboard'),
          ' Home'
        ]), root_path)
      )
      concat content_tag(:li, controller.controller_name.titleize, class: 'active')
    end
  end
end


# <ol class="breadcrumb">
#   <li>
#       <a href="#"><i class="fa fa-dashboard"></i> Home</a>
#     </li>
# #   <li class="active">Dashboard</li>
# </ol>
#
# <ol class="breadcrumb">
#   <li><a href="/"><i class="fa fa-dashboard"> Home</i></a></li>
#   <li class="active">DashboardX</li>
# </ol>