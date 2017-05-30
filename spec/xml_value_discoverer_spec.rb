require "spec_helper"

RSpec.describe Carwash::XmlValueDiscoverer do
  let(:discoverer) { Carwash::XmlValueDiscoverer.new("PASSWORD") }

  describe "#discover" do
    it "finds the values of XML elements" do
      input = "<password>secret password</password>"
      expect(discoverer.discover(input)).to include "secret password"
    end

    it "unwraps CDATA values" do
      input = "<password><![CDATA[pa[ss<>wo]rd]]></password>"
      expect(discoverer.discover(input)).to include "pa[ss<>wo]rd"
    end

    it "unescapes XML entity references" do
      input = "<password>&lt;password&gt;</password>"
      expect(discoverer.discover(input)).to include "<password>"
    end
  end
end
