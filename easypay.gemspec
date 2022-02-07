# -*- encoding: utf-8 -*-
#$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "easypay"
  s.version     = "1.2.3"
  s.authors     = ["Guilherme Pereira"]
  s.email       = ["guiferrpereira@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{This Gem provides connection to easypay API}
  s.description = %q{This Gem provides connection to easypay API, that allow you to use credit cards and MB references to Portugal}
  s.extra_rdoc_files = ["README.md"]

  s.rubyforge_project = "easypay"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
