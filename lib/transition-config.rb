module TransitionConfig
  def self.path(relative)
    File.expand_path(File.join(File.dirname(__FILE__), '..', relative))
  end
end

require 'transition-config/organisations'
require 'transition-config/site'
require 'transition-config/hosts'
