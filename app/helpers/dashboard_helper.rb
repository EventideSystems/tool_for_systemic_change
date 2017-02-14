module DashboardHelper
  
  def menu_item_tag(resources, icon, options={})
    controller_name = options[:controller] || resources.to_s
    
    menu_item_class = controller.controller_name == controller_name ? 'active' : ''

    content_tag(:li, class: menu_item_class) do
      link_to(controller: controller_name, action: 'index') do
        concat content_tag(:i, '', class: "fa fa-#{h icon}")
        concat content_tag(:span, resources.to_s.titleize)
      end
    end
  end
  
  def content_title
    content_tag(:h1) do
      concat controller.controller_name.titleize 
      # <small></small>
    end
  end
  
  def current_user_name
    return '' unless user_signed_in?
    return current_user.email unless current_user.name.present?
    current_user.name
  end
  
  def current_user_membership_summary
    return '' unless user_signed_in?
    "Member since #{current_user.created_at}"
  end
  
  class ResourceTable
    
    def initialize(view, resources_name, columns)
      @view = view
      @resource_type = resources_name
      @resources = view.assigns[resources_name.to_s]
      @columns = columns
    end
        
    def html
      content_tag(:div, safe_join([header, body]), class: 'box')
    end
    
    private
    
    attr_accessor :view, :resource_type, :resources, :columns
    delegate :concat, :link_to, :content_tag, :safe_join, to: :view
    
    def title_row
      content_tag(:tr, 
        safe_join(
          columns.map {|c| content_tag(:th, c.to_s.titleize) } << content_tag(:th)
        )
      )
    end
    
    def data_rows
      resources.map do |resource|
        content_tag(:tr, 
          safe_join(
            columns.map {|c| content_tag(:td, resource.send(c)) } << content_tag(:td, link_to('a', resource))
          )
        )
      end
    end
    
    def header
      content_tag(
        :div, 
        link_to("New #{resource_type.to_s.singularize.titleize}", controller: resource_type.to_s.pluralize, action: 'new'),
        class: 'box-header' 
      )
    end
    
    def body
      content_tag(:div, '', class: 'box-body no-padding') do
         content_tag(:table, '', class: 'table table-striped') do
           content_tag(:tbody, safe_join([title_row] << data_rows))
        end
      end
    end
    
    
  end
  
  def resource_table(resource_name, columns)
    ResourceTable.new(self, resource_name, columns).html
  end

end