# frozen_string_literal: true
class VoiceOutTrunkDecorator < ResourceDecorator
  def display_allowed_sip_ips
    model.allowed_sip_ips.map(&:to_s).join(', ')
  end

  def display_allowed_rtp_ips
    model.allowed_rtp_ips.map(&:to_s).join(', ') if model.allowed_rtp_ips
  end

  def spent_amount
    model.meta[:spent_amount]
  end

  def status_badge
    type = model.status == DIDWW::Resource::VoiceOutTrunk::STATUS_ACTIVE ? :success : :default
    h.badge_tag(title: model.status, type: type)
  end

  def threshold_reached_badge
    h.boolean_badge_tag(model.threshold_reached, true_type: :danger, false_type: :default)
  end
end
