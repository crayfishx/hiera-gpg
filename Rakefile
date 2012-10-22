require 'rubygems'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |gem|
    gem.name = "hiera-gpg"
    gem.version = "1.1.0"
    gem.summary = "GPG backend for Hiera"
    gem.email = "craig@craigdunn.org"
    gem.author = "Craig Dunn"
    gem.homepage = "http://github.com/crayfishx/hiera-gpg"
    gem.description = "Hiera backend for storing secret data and decrypting with GPG"
    gem.require_path = "lib"
    gem.files = FileList["lib/**/*"].to_a
    gem.add_dependency('hiera', '>=0.2.0')
    gem.add_dependency('gpgme', '>=2.0.0')
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end

