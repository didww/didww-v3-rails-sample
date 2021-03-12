# frozen_string_literal: true
module WithBatchActions
  extend ActiveSupport::Concern

  included do
    class_attribute :_batch_actions, instance_writer: false, default: {}
    helper_method :batch_action_names
  end

  class_methods do
    def batch_action(name, options = {}, &block)
      name = name.to_s
      raise ArgumentError "batch action #{name} already exist" if _batch_actions.key?(name)

      options[:title] ||= name.titleize
      options[:block] = block if block_given?
      _batch_actions[name] = options
    end

    def remove_batch_action(name)
      name = name.to_s
      raise ArgumentError "batch action #{name} does not exist" unless _batch_actions.key?(name)

      _batch_actions.delete(name)
    end

    def inherited(subclass)
      super
      subclass._batch_actions = _batch_actions.dup
    end
  end

  def batch_action_content
    name = params[:name]
    return unless validate_batch_action(name)

    current_options = _batch_actions.fetch(name)
    partial = current_options.fetch(:partial) { "#{params[:controller]}/batch_actions/#{name}" }
    render partial: partial, layout: false, locals: { record_ids: params[:record_ids] }
  end

  def batch_action
    name = params[:name]
    return unless validate_batch_action(name)

    current_options = _batch_actions.fetch(name)
    block = current_options[:block]
    if block
      instance_exec(&block)
    else
      action = current_options.fetch(:action) { "batch_action_#{name}" }
      send(action)
    end
  end

  private

  def validate_batch_action(name)
    if _batch_actions.key?(name)
      true
    else
      render status: 404, json: { error: "Batch Action #{name} Not Found" }
      false
    end
  end

  def batch_action_names
    _batch_actions.map { |name, opts| [name, opts.fetch(:title)] }
  end
end
