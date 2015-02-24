source "http://rubygems.org"

# Specify your gem's dependencies in lucene_query_parser.gemspec
gemspec

group "development" do
  gem "guard"
  gem "guard-rspec"

  if RUBY_PLATFORM =~ /darwin/
    gem "rb-fsevent"
    gem "growl_notify"
  end
end
