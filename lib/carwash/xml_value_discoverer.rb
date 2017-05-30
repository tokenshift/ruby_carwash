require 'rexml/document'

# Discovers values in the format <key>value, which may occur in XML/HTML.
# XML attribute values are already handled using the basic ValueDiscoverer,
# since they match the `key="value"` format that it handles.
class Carwash::XmlValueDiscoverer < Struct.new(:key)
  def discover(line)
    line.scan(%r{[^/]#{key}>(?:([^<]+)|<!\[CDATA\[(.*?)\]\])}i)
      .map(&:compact)
      .flatten(1)
      .map { |val| unescape_value(val) }
  end

  def unescape_value(value)
    REXML::Text::unnormalize(value)
  end
end
