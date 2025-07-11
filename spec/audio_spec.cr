require "spec"

require "../src/track/audio"

describe AudioInfo do
  it "#duration_from_str=" do
    expect_raises(Time::Format::Error) do
      AudioInfo.new.duration_from_str = "2022-11-05"
    end
    ai = AudioInfo.new
    ai.duration_from_str = "00:01:25"
    ai.duration.should eq 85_000
  end
  it "#empty?" do
    AudioInfo.new.empty?.should be_true
    AudioInfo.new(channels: 2).empty?.should be_false
  end
end
