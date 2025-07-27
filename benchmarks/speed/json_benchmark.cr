require "benchmark"
require "../../src/core/suggestion"

Benchmark.ips do |x|
  x.report("JSON parsing") { Suggestion.from_json(File.read("spec/data/suggestion22.json")) }
end
