# frozen_string_literal: true
module PermanentSupportingDocumentsHelper
  def available_supporting_document_templates
    supporting_document_templates_for_current_identity - presented_supporting_document_templates
  end

  private

  def presented_supporting_document_templates
    resource.permanent_documents.map(&:template).map do |t|
      [ t.name, t.id, { 'data-permanent-document-template-url' => t.url } ]
    end
  end

  def supporting_document_templates_for_current_identity
    DIDWW::Resource::SupportingDocumentTemplate.where(permanent: true).map do |t|
      [ t.name, t.id, { 'data-permanent-document-template-url' => t.url } ]
    end
  end
end
