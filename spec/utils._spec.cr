require "spec"

require "../src/utils"

describe "Utils functions" do
  it "levenshtein_distance" do
    levenshtein_distance("кот", "код").should eq 1
  end
end
