require "log"
require "spec"

require "../src/track"

# TODO: Add tracks' compare test

describe "Track Functions" do
  it "#disc_number_by_track_pos" do
    results = {
      "A1"    => 1,
      "A.1"   => 1,
      "B2"    => 1,
      "C3"    => 2,
      "D4"    => 2,
      "E5"    => 3,
      ""      => 1,
      "1"     => 1,
      "2.10"  => 2,
      "3 - 1" => 3,
      "Б1"    => 1,
    }
    results.each { |k, v| disc_num_by_track_pos(k).should eq v }
  end

  it "#disc_track_num_from_pos" do
    expect_raises(Exception, "Incorrect track position") do
      disc_track_num_from_pos("A1")
    end
  end

  it "#normalize_position" do
    normalize_pos("1").should eq "01"
    normalize_pos("01").should eq "01"
  end
end

describe FileInfo do
  it "#empty?" do
    fi = FileInfo.new
    fi.empty?.should be_true
    fi.fsize = 100500
    fi.empty?.should be_false
  end
end

describe Track do
  it "#duration_from_str" do # TODO: следует перенести в audio_spec.cr
    t = Track.new
    t.ainfo.duration_from_str("2022-11-05").should be_false
    t.ainfo.duration_from_str("00:01:25").should be_true
    t.ainfo.duration.total_seconds.should eq 85
  end

  it "#set_position" do
    t = Track.new
    t.position = "E1"
    disc_num_by_track_pos("E1").should eq 3
    t.position.should eq "E1"
  end
end

describe Tracks do
  it "#compare" do
    ts = Tracks.new
    t = Track.new
    t.title = "Some Prince will come"
    ts << t
    ts2 = Tracks.new
    ts.compare(ts2).should eq 0.0
    t2 = Track.new
    t2.title = "Some Prince will come"
    ts2 << t2
    ts.compare(ts2).should eq 1.0
  end

  it "#last_modified" do
    ts = Tracks.new
    t = Track.new("01")
    t.finfo.mtime = 100500
    ts << t
    t2 = Track.new("02")
    t2.finfo.mtime = 100400
    ts << t2
    ts.last_modified.should eq 100500
  end

  it "#track" do
    ts = Tracks.new
    ts.track("01").should be_nil
    ts << Track.new("01")
    ts.track("01").is_a?(Track).should be_true
  end

  it "#to_range" do
    tracks = Tracks.new
    tracks << Track.new("A1")
    tracks << Track.new("A2")
    tracks << Track.new("A3")
    tracks << Track.new("B1")
    tracks << Track.new("B2")
    tracks << Track.new("B3")
    tracks.to_range("A2 to B2").should eq ["A2", "A3", "B1", "B2"]
    tracks.to_range("A2 to B2 to C1").should eq ["A2 to B2 to C1"]
  end
end
