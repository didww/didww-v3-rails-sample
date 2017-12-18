module AttributesForSave
  extend ActiveSupport::Concern
  include ApiNestedResources

  # At resource creation, we do not want to send blank ("") parameters
  # to the API. We want to ignore them completely instead.
  #
  # At resource updating, we want to send any blank ("") values as nil.
  # This way we will effectively nullify existing values while leaving null
  # values unchanged.

  def attributes_for_save
    @_attributes_for_save ||=
      resource.persisted? ? attributes_for_update : attributes_for_create
  end

  def resource_params
    raise 'Override me'
  end

  def attributes_for_create
    deep_reject_nil(attributes_for_update)
  end

  def attributes_for_update
    deep_replace_blank_with_nil(resource_params.to_hash.with_indifferent_access)
  end

  private

  def deep_replace_blank_with_nil(attrs)
    attrs.each do |key, val|
      if val.is_a?(Hash)
        deep_replace_blank_with_nil(val)
      else
        attrs[key] = nil if val == ''
      end
    end
  end

  def deep_reject_nil(attrs)
    attrs.each do |k, v|
      if v.is_a?(Hash)
        deep_reject_nil(v)
      else
        attrs.delete(k) if v.nil?
      end
    end
  end
end
