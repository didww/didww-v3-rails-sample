# frozen_string_literal: true
module PermanentSupportingDocumentsHelper
  def available_supporting_document_templates
    supporting_document_templates_for_current_identity - presented_supporting_document_templates
  end

  private

  def presented_supporting_document_templates
    resource.permanent_documents.map(&:template).map { |d| [ d.name, d.id ] }
  end

  def supporting_document_templates_for_current_identity
    DIDWW::Resource::SupportingDocumentTemplate.where(permanent: true).map { |d| [ d.name, d.id ] }
  end
end
