require "spec"

require "../src/release/disc"

describe DiscFormat do
  it "#has_attr" do
    df = DiscFormat.new
    df.attrs << "test"
    df.has_attr("test").should be_true
  end
  it "#empty?" do
    df = DiscFormat.new
    df.empty?.should be_true
    df.media = Media::CD
    df.empty?.should_not be_true
  end
end

describe Disc do
  it "#compare" do
    d = Disc.new
    d.fmt.media = Media::SACD
    d2 = Disc.new(2)
    d2.fmt.media = Media::LP
    d.compare(d2).should eq 0.0
    d2.num = 1
    d.compare(d2).should eq 0.0
    d2.fmt.media = Media::SACD
    d.compare(d2).should eq 1.0
  end
end

describe Discs do
  it "#<<" do
    # ds = Discs.new
    # ds.add(Disc.new(2))
    # d2 = Disc.new(2)
    # d2.ids[DiscIdType::DISCOGS] = "12345"
    # ds.add(d2)
    ds = Discs.new
    d = Disc.new(1)
    d.fmt.media = Media::LP
    ds << d
    d2 = Disc.new(1)
    d2.fmt.attrs << "gatefold sleeve"
    ds << d2
    ds.size.should eq 1
    ds[0].fmt.media == Media::LP
    ds[0].fmt.attrs.should contain("gatefold sleeve")
  end

  it "discs compare" do
    ds = Discs.new
    ds2 = Discs.new
    ds.compare(ds2).should eq 0.0
    ds << Disc.new
    ds << Disc.new(2)
    ds[0].fmt.media = Media::SACD
    ds[1].fmt.media = Media::SACD
    ds.compare(ds2).should eq 0.0
    ds2 << Disc.new
    ds2 << Disc.new(2)
    ds2[0].fmt.media = Media::SACD
    ds2[1].fmt.media = Media::LP
    ds.compare(ds2).should eq 0.5
    ds2[1].fmt.media = Media::SACD
    ds.compare(ds2).should eq 1.0
  end
end
