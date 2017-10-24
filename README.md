# Carwash

[![CircleCI](https://circleci.com/gh/tokenshift/ruby_carwash.svg?style=svg)](https://circleci.com/gh/tokenshift/ruby_carwash)

Log sanitizer. Obscures passwords and other potentially sensitive values in log
entries.

## Features

* Learns potentially sensitive values by looking for keys like "PASSWORD" and
  "TOKEN", then obscures them wherever they subsequently occur.
* Seeds the list of sensitive values from environment variables and Rails'
  `secrets.yml`.
* Additional sensitive keys and values can be added as needed, if you have
  a known source of secured config values that could potentially end up
  (accidentally) showing up in logs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'carwash'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carwash

## Usage

```ruby
scrubber = Carwash::Scrubber.new

scrubber.add_sensitive_key("CERT")
scrubber.add_sensitive_value("P@ssw0rd")
scrubber.add_sensitive_value("mysecret")

log_lines.each do |line|
  puts scrubber.scrub(line)
end
```

Or to scrub an entire input stream line by line and print it to stdout:

```
scrubber.scrub_stream(input_stream, STDOUT)
```

See `Carwash::Scrubber` for the rest of the API.
