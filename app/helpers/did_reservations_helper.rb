# frozen_string_literal: true
module DidReservationsHelper
  def expiration_formatted(expire_at)
    expire_at = expire_at.utc
    now = Time.now.utc
    if expire_at > now
      formatted = FormattedDuration.parse(expire_at - now)
      "#{formatted} left"
    else
      'expired'
    end
  end
end
