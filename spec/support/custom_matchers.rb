require 'rspec/expectations'

RSpec::Matchers.define :include_hash_matching do |expected|
  match do |array_of_hashes|
    array_of_hashes.any? { |element| element.slice(*expected.keys) == expected }
  end
end