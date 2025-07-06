require "spec"

require "../src/track/audio"

describe Array do
  it "#duration_from_ms" do
    ai = AudioInfo.new
    ai.duration_from_ms=1500
    ai.ms.should eq 1500
  end
  it "#set_duration_from_str" do
    ai = AudioInfo.new
    ai.duration_from_str("str").should be_false
  end
  it "#empty?" do
    ai = AudioInfo.new
    ai.empty?.should be_true
    ai.channels = 2
    ai.empty?.should be_false
  end
end
