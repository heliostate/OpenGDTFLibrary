#!/usr/bin/env ruby

require 'fileutils'
require 'nokogiri'

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

def boilerplate_fixture?(description_xml)
  parsed_description = Nokogiri::XML(description_xml)

  # nokogiri finds several XML::Text nodes with newlines as the contained text, so we seslect only elements
  modes = parsed_description.xpath('//GDTF/FixtureType/DMXModes').children.select{ |mode| mode.is_a? Nokogiri::XML::Element}
  if modes.length > 1
    false
  elsif modes.length == 0
    true
  else
    mode = modes.first
    channels =  mode.at('DMXChannels').children.select { |mode| mode.is_a? Nokogiri::XML::Element }
    (mode.attributes["Name"].value == "DMX Mode") && (channels.length == 1)
  end
end

total_gobo_count = 0
fixtures_with_gobos_count = 0
fixtures_with_models = 0
boilerplate_fixture_count = 0

for_each_directory do |gdtf_path|
  # puts gdtf_path
  directory_contents = Dir.glob("#{gdtf_path}/*")
  directory_contents_names = directory_contents.flat_map{ |path| path.split('/').last }

  if directory_contents_names.include? "wheels"
    fixture_gobo_count = Dir.glob("#{gdtf_path}/wheels/*").size
    total_gobo_count += fixture_gobo_count
    fixtures_with_gobos_count += 1
  end

  if directory_contents_names.include? "models"
    fixtures_with_models += 1
  end

  fixture_description = File.open("#{gdtf_path}/description.xml").read
  if boilerplate_fixture?(fixture_description)
    boilerplate_fixture_count += 1
  end
end

puts "fixtures with gobos: #{fixtures_with_gobos_count}"
puts "total gobo files: #{total_gobo_count}"
puts "fixtures with models: #{fixtures_with_models}"
puts "boilerplate fixtures: #{boilerplate_fixture_count}"
