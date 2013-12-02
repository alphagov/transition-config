$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'bundler/setup'

require 'webmock/minitest'

Dir[File.expand_path('support/**/*.rb', File.dirname(__FILE__))].each do |f|
  require f
end
