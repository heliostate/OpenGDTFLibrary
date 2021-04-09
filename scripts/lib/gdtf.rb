class GDTF
  require 'nokogiri'

  def initialize(input_path)
    @input_path = input_path
    @packed = !File.directory?(@input_path)

    if !@packed
      # TODO: write unpack function that will fill in gdtf contents for packed gdtfs
      @unpacked_path = @input_path
      @gdtf_contents = Dir.glob("#{@input_path}/*")
      @gdtf_contents_names = @gdtf_contents.flat_map{ |path| path.split('/').last }
    end
  end

  def packed?
    @packed
  end

  def unpacked?
    !@packed
  end

  def num_wheels
    raise "Please unpack gdtf before checking wheels" if @packed

    if @gdtf_contents_names.include? "wheels"
      Dir.glob("#{@unpacked_path}/wheels/*").size
    else
      0
    end
  end

  def has_models?
    raise "Please unpack gdtf before checking models" if @packed

    @gdtf_contents_names.include? "models"
  end

  def has_channels?
    raise "Please unpack gdtf before checking channels" if @packed

    @description_xml ||= File.open("#{@input_path}/description.xml").read
    parsed_description = Nokogiri::XML(@description_xml)

    # nokogiri finds several XML::Text nodes with newlines as the contained text, so we seslect only elements
    modes = parsed_description.xpath('//GDTF/FixtureType/DMXModes').children.select{ |mode| mode.is_a? Nokogiri::XML::Element}
    if modes.length > 1
      true
    elsif modes.length == 0
      false
    else
      mode = modes.first
      channels =  mode.at('DMXChannels').children.select { |mode| mode.is_a? Nokogiri::XML::Element }
      !((mode.attributes["Name"].value == "DMX Mode") && (channels.length == 1))
    end
  end

end