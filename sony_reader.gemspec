# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sony_reader/version"

Gem::Specification.new do |s|
  s.name        = "sony_reader"
  s.version     = SonyReader::VERSION
  s.authors     = ["François Beausoleil"]
  s.email       = ["francois@teksol.info"]
  s.homepage    = ""
  s.summary     = %q{Low-level library to access a Sony PRS-T1 database}
  s.description = %q{Low-level library to access a Sony PRS-T1 database}

  s.rubyforge_project = "sony_reader"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "ruby-debug19"

  s.add_runtime_dependency "sequel"
  s.add_runtime_dependency "sqlite3-ruby"
  s.add_runtime_dependency "escape"
end
