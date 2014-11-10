module Redirector
  def self.path(relative)
    File.expand_path(File.join(File.dirname(__FILE__), '..', relative))
  end
end

require 'redirector/organisations'
require 'redirector/site'
