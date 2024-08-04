# require 'table_for/base'

# module TableFor
#   class Base < WithTemplate::Base
#     def header_sort_link(column, options={}, &block)
#       if options[:sortable] && (options[:header] || !column.anonymous)
#         order = options[:order] ? options[:order].to_s : column.name.to_s

#         sort_modes = TableFor.config.sort_modes
#         current_sort_mode = (view.params[:order] != order || view.params[:sort_mode].blank?) ? nil : view.params[:sort_mode]
#         next_sort_mode_index = sort_modes.index(current_sort_mode.to_sym) + 1 rescue 0
#         if next_sort_mode_index == sort_modes.length
#           next_sort_mode = nil
#         else
#           next_sort_mode = sort_modes[next_sort_mode_index]
#         end

#         parameters = view.params.merge(:order => order, :sort_mode => next_sort_mode).to_unsafe_h
#         parameters.delete(:action)
#         parameters.delete(:controller)
#         url = options[:sort_url] ? options[:sort_url] : ""
#         view.link_to view.capture(self, &block), "#{url}?#{parameters.to_query}"
#       else
#         view.capture(self, &block)
#       end
#     end
#   end
# end
