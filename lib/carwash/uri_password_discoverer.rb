# Scans for occurrences of a password baked into a URI (e.g. a database
# connection string), of the form `scheme://username:PASSWORD@hostname`.
class Carwash::UriPasswordDiscoverer
  URI_PASSWORD_PATTERN= %r{:([0-9a-z_\.\-~%]+?)@}i

  def discover(line)
    line.scan(URI_PASSWORD_PATTERN).map(&:first).map { |password|
      CGI::unescape(password)
    }
  end
end
