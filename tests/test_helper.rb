# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))

require "bundler/setup"

require "minitest/unit"
require "minitest/autorun"
require "transition-config"

require "webmock/minitest"

Dir[File.expand_path("support/**/*.rb", File.dirname(__FILE__))].each do |f|
  require f
end
