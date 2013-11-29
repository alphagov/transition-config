require 'redirector/organisations'
require 'redirector/site'
require 'redirector/mappings'
require 'redirector/tests'

module Redirector
  def self.path(relative)
    File.expand_path(File.join(File.dirname(__FILE__), '..', relative))
  end
end
