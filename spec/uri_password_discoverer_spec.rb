require "spec_helper"

RSpec.describe Carwash::UriPasswordDiscoverer do
  describe "#discover" do
    let(:discoverer) { Carwash::UriPasswordDiscoverer.new }

    it "finds passwords in a DB connection string" do
      input = "postgres://dbuser:dbpassword@dbhost:5432/somedb"
      expect(discoverer.discover(input).to_a).to eq ["dbpassword"]
    end

    it "finds multiple passwords when there are multiple DB connection strings" do
      input = "Here's a log entry: postgres://dbuser:dbpassword@dbhost:5432/somedb and some more text: jdbc:postgresql://foo:bar@db.example.com/fizzbuzz the end."
      expect(discoverer.discover(input)).not_to be_empty
      expect(discoverer.discover(input)).to include "dbpassword"
      expect(discoverer.discover(input)).to include "bar"
    end

    it "finds nothing when there isn't a password in a URI" do
      input = "postgres://db.example.com/database"
      expect(discoverer.discover(input)).to be_empty
    end

    it "unescapes any percent-encoded values in the password" do
      input = "postgres://dbuser:password%21@dbhost:5432/somedb"
      expect(discoverer.discover(input)).to include "password!"
    end
  end
end

