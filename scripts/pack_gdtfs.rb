#!/usr/bin/env ruby

require 'zip'
require 'fileutils'

require_relative './lib/zip_file_generator.rb'
require_relative './lib/extra_file_utils.rb'
require_relative './lib/gdtf.rb'

gdtf_directory = ARGV[0]
output_directory = ARGV[1]  
if gdtf_directory.to_s.empty?
  puts "Usage: pack_gdtfs.rb </path/to/GDTF/manufacturer/folders> </output/path>"
  exit 1
end

def contains_channel_information? folder_path
end

# TODO: make stats an injectable addition to this code instead of copy pasta
total_fixtures = 0
total_gobo_count = 0
fixtures_with_gobos_count = 0
fixtures_with_models = 0
fixtures_with_channels = 0

ExtraFileUtils.for_each_gdtf_directory(gdtf_directory) do |packable_folder|
  gdtf_name = packable_folder.split('/').last
  manufacturer_name = packable_folder.split('/')[-2]

  gdtf = GDTF.new(packable_folder)

  output_dir = if gdtf.has_channels?
    fixtures_with_channels += 1
    "#{output_directory}/with_channels/#{manufacturer_name}"
  else
    "#{output_directory}/without_channels/#{manufacturer_name}"
  end

  wheels_count = gdtf.num_wheels
  if wheels_count > 0
    total_gobo_count += wheels_count
    fixtures_with_gobos_count += 1
  end

  if gdtf.has_models?
    fixtures_with_models += 1
  end

  FileUtils.mkdir_p output_dir

  output_file = "#{output_dir}/#{gdtf_name}.gdtf"

  zf = ZipFileGenerator.new(packable_folder, output_file)
  zf.write()
  total_fixtures += 1
end

puts "Packed #{total_fixtures} gdtfs"
puts "fixtures with gobos: #{fixtures_with_gobos_count}"
puts "total gobo files: #{total_gobo_count}"
puts "fixtures with models: #{fixtures_with_models}"
puts "fixtures with channels: #{fixtures_with_channels}"
