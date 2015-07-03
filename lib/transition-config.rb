module TransitionConfig
  def self.path(relative)
    File.expand_path(File.join(File.dirname(__FILE__), '..', relative))
  end
end

ENV['GOVUK_APP_NAME'] = 'transition-config'

require 'transition-config/organisations'
require 'transition-config/site'
require 'transition-config/hosts'
