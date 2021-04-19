# frozen_string_literal: true

require_relative "lib/ebay/notification_api/verifier/version"

Gem::Specification.new do |spec|
  spec.name = "ebay-notification_api-verifier"
  spec.version = Ebay::NotificationApi::Verifier::VERSION
  spec.authors = ["DmitryTsepelev"]
  spec.email = ["dmitry.a.tsepelev@gmail.com"]

  spec.summary = "The Ruby implementation of eBay Notification API verification"
  spec.description = spec.summary
  spec.homepage = "https://github.com/DmitryTsepelev/ebay-notification_api-verifier"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/DmitryTsepelev/ebay-notification_api-verifier/blob/main/Rakefile/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.3"

  spec.add_dependency "httparty", "~> 0.17"

  spec.add_development_dependency "rspec", "~> 3.1"
end
