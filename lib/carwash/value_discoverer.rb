# Scans for occurrences of a key in a line of text and returns any associated
# values.
#
# Looks for the following patterns of key-value pairs:
# KEY=value
# KEY='value'
# KEY="value"
# KEY value
# KEY 'value'
# KEY "value"
# KEY: value
# KEY => value
class Carwash::ValueDiscoverer < Struct.new(:key)
  def discover(line)
    patterns.flat_map { |pattern|
      line.scan(pattern).map(&:first)
    }.reject(&:nil?).reject(&:empty?).map(&:downcase).map { |val|
      unescape_value(val)
    }
  end

  def patterns
    @patterns ||= [
      %r{#{key}['"]?\s*(?:=>|=|:|\s+)\s*'((?:\\'|[^'])+)'}i,
      %r{#{key}['"]?\s*(?:=>|=|:|\s+)\s*"((?:\\"|[^"])+)"}i,
      %r{#{key}['"]?\s*(?:=>|=|:|\s+)\s*((?:\\\s|\\"|\\'|[^\s'"])+)}i
    ]
  end

  def unescape_value(value)
    value.gsub(/\\(.)/) { $1 }
  end
end
