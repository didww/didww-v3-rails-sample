# frozen_string_literal: true
class IdentityDecorator < ResourceDecorator
  def display_name
    if model.personal?
      full_name
    else
      "#{model.company_name} (#{full_name})"
    end
  end

  def full_name
    "#{model.first_name} #{model.last_name}"
  end

  def created_at
    format_time model.created_at
  end
end
