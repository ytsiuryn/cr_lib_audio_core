require "spec"

require "../src/actor"

describe ActorIDs do
end

describe Roles do
  it "change role collection" do
    ars = Roles.new
    ars.add("John Doe", "singer")
    ars.size.should eq 1
    ars.has_key?("John Doe").should be_true
    ars["John Doe"].size.should eq 1
    ars.add("John Doe", "lyricist")
    ars.size.should eq 1
    ars["John Doe"].size.should eq 2
    ars.delete("John Doe", "singer")
    ars.size.should eq 1
    ars["John Doe"].size.should eq 1
    ars.delete("John Doe", "lyricist")
    ars.has_key?("John Doe").should be_false
  end
end
