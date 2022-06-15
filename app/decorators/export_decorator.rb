# frozen_string_literal: true
class ExportDecorator < ResourceDecorator
  def cdr_in?
    model.export_type == model.class::EXPORT_TYPE_CDR_IN
  end

  def cdr_out?
    model.export_type == model.class::EXPORT_TYPE_CDR_OUT
  end
end
