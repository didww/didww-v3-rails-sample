class FormattedDuration
  PARTS_NAMES = (
    ActiveSupport::Duration::ISO8601Parser::DATE_COMPONENTS +
      ActiveSupport::Duration::ISO8601Parser::TIME_COMPONENTS
  ).freeze

  def self.parse(duration)
    new(duration).parse
  end

  def initialize(duration)
    @duration = duration
  end

  def parse
    return if @duration < 0
    parts = ActiveSupport::Duration.build(@duration).parts
    PARTS_NAMES.map { |name| parts.key?(name) ? "#{parts[name].to_i} #{name}" : nil }.reject(&:nil?).join(', ')
  end
end
