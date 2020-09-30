Gem::Specification.new do |s|
  s.name        = 'molasses'
  s.version     = '0.1.0'
  s.licenses    = ['MIT']
  s.summary     = "Ruby SDK for Molasses. Feature flags as a service"
  s.description = "Ruby SDK for Molasses. Feature flags as a service"
  s.authors     = ["James Hrisho"]
  s.email       = 'james.hrisho@gmail.com'
  s.files       = ["lib/example.rb"]
  s.homepage    = 'https://molasses.app'
  s.add_dependency 'faraday', '>= 1.0'

  s.files = Dir['CHANGELOG.md', '{lib,spec}/**/*', 'LICENSE.md', 'Rakefile', 'README.md']
  s.metadata    = { "source_code_uri" => "https://github.com/molassesapp/molasses-ruby" }
end