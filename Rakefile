desc "Pull down mappings, build redirections and run unit tests"
task :default => :prerequisites do
  sh "./jenkins.sh"
end

task :prerequisites => [:required_perl_modules, :required_binaries]

task :required_binaries do
  %w{perl prove}.each do |executable|
    Kernel.system("which #{executable} > /dev/null") || raise("#{executable} executable not found on #{ENV['PATH']}")
  end
end

task :required_perl_modules do
  %w{Text::CSV}.each do |module_name|
    Kernel.system("perl -m#{module_name} -eprint > /dev/null 2>&1") || raise("Required perl module '#{module_name}' not found")
  end
end