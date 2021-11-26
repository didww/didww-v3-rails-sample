# frozen_string_literal: true
class VoiceOutTrunkDecorator < ResourceDecorator
  def display_allowed_sip_ips
    model.allowed_sip_ips.map(&:to_s).join(', ')
  end

  def display_allowed_rtp_ips
    model.allowed_rtp_ips.map(&:to_s).join(', ')
  end

  def spent_amount
    model.meta[:spent_amount]
  end
end
