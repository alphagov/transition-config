require 'transition-config'

namespace :validate do
  desc 'Run all validation checks'
  task :all do
    Rake::Task['whitehall:slug_check'].invoke
    Rake::Task['hosts:validate'].invoke
    Rake::Task['sites:validate'].invoke
    Rake::Task['sites:check_yaml_files_not_in_unexpected_locations'].invoke
  end
end
