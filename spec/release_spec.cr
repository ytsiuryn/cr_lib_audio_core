require "spec"
require "../src/core/mood"
require "../src/core/picture"
require "../src/core/release"
require "../src/core/release/disc"
require "../src/core/release/publishing"
require "../src/core/track"

describe Release do
  it "#add_actor" do
    r = Release.new
    r.add_actor("John Doe", ext_db: "discogs", id: "12345")
    r.actors.size.should eq 1
    r.add_actor("John Doe", ext_db: "discogs", id: "12345")
    r.actors.size.should eq 1
    r.add_actor("Cpt. Nemo", ext_db: "musicbrainz", id: "guid")
    r.actors.size.should eq 2
  end

  it "#aggregate_actors" do
    r = Release.new
    t1 = Track.new
    t1.composition.add_role("Chopin", "composer")
    t1.record.add_role("Pollini", "performer")
    t2 = Track.new
    t2.composition.add_role("Chopin", "composer")
    t2.record.add_role("Pollini", "performer")
    r.tracks << t1
    r.tracks << t2
    r.aggregate_actors
    r.roles.size.should eq 2
  end

  it "#aggregate_unprocessed" do
    r = Release.new
    t1 = Track.new
    t1.unprocessed["A"] = "AA"
    t1.unprocessed["B"] = "BB"
    t2 = Track.new
    t2.unprocessed["A"] = "AA"
    t2.unprocessed["C"] = "CC"
    r.tracks << t1
    r.tracks << t2
    r.aggregate_unprocessed
    r.unprocessed.size.should eq 1
  end

  it "#charging" do
    r = Release.new
    r.charging.should eq 0.0
    r.add_role("John Doe")   # performer
    r.charging.should eq 0.2 # +0.2
    r.title = "Some Title"
    r.charging.should be_close(0.6, 0.001) # +0.4
    r.tracks << Track.new
    r.charging.should eq 0.8 # +0.2
    r.issues.actual.add_label(Label.new("ARC"))
    r.charging.should eq 0.9 # +0.1
    r.discs << Disc.new(1)
    r.charging.should eq 1.0 # +0.1
  end

  it "#compare" do
    r = Release.new
    r2 = Release.new
    r.compare(r2).should eq 0
    t = Track.new("")
    t.title = "Some Prince will come"
    r.tracks << t
    r.tracks.compare(r2.tracks).should eq 0.0
    t2 = Track.new("")
    t2.title = "Some Prince will come"
    r2.tracks << t2
    r.tracks.compare(r2.tracks).should eq 1.0
    r.issues.actual.add_label_catno("test", "test_catno")
    r.issues.actual.labels.has_label("test").should be_true
    r2.issues.actual.add_label_catno("test", "test_catno")
    r.compare(r2).should eq 1.0
  end

  it "#moods" do
    r = Release.new
    t = Track.new("01")
    t.moods << Mood::CALM
    r.tracks << t
    t2 = Track.new("02")
    t2.moods << Mood::ENERGETIC
    r.tracks << t2
    r.moods.size.should eq 2
  end

  it "#no_mandatory_fields" do
    r = Release.new
    r.no_mandatory_fields.should be_true
    r.title = "test title"
    r.no_mandatory_fields.should be_true
    r.add_role("Nemo", "performer")
    r.no_mandatory_fields.should be_true
    r.tracks << Track.new("01")
    r.no_mandatory_fields.should be_true
    r.issues.actual.labels << Label.new("test")
    r.no_mandatory_fields.should be_false
  end

  it "#optimize_notes" do
    r = Release.new
    t1 = Track.new
    t1.notes << "Notes"
    t2 = Track.new
    t2.notes << "Notes"
    r.tracks << t1
    r.tracks << t2
    r.aggregate_notes
    (r.notes.size == 1 && r.tracks[0].notes.empty? && r.tracks[1].notes.empty?).should be_true
  end

  it "#performers_compare" do
    r = Release.new
    r2 = Release.new
    r.performers_compare(r2).should eq 0.0
    r.add_role("Miles Davis", "performer")
    r2.add_role("Miles Davis", "performer")
    r.performers_compare(r2).should eq 1.0
  end

  it "#picture" do
    r = Release.new
    r.pictures << PictureInAudio.new(PictType::COVER_FRONT)
    r.pictures << PictureInAudio.new(PictType::COVER_BACK)
    r.pictures.size.should eq 2
    r.picture(PictType::COVER_FRONT).should_not be_nil
  end

  it "#picture_types" do
    r = Release.new
    r.picture_types.empty?.should be_true
    r.pictures << PictureInAudio.new(PictType::COVER_FRONT)
    r.picture_types.should contain(PictType::COVER_FRONT)
  end

  it "#pub_ancestor" do
    r = Release.new
    r.issues.ancestor.empty?.should be_true
    r.issues.actual.add_label(Label.new("test"))
    r.issues.ancestor.empty?.should be_true
  end

  it "#pub_compare" do
    r = Release.new
    r.issues.actual.year = 2000
    r.issues.actual.add_label(Label.new("test"))
    r2 = Release.new
    r2.issues.actual.year = 2000
    r2.issues.actual.add_label(Label.new("test"))
    r.pub_compare(r2).should eq 0.99
  end
end
