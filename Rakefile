# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("lib", File.dirname(__FILE__)))

require "rake"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "tests/**/*_test.rb"
end

Dir.glob("lib/tasks/**/*.rake").each { |r| import r }

task default: :test
