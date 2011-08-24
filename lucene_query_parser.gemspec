# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lucene_query_parser/version"

Gem::Specification.new do |s|
  s.name        = "lucene_query_parser"
  s.version     = LuceneQueryParser::VERSION
  s.authors     = ["Nathan Witmer"]
  s.email       = ["nwitmer@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "lucene_query_parser"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "parslet"
  s.add_development_dependency "rspec", "~> 2.5.0"
end
