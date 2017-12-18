require 'will_paginate'

module ApiNestedResources
  class CollectionError < StandardError
  end

  extend ActiveSupport::Concern

  module CONST
    DEFAULT_PAGE_MAX_SIZE = 500.freeze
    freeze
  end

  included do
    helper_method :resources, :resource, :resource_klass,
                  :api_config, :filters, :per_page_values, :page, :per_page,
                  :current_scope, :current_scope_name, :default_scope_name,
                  :scoped_to?, :default_scope?, :scoped_to_any?,
                  :sorting_params

    before_action :set_per_page
  end

  def initialize_api_config
    {
        scopes: HashWithIndifferentAccess.new,
        resource_type: nil,
        have_filters: true,
        have_sorting: true,
        have_pagination: true,
        decorator_class: nil,
        includes: nil,
        per_page_default: 10,
        per_page_values: [],
        allowed_filters: [],    # drop filters except these
        nullable_filters: []    # also drop empty filters except listed here
    }
  end

  def api_config
    @api_config ||= OpenStruct.new(initialize_api_config)
  end

  def page
    params[:page] || 1
  end

  def per_page
    (params[:per_page] || preserved_per_page || api_config.per_page_default).to_i
  end

  def begin_of_scope_chain
    resource_klass.where({})
  end

  def resource_klass
    "DIDWW::Resource::#{api_config.resource_type.to_s.classify}".safe_constantize
  end

  def scoped_collection
    begin_of_scope_chain
  end

  def filters
    params.fetch(:q, {})
  end

  def allowed_filters
    filters.permit(api_config.allowed_filters)
  end

  def sanitized_filters
    allowed_filters.delete_if do |k, v|
      v.blank? && api_config.nullable_filters.exclude?(k)
    end
  end

  def flattened_filters
    sanitized_filters.tap do |h|
      h.keys.each { |k| h[k] = h[k].join(',') if h[k].is_a? Array }
    end
  end

  def apply_filters(collection, where = nil)
    collection.where(where || flattened_filters )
  end

  def apply_sorting(collection)
    collection.order(*sorting_params)
  end

  def apply_api_pagination(collection)
    collection.paginate(page: page, per_page: per_page)
  end

  def apply_includes(collection, includes = nil)
    collection.includes(includes || api_config.includes)
  end

  def apply_scope(collection)
    scope = current_scope
    return unless scope
    if scope.is_a?(Proc)
      scope.call(collection)
    else
      scope = scope.dup
      includes = scope.delete(:includes)
      apply_includes(collection, includes) if includes
      apply_filters(collection, scope) if scope.any?
    end
  end

  def current_scope
    api_config.scopes[current_scope_name]
  end

  def current_scope_name
    (params[:scope] || default_scope_name).try(:to_sym)
  end

  def default_scope_name
    api_config.scopes.keys.try(:first).try(:to_sym)
  end

  def default_scope?(name)
    default_scope_name == name
  end

  def scoped_to?(scope_name)
    scoped_to_any?(scope_name)
  end

  def scoped_to_any?(*scope_names)
    scope_names.include?(current_scope_name)
  end

  def apply_decoration(collection)
    api_config.decorator_class.decorate_collection(collection)
  end

  def apply_record_decoration(record)
    api_config.decorator_class.decorate(record)
  end

  def apply_view_pagination(collection, total_records)
    WillPaginate::Collection.create(page, per_page, total_records) do |pager|
      pager.replace collection
    end
  end

  def end_of_collection_chain
    collection = scoped_collection
    apply_filters(collection) if api_config.have_filters
    apply_api_pagination(collection) if api_config.have_pagination
    apply_sorting(collection) if api_config.have_sorting
    apply_scope(collection)
    apply_includes(collection) if api_config.includes
    collection
  end

  def find_collection
    collection = end_of_collection_chain.all
    total_records = collection.meta[:total_records]
    handle_errors_api_resource(collection)
    collection = apply_decoration(collection) if api_config.decorator_class
    collection = apply_view_pagination(collection, total_records)
    collection
  end

  def find_resource
    collection = begin_of_scope_chain
    apply_includes(collection) if api_config.includes
    record = find_record(collection)
    record = apply_record_decoration(record) if api_config.decorator_class
    record
  end

  def find_record(collection)
    collection.find(params[:id]).to_a.first
  end

  def default_sorting_column
    :id
  end

  def default_sorting_direction
    :desc
  end

  def default_sorting_params
    [{ default_sorting_column => default_sorting_direction }]
  end

  def sorting_params
    if params[:sort].present?
      direction = params.fetch(:direction, default_sorting_direction).to_sym
      # when sorting on several columns: [{id: :desc}, {name: :asc}]
      # change only first sorting pair
      [{ params.fetch(:sort).to_sym => direction }] + default_sorting_params[1..-1]
    else
      default_sorting_params
    end
  end

  def build_resource
    record = resource_klass.where({}).build
    record = apply_record_decoration(record) if api_config.decorator_class
    record
  end

  def resource
    @resource ||= params[:id] ? find_resource : build_resource
  end

  def reload_resource!
    @resource = find_resource
  end

  def resources
    @resources ||= find_collection
  end

  private

  def set_per_page
    if params[:per_page] && per_page_values.include?(params[:per_page].to_i)
      session['per_page_size'] = {} unless session['per_page_size'].is_a? Hash
      session['per_page_size'][controller_name] = params[:per_page].to_i
    end
  end

  def preserved_per_page
    stored_value = session['per_page_size'][controller_name] rescue nil
    stored_value if per_page_values.include? stored_value
  end

  def per_page_values
    api_config.per_page_values
  end

  def handle_errors_api_resource(collection)
    if collection.errors.any?
      raise CollectionError.new(collection.errors.map(&:detail).to_sentence)
    end
  end
end
