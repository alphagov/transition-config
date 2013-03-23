#!/usr/bin/env ruby -w

require 'erb'
require 'yaml'
require 'optparse'
require 'ostruct'

variables = OpenStruct.new

def render_erb(template_name, variables)
  template = File.read(template_name)
  ERB.new(template).result(variables.instance_eval { binding })
end

options = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} [options] <my_template.erb>"

  opts.on("-d varname=value", "Define a variable") do |v|
    varname, value = v.split('=')
    raise "Invalid varname #{varname}" unless varname =~ /\A[a-zA-Z_-][a-zA-Z0-9_-]*\Z/
    variables.send(:"#{varname}=", value)
  end

  opts.on("-y somefile.yml", "Define variables from yml") do |yaml_filename|
    YAML.load_file(yaml_filename).each do |varname, value|
      raise "Invalid varname #{varname}" unless varname =~ /\A[a-zA-Z_-][a-zA-Z0-9_-]*\Z/
      variables.send(:"#{varname}=", value)
    end
  end
end

begin
  options.parse!

  if ARGV.size == 1
    puts render_erb(ARGV[0], variables)
  else
    $stderr.puts options.help
  end
rescue Errno::ENOENT => e
  $stderr.puts "ERROR: #{e}"
  exit(1)
end
