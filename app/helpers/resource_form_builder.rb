# frozen_string_literal: true
class ResourceFormBuilder < ActionView::Helpers::FormBuilder
  def l_text_field(atr, options = {})
    control_label(atr) +
    text_field(atr, form_control(options))
  end

  def l_select(atr, choices = nil, options = {}, html_options = {}, &block)
    control_label(atr) +
    select(atr, choices, options, form_control(html_options), &block)
  end

  def l_text_area(atr, options = {})
    control_label(atr) +
    text_area(atr, form_control(options))
  end

  def l_check_box(atr, options = {})
    label(atr, class: 'checkbox-inline') do
      check_box(atr, options) + label(atr)
    end
  end

  def l_number_field(atr, options = {})
    control_label(atr) +
    number_field(atr, form_control(options))
  end

  def control_label(atr, options = {})
    label(atr, options.reverse_merge(class: 'control-label'))
  end

  def has_error?(atr, obj = object)
    'has-error' if obj.errors[atr].any? rescue nil
  end

  private

  def form_control(options = {})
    options.reverse_merge(class: 'form-control')
  end

end
