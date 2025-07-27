require "spec"
require "../src/core/id"
require "../src/core/release"
require "../src/core/suggestion"

describe Suggestions do
  it "#shrink_for_bigger_score" do
    sgs = Suggestions.new
    s1 = Suggestion.new
    s1.similarity = 0.6
    sgs << s1
    s2 = Suggestion.new
    s2.similarity = 0.4
    sgs << s2
    s3 = Suggestion.new
    s3.similarity = 0.8
    sgs << s3
    s4 = Suggestion.new
    s4.similarity = 0.5
    sgs << s4
    #   sgs.optimize()
    sgs.shrink_for_bigger_score(0.5)
    sgs.size.should eq 2
  end

  it "#shrink_to_best_resultgs" do
    sgs = Suggestions.new
    sgs.shrink_to_best_results(2)
    sgs.empty?.should be_true
    s1 = Suggestion.new
    s1.similarity = 0.6
    sgs << s1
    s2 = Suggestion.new
    s2.similarity = 0.4
    sgs << s2
    s3 = Suggestion.new
    s3.similarity = 0.8
    sgs << s3
    s4 = Suggestion.new
    s4.similarity = 0.5
    sgs << s4
    sgs = sgs.shrink_to_best_results(2)
    sgs.size.should eq 2
    sgs[0].similarity.should eq 0.8
    sgs[1].similarity.should eq 0.6
  end
end
