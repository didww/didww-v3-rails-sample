module CdrExportsHelper
  def period_for_cdr(cdr)
    year  = cdr.year || Time.now.year
    month = cdr.month || Time.now.month
    "#{year} / #{month.to_s.rjust(2, '0')}"
  end
end
