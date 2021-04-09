#!/usr/bin/env ruby

require_relative './lib/extra_file_utils.rb'
require_relative './lib/gdtf.rb'

analyzed_directory = ARGV[0]

if analyzed_directory.to_s.empty?
  puts "Usage: stats.rb </path/to/GDTF/manufacturer/folders>"
  exit 1
end

total_gobo_count = 0
fixtures_with_gobos_count = 0
fixtures_with_models = 0
boilerplate_fixture_count = 0

ExtraFileUtils.for_each_gdtf_directory(analyzed_directory) do |gdtf_path|
  gdtf = GDTF.new(gdtf_path)

  wheels_count = gdtf.num_wheels
  if wheels_count > 0
    total_gobo_count += wheels_count
    fixtures_with_gobos_count += 1
  end

  if gdtf.has_models?
    fixtures_with_models += 1
  end

  if gdtf.has_channels?
    boilerplate_fixture_count += 1
  end
end

puts "fixtures with gobos: #{fixtures_with_gobos_count}"
puts "total gobo files: #{total_gobo_count}"
puts "fixtures with models: #{fixtures_with_models}"
puts "boilerplate fixtures: #{boilerplate_fixture_count}"
