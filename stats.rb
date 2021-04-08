#!/usr/bin/env ruby

require 'fileutils'

ANALYZED_DIRECTORY = ARGV[0]

if ANALYZED_DIRECTORY.to_s.empty?
  puts "Usage: stats.rb </path/to/GDTF/manufacturer/folders>"
  exit 1
end

def for_each_directory &block
  Dir.foreach(ANALYZED_DIRECTORY) do |manufacturer_directory|
    next if manufacturer_directory == '.' or manufacturer_directory == '..'
    manufacturer_path = "#{ANALYZED_DIRECTORY}#{manufacturer_directory}"

    Dir.foreach(manufacturer_path) do |gdtf_folder|
      next if gdtf_folder == '.' or gdtf_folder == '..'

      yield "#{manufacturer_path}/#{gdtf_folder}"
    end
  end
end

for_each_directory do |gdtf_path|
  # puts gdtf_path
  puts Dir.glob("#{gdtf_path}/*").inspect
end
