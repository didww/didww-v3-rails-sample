# frozen_string_literal: true
module ResourceHelper
  def attribute_row_classes
    'col-lg-3 col-md-4 col-sm-6'
  end

  def empty_label
    tag.span('EMPTY', class: 'label label-default')
  end

  def attribute_row(attribute, options = {})
    label = options[:label] || t("#{resource.type.singularize}.#{attribute}")
    value = options.key?(:value) ? options[:value] : resource.public_send(attribute)
    value = empty_label if value.blank?
    value_classes = options[:value_classes] || ''
    tag.tr do
      tag.td(tag.strong(label), class: attribute_row_classes) +
      tag.td(value.to_s, class: value_classes)
    end
  end

  def resource_form_with(**options, &block)
    options.reverse_merge! builder: ResourceFormBuilder
    form_with(**options, &block)
  end

  def new_button(path, small = false, label: 'Add new')
    link_to path, class: "btn btn-success #{'btn-xs' if small} js-clickable-nofollow" do
      tag.i(class: "fa fa-plus #{'fa-lg' if !small}") + "&nbsp;&nbsp;#{label}&nbsp;&nbsp".html_safe
    end
  end

  def show_button(path, small = false)
    link_to path, class: "btn btn-success #{'btn-xs' if small} js-clickable-nofollow" do
      tag.i(class: 'fa fa-eye') + ' Show'
    end
  end

  def edit_button(path, small = false)
    link_to path, class: "btn btn-info #{'btn-xs' if small} js-clickable-nofollow" do
      tag.i(class: 'fa fa-pencil') + ' Edit'
    end
  end

  def calc_classes(*classes)
    opts = classes.extract_options!
    classes += opts.select { |_, v| v }.keys
    classes.compact.join(' ')
  end

  def modal_trigger_button(text, modal_id:, type:, icon:, small: false, **options)
    classes = calc_classes(
      'btn',
      "btn-#{type}",
      options[:class],
      'btn-xs': small
    )
    button_attrs = {
      type: 'button',
      class: classes,
      'data-toggle': 'modal',
      'data-target': "##{modal_id}",
      **options.except(:class)
    }
    tag.button(button_attrs) do
      tag.i(class: "fa fa-#{icon}") + " #{text}"
    end
  end

  def delete_button(path, small = false, confirm:, text: 'Delete')
    link_to path, method: :delete, data: { confirm: confirm }, class: "btn btn-danger #{'btn-xs' if small} js-clickable-nofollow" do
      tag.i(class: 'fa fa-times') + ' ' + text
    end
  end

  def cancel_button(path, small = false, confirm:)
    link_to path, method: :delete, data: { confirm: confirm }, class: "btn btn-danger #{'btn-xs' if small} js-clickable-nofollow" do
      tag.i(class: 'fa fa-minus-circle') + ' Cancel'
    end
  end

  def download_button(path, small = false)
    link_to path, class: "btn btn-info #{'btn-xs' if small} js-clickable-nofollow" do
      tag.i(class: 'fa fa-download') + ' Get .csv'
    end
  end

  def link_to_trunk(tr)
    link_to tr.name, trunk_path(tr), class: 'js-clickable-nofollow' if tr
  end

  def link_to_trunk_group(tg)
    link_to tg.name, trunk_group_path(tg), class: 'js-clickable-nofollow' if tg
  end

  def sort_link(column, title = column.titleize)
    filters        = request.query_parameters
    sort_direction = sorting_params.find { |pair| pair[column] }&.values&.first
    if sort_direction.in? [:asc, :desc]
      # There's sorting by this column applied
      if sort_direction == :asc
        icon_class    = 'fa fa-sort-asc'
        new_direction = :desc
      else
        icon_class    = 'fa fa-sort-desc'
        new_direction = :asc
      end
    else
      # No sorting by this column is applied
      icon_class    = 'fa fa-sort'
      new_direction = :asc
    end
    link_to filters.merge(sort: column, direction: new_direction) do
      tag.span(title) + ' ' + tag.i(class: icon_class)
    end
  end

  def keep_sorting_params
    hidden_field_tag('sort', params[:sort]) +
    hidden_field_tag('direction', params[:direction])
  end

  def full_name(resource)
    "#{resource.first_name} #{resource.last_name}"
  end
end
