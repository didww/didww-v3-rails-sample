# frozen_string_literal: true
class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  class_attribute :logger, instance_writer: false, default: Rails.logger

  def save
    return false unless valid?

    _save
  end

  private

  def _save
    raise NotImplementedError
  end

  private

  def propagate_errors(record)
    record.errors.each do |attribute, message|
      add_custom_error(attribute, message)
    end
  end

  def add_custom_error(attribute, detail, message = nil)
    message ||= detail
    errors.details[attribute.to_sym] << detail
    errors.messages[attribute.to_sym] << message
  end
end
