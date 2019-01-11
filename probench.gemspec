lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/probench/version'

Gem::Specification.new do |s|
    s.name          = 'probench'
    s.version       = Probench::VERSION
    s.date          = '2019-01-10'
    s.summary       = "Hardware probing and benchmarking tools for Subutai"
    s.description   = "Hardware probing and benchmarking tools for Subutai. Lightweight and does not force people to wait too long. The generate json file is used to understand the underlying hardware for pricing."
    s.authors       = ["Subutai"]
    s.email         = 'info@subutai.io'
    s.homepage      = "https://github.com/subutai-io/probench"
    s.metadata      = { "source_code_uri" => "https://github.com/subutai-io/probench" }
    s.files         = `git ls-files`.split($\)
    s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
    s.test_files    = s.files.grep(%r{^(test|spec|features)/})
    s.license       = 'Apache-2.0'
    s.test_files    = spec.files.grep(%r{^(test|spec|features)/})

    s.add_development_dependency 'rake'
end