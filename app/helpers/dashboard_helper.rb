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
  
  # TODO Move this to application_helper
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
      content_tag(:div, new_resource_link, class: 'box-header')
    end
    
    def body
      content_tag(:div, '', class: 'box-body no-padding') do
         content_tag(:table, '', class: 'table table-striped') do
           content_tag(:tbody, safe_join([title_row] << data_rows))
        end
      end
    end
    
    def new_resource_link
      new_resource_link = if action_available?(:new)
        link_to(
          "New #{resource_type.to_s.singularize.titleize}", 
          controller: resource_type.to_s.pluralize, 
          action: 'new'
        )
      else
        ''
      end  
    end
    
    def action_available?(action)
      view.url_for(:controller => view.controller.controller_name, :action => action.to_s).present?
    rescue  
      false
    end
  end
  
  # TODO Move this to application_helper
  def resource_table(resource_name, columns)
    ResourceTable.new(self, resource_name, columns).html
  end

end