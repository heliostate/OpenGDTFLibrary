require 'fileutils'

module ExtraFileUtils
  def self.for_each_gdtf_directory manufacturers_list_dir, &block
    Dir.foreach(manufacturers_list_dir) do |manufacturer_directory|
      next if manufacturer_directory == '.' or manufacturer_directory == '..'
      manufacturer_path = "#{manufacturers_list_dir}#{manufacturer_directory}"

      Dir.foreach(manufacturer_path) do |gdtf_folder|
        next if gdtf_folder == '.' or gdtf_folder == '..'

        yield "#{manufacturer_path}/#{gdtf_folder}"
      end
    end
  end
end