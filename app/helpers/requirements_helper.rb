# frozen_string_literal: true
module RequirementsHelper
  def document_template_link(document_template)
    return if document_template.nil?

    link_to document_template.name, document_template.url
  end
end
