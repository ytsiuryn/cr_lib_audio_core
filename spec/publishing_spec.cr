require "spec"
require "../src/core/release/publishing"

describe Issue do
  it "#compare" do
    p = Issue.new
    p.add_label(Label.new("Analog Audio"))
    p.compare(Issue.new).should eq 0.0
    p2 = Issue.new
    p2.add_label(Label.new("Analog Audio"))
    p.compare(p2).should eq 0.99
    p.labels[0].catnos << "12345"
    p2.labels[0].catnos << "12345"
    p.compare(p2).should eq 1.0
  end

  it "#add_label" do
    p = Issue.new
    p.add_label(Label.new("test"))
    l2 = Label.new("test")
    l2.ids[OnlineDB::DISCOGS] = "12345"
    l2.notes << "test notes"
    p.add_label(l2)
    p.labels.size.should eq 1
    p.labels[0].ids.size.should eq 1
    p.labels[0].notes.size.should eq 1
  end

  it "all catnos" do
    p = Issue.new
    l1 = Label.new("name1")
    l1.catnos << "11"
    l1.catnos << "111"
    l2 = Label.new("name1")
    l2.catnos << "22"
    l2.catnos << "222"
    p.add_label(l1)
    p.add_label(l2)
    p.catnos.size.should eq 4
  end

  it "#has_label" do
    p = Issue.new
    p.has_label("test").should_not be_true
    p.add_label(Label.new("test"))
    p.has_label("test").should be_true
  end

  it "#empty?" do
    p = Issue.new
    p.empty?.should be_true
    p.add_label(Label.new("test"))
    p.empty?.should_not be_true
  end
end
