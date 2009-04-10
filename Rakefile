require 'rubygems'
require 'rake/gempackagetask'

PLUGIN = "rdb4o"
NAME = "rdb4o"
VERSION = "0.0.1"
AUTHOR = "Kacper Cieśla"
EMAIL = "kacper.ciesla@gmail.com"
HOMEPAGE = "http://"
SUMMARY = "Small library for accessing db4o from jruby"

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.version = VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  #s.extra_rdoc_files = ["README", "LICENSE", 'TODO']
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE  
  s.require_path = 'lib'
  s.autorequire = PLUGIN
  # %w(LICENSE README Rakefile TODO) + 
  s.files = %w(Rakefile) + Dir.glob("{lib}/**/**/**/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task :install => [:package] do
  sh %{sudo gem install pkg/#{NAME}-#{VERSION}}
end

namespace :jruby do

  desc "Run :package and install the resulting .gem with jruby"
  task :install => :package do
    sh %{#{SUDO} jruby -S gem install pkg/#{NAME}-#{VERSION}.gem --no-rdoc --no-ri}
  end
  
end