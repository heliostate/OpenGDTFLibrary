#!/usr/bin/env ruby

require 'zip'
require 'fileutils'

gdtf_directory = ARGV[0]
output_directory = ARGV[1]  
if gdtf_directory.to_s.empty?
  puts "Usage: pack_gdtfs.rb </path/to/GDTF/manufacturer/folders> </output/path>"
  exit 1
end

class ZipFileGenerator
  # Initialize with the directory to zip and the location of the output archive.
  def initialize(input_dir, output_file)
    @input_dir = input_dir
    @output_file = output_file
  end

  # Zip the input directory.
  def write
    entries = Dir.entries(@input_dir) - %w[. ..]

    ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
      write_entries entries, '', zipfile
    end
  end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, zipfile)
    entries.each do |e|
      zipfile_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zipfile_path)

      if File.directory? disk_file_path
        recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      else
        put_into_archive(disk_file_path, zipfile, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
    zipfile.mkdir zipfile_path
    subdir = Dir.entries(disk_file_path) - %w[. ..]
    write_entries subdir, zipfile_path, zipfile
  end

  def put_into_archive(disk_file_path, zipfile, zipfile_path)
    zipfile.add(zipfile_path, disk_file_path)
  end
end

Dir.foreach(gdtf_directory) do |manufacturer_directory|
  next if manufacturer_directory == '.' or manufacturer_directory == '..'
  manufacturer_path = "#{gdtf_directory}/#{manufacturer_directory}"

  Dir.foreach(manufacturer_path) do |packable_folder|
    next if packable_folder == '.' or packable_folder == '..'

    output_dir = "#{output_directory}/#{manufacturer_directory}"
    FileUtils.mkdir_p output_dir

    output_file = "#{output_dir}/#{packable_folder}.gdtf"
    puts output_file

    zf = ZipFileGenerator.new("#{manufacturer_path}/#{packable_folder}", output_file)
    zf.write()
  end
end
