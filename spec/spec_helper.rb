require "lucene_query_parser"

require "parslet/rig/rspec"

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.expect_with(:rspec) { |c| c.syntax = :should }
end
