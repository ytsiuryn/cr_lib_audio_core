require "spec"
require "../src/core/track/composition"

describe Composition do
  it "#empty?" do
    c = Composition.new
    c.empty?.should be_true
    c.add_role("Nemo", "composer")
    c.empty?.should_not be_true
  end
end
