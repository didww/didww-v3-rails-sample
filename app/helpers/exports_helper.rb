# frozen_string_literal: true
module ExportsHelper
  def period_for_cdr(cdr)
    year  = cdr.filters.year || Time.now.year
    month = cdr.filters.month || Time.now.month
    "#{year} / #{month.to_s.rjust(2, '0')}"
  end

  def voice_out_trunk

  end
end
