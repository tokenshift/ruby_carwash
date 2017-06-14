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
  ESCAPE_CHARACTERS = {
    "\\0" => "\0",
    "\\a" => "\a",
    "\\b" => "\b",
    "\\f" => "\f",
    "\\n" => "\n",
    "\\r" => "\r",
    "\\t" => "\t",
    "\\v" => "\v",
  }

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
    value.gsub(/\\(.)/) { |match|
      ESCAPE_CHARACTERS.fetch(match, $1)
    }
  end
end
