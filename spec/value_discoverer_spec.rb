require "spec_helper"

require "json"

RSpec.describe Carwash::ValueDiscoverer do
  let(:discoverer) { Carwash::ValueDiscoverer.new("PASSWORD") }

  describe "#discover" do
    it "finds values in KEY=value format" do
      input = "PASSWORD=super_secret"
      expect(discoverer.discover(input)).to include "super_secret"

      input = "PASSWORD = also_secret"
      expect(discoverer.discover(input)).to include "also_secret"
    end

    it "finds values in KEY='value' format" do
      input = "PASSWORD='testing'"
      expect(discoverer.discover(input)).to include "testing"
    end

    it "finds values in KEY=\"value\" format" do
      input = "PASSWORD=\"testing\""
      expect(discoverer.discover(input)).to include "testing"
    end

    it "finds values in KEY value format" do
      input = "PASSWORD testing"
      expect(discoverer.discover(input)).to include "testing"
    end

    it "finds values in KEY 'value' format" do
      input = "PASSWORD 'testing'"
      expect(discoverer.discover(input)).to include "testing"
    end

    it "finds values in KEY \"value\" format" do
      input = "PASSWORD 'testing'"
      expect(discoverer.discover(input)).to include "testing"
    end

    it "finds values in KEY: value format" do
      input = "PASSWORD: testing"
      expect(discoverer.discover(input)).to include "testing"

      input = "PASSWORD 'testing'"
      expect(discoverer.discover(input)).to include "testing"

      input = "PASSWORD \"testing\""
      expect(discoverer.discover(input)).to include "testing"
    end

    it "finds values in KEY => value format" do
      input = "PASSWORD => testing"
      expect(discoverer.discover(input)).to include "testing"

      input = "PASSWORD => 'testing'"
      expect(discoverer.discover(input)).to include "testing"

      input = "PASSWORD => \"testing\""
      expect(discoverer.discover(input)).to include "testing"
    end

    it "handles escaped quotes and whitespace in unquoted values" do
      input = "PASSWORD=this\\ \\\"is\\\"\\ \\\'a\\\'\\ test"
      expect(discoverer.discover(input)).to include "this \"is\" 'a' test"
    end

    it "handles escaped quotes in single-quoted values" do
      input = "PASSWORD='testing\\'quotes\\''"
      expect(discoverer.discover(input)).to include "testing'quotes'"
    end

    it "handles escaped quotes in double-quoted values" do
      input = "PASSWORD=\"another\\\"test\\\"\""
      expect(discoverer.discover(input)).to include "another\"test\""
    end

    it "handles whitespace in quoted values" do
      input = "PASSWORD='this is a test'"
      expect(discoverer.discover(input)).to include "this is a test"

      input = "PASSWORD=\"this is a test\""
      expect(discoverer.discover(input)).to include "this is a test"
    end

    it "finds multiple entries in a single line" do
      config = {
        some_password: "testing1",
        another_password: "testing2",
        something_else: "testing3"
      }

      input = "This is a log line: #{config.to_json}"
      expect(discoverer.discover(input)).to include "testing1"
      expect(discoverer.discover(input)).to include "testing2"
      expect(discoverer.discover(input)).not_to include "testing3"
    end

    it "ignores case" do
      input = "PASSWORD=testing"
      expect(discoverer.discover(input)).to include "testing"

      input = "password=testing"
      expect(discoverer.discover(input)).to include "testing"

      input = "pAsSwOrD=testing"
      expect(discoverer.discover(input)).to include "testing"
    end
  end

  describe "#unescape_value" do
    it "unescapes multiple escaped quotes" do
      expect(discoverer.unescape_value("\\\"testing\\\"")).to eq "\"testing\""
    end
  end
end
