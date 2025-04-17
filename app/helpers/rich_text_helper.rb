# frozen_string_literal: true

# Helper for rendering rich text content
module RichTextHelper
  def rich_text(text)
    return '' if text.blank?

    sanitize(text, scrubber: rich_text_scrubber)
  end

  private

  def add_tailwind_classes_to_links(node)
    return unless node.name == 'a'

    default_classes = 'text-blue-600 hover:text-blue-700 dark:text-blue-500 dark:hover:text-blue-400'
    node['class'] = merge_tailwind_class(default_classes, node['class'])
  end

  def add_target_blank_to_links(node)
    return unless node.name == 'a' && node['href']

    node['target'] = '_blank' if node['target'].blank?
  end

  def disallow_script_tags(node)
    node.remove && return if node.name == 'script'
  end

  def remove_disallowed_attributes(node)
    allowed_attributes = %w[href target]
    node.attribute_nodes.each do |attr|
      node.remove_attribute(attr.name) unless allowed_attributes.include?(attr.name)
    end
  end

  def replace_disallowed_tags(node)
    allowed_tags = %w[div br strong em a p h1 h2 h3 h4 h5 h6 ul li]
    node.replace(node.text) if !allowed_tags.include?(node.name) && node.parent
  end

  def rich_text_scrubber
    @rich_text_scrubber ||= Loofah::Scrubber.new do |node|
      disallow_script_tags(node)
      replace_disallowed_tags(node)
      remove_disallowed_attributes(node)
      add_target_blank_to_links(node)
      add_tailwind_classes_to_links(node)
    end
  end
end
