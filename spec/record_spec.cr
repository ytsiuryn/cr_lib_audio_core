require "spec"

require "../src/track/record"

describe Record do
  it "empty?" do
    rec = Record.new
    rec.empty?.should be_true
    rec.add_role("Nemo", "composer")
    rec.empty?.should_not be_true
  end
end
