# frozen_string_literal: true
class DidDecorator < ResourceDecorator
  delegate :requirement, to: :did_group

  def requirement_link
    return if requirement.nil?

    h.link_to 'Requirement', h.requirement_path(requirement.id)
  end
end
