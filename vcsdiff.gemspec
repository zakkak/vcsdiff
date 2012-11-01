Gem::Specification.new do |s|
  s.name        = 'vcsdiff'
  s.version     = '0.1.2.alpha'
  s.date        = '2012-10-31'
  s.summary     = 'vcsdiff'
  s.description = 'A ruby gem for inspecting diffs generated by git/svn/hg diff using vim or Kompare'
  s.authors     = ["Foivos Zakkak"]
  s.email       = 'foivos@zakkak.net'
  s.executables = ["vcsdiff"]
  s.homepage    = 'http://rubygems.org/gems/vcsdiff'
  s.license     = 'GPL-3'
  s.requirements << 'patch'
end
