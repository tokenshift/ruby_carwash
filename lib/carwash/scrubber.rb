require "set"

# Keeps track of values known/suspected to be sensitive (passwords, etc) and
# obscures them in lines of text.
class Carwash::Scrubber
  DEFAULT_OBSCURE_WITH   = "********"
  DEFAULT_SENSITIVE_KEYS = %w[key password token]

  attr_accessor :obscure_with
  attr_reader :sensitive_keys

  def initialize(sensitive_keys: DEFAULT_SENSITIVE_KEYS,
                 obscure_with: DEFAULT_OBSCURE_WITH,
                 check_for_rails: true,
                 check_env_vars: true)
    @obscure_with = obscure_with

    @sensitive_keys = Set.new(sensitive_keys.map(&:to_s).map(&:downcase))
    @sensitive_vals = Set.new

    add_rails_secrets if check_for_rails && defined? Rails

    add_env_values if check_env_vars
  end

  # Adds keys and values from Rails' secrets.yml and filter_parameters.
  def add_rails_secrets
    @sensitive_keys += Rails.configuration.filter_parameters.map(&:to_s).map(&:downcase).compact
    @sensitive_keys += Rails.application.secrets.keys.map(&:to_s).map(&:downcase).compact

    Rails.application.secrets.values.each do |secret|
      add_sensitive_value(secret)
    end
  end

  # Adds sensitive values (as determined by the existing set of sensitive keys)
  # found in environment variables.
  def add_env_values
    ENV.each do |env_key, env_val|
      @sensitive_keys.each do |key|
        if env_key =~ %r{[_-]?#{key}}i
          add_sensitive_value(env_val)
        end
      end
    end
  end

  # Adds a string to the list of known sensitive values. Useful for adding
  # passwords/keys that are known at startup time, without relying on value
  # discovery.
  def add_sensitive_value(value)
    value = value.to_s.downcase.strip
    if !value.empty?
      @sensitive_vals.add(value.to_s.downcase)
    end
  end

  # Adds a string to the list of sensitive keys, to be used when learning new
  # values to be obscured.
  def add_sensitive_key(key)
    @sensitive_keys.add(key.to_s.downcase)
  end

  # Look for sensitive keys in a line of text and "learn" the associated
  # potentially sensitive values. E.g. if "PASSWORD" is set as a sensitive key,
  # the line "PASSWORD=super_secret" will add "super_secret" to the list of
  # known sensitive values.
  def discover_sensitive_values(line)
    value_discoverers.each do |discoverer|
      discoverer.discover(line).each do |value|
        add_sensitive_value(value)
      end
    end
  end

  # Go through a line of text and obscure any potentially sensitive values
  # detected. Returns the line with replacements made.
  #
  # NOTE: Does *not* discover/learn values from the line; use `#scrub` to both
  # discover and obscure based on the line.
  def obscure_sensitive_values(line, obscure_with: self.obscure_with)
    line = line.clone
    obscure_sensitive_values!(line, obscure_with: obscure_with)
    line
  end

  # Go through a line of text and obscure any potentially sensitive values
  # detected. Makes replacements in place.
  def obscure_sensitive_values!(line, obscure_with: self.obscure_with)
    @sensitive_vals.each do |val|
      val=CGI::escape(val)
      line.gsub!(/#{val}/i, obscure_with)
    end
  end

  # Scans the line to try and discover potentially sensitive values, then
  # obscures all sensitive values known. Returns the line with replacements
  # made.
  def scrub(line, obscure_with: self.obscure_with)
    discover_sensitive_values(line)
    obscure_sensitive_values(line, obscure_with: obscure_with)
  end

  # Scans the line to try and discover potentially sensitive values, then
  # obscures all sensitive values known. Makes replacements in place.
  def scrub!(line, obscure_with: self.obscure_with)
    discover_sensitive_values(line)
    obscure_sensitive_values!(line, obscure_with: obscure_with)
  end

  # Learns from and scrubs each line of an input stream, writing the result to
  # the given output stream.
  def scrub_stream(input, output)
    input.each_line do |line|
      output.puts(scrub(line))
    end
  end

  private

  # Provides a list of value discovers to use when attempting to learn
  # sensitive values from input text.
  def value_discoverers
    Enumerator.new do |y|
      @sensitive_keys.each do |key|
        y << Carwash::ValueDiscoverer.new(key)
        y << Carwash::XmlValueDiscoverer.new(key)
      end

      y << Carwash::UriPasswordDiscoverer.new
    end
  end
end
