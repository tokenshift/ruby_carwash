require "spec_helper"

RSpec.describe Carwash::Scrubber do
  let(:scrubber) { Carwash::Scrubber.new }

  describe "#scrub_stream" do
    it "learns from and scrubs a stream of text" do
      input = StringIO.new <<-EOS
      This is a test.
      Config:
      PASSWORD=super_secret
      DATABASE_URL=postgres://dbuser:dbpassword@dbhost:5432/testing
      Doing some more stuff
      Just make sure nobody knows the super_secret password!
      Or the dbpassword. That would be bad.
      EOS
      .strip

      scrubber = Carwash::Scrubber.new

      p scrubber.instance_variable_get("@sensitive_vals").to_a

      output = StringIO.new
      scrubber.scrub_stream(input, output)
      p scrubber.instance_variable_get("@sensitive_vals").to_a

      output.rewind
      result = output.read

      expect(result).not_to include "super_secret"
      expect(result).not_to include "dbpassword"
      expect(result).to include "PASSWORD=********"
      expect(result).to include "dbuser:********@dbhost"
      expect(result).to include "the ******** password"
      expect(result).to include "Or the ********."
    end
  end

  describe "#scrub" do
    it "obscures values in Dockerfile `ENV foo bar` format" do
      expect(scrubber.scrub("ENV password something"))
        .to eq "ENV password ********"
    end

    it "obscures values in Dockerfile `ENV foo=bar` format" do
      expect(scrubber.scrub("ENV password=secret"))
        .to eq "ENV password=********"
    end

    it "obscures values in a multiline Dockerfile `ENV` statement" do
      input = <<-EOS
      ENV password=something
          secret_key=another_thing
          api_token=dontsharethis
          other_config=not-secret
      EOS

      result = input.split("\n").map { |line|
        scrubber.scrub(line)
      }.join("\n").strip

      expect(result).to eq <<-EOS
      ENV password=********
          secret_key=********
          api_token=********
          other_config=not-secret
      EOS
      .strip
    end

    it "obscures sensitive values found in env vars by default" do
      ENV["MY_SUPER_SECRET_PASSWORD"] = "this_is_a_test"

      scrubber = Carwash::Scrubber.new

      expect(scrubber.scrub("Logging this_is_a_test"))
        .to eq "Logging ********"
    end
  end
end
