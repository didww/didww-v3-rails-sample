# frozen_string_literal: true
class ResourceCollectionDecorator < Draper::CollectionDecorator
  RESULT_SET_METHODS = [
    :errors,
    :record_class,
    :meta,
    :pages,
    :uri,
    :links,
    :implementation,
    :relationships,
    :included,
    :has_errors?
  ].freeze

  delegate(*RESULT_SET_METHODS, to: :object)
end
