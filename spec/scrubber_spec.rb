require "spec_helper"

RSpec.describe Carwash::Scrubber do
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

      scrubber = Carwash::Scrubber.new

      output = StringIO.new
      scrubber.scrub_stream(input, output)

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
    let(:scrubber) { Carwash::Scrubber.new }

    it "obscures values in Dockerfile `ENV foo bar` format" do
      expect(scrubber.scrub("ENV password something"))
        .to eq "ENV password ********"
    end

    it "obscures values in Dockerfile `ENV foo=bar` format" do
      expect(scrubber.scrub("ENV password=secret"))
        .to eq "ENV password=********"
    end

    it "obscures values in a multiline Dockerfile `ENV` statement" do
      input = <<~EOS
      ENV password=something
          secret_key=another_thing
          api_token=dontsharethis
          other_config=not-secret
      EOS

      result = input.split("\n").map { |line|
        scrubber.scrub(line)
      }.join("\n").strip

      expect(result).to eq <<~EOS
      ENV password=********
          secret_key=********
          api_token=********
          other_config=not-secret
      EOS
      .strip
    end
  end
end
