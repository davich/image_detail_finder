require_relative 'image_detail_finder'

class Redbubble
  def initialize(page_url)
    @page_url = page_url
  end

  def cropped_url
    `curl -o input.jpg #{image_url_without_pad}`
    idf = ImageDetailFinder.new('input.jpg')
    # idf.write_out_with_bounding_box('output.jpg')

    "#{prefix}/flat,#{size_str(idf)},075,f-c,#{crop_str(idf)}#{suffix}"
  end

  private

  attr_reader :page_url

  def size_str(idf)
    idf.image_dimensions.map {|i| i * multiplier(idf) }.map(&:to_i).join('x')
  end

  def crop_str(idf)
    idf.rectangle_coords_for_crop.map {|i| i * multiplier(idf) }.map(&:to_i).join(',')
  end

  def multiplier(idf)
    1000.0 / idf.image_dimensions.max
  end

  def image_url_without_pad
    "#{prefix}/flat,550x550,075,f#{suffix}"
  end

  def prefix
    image_url[/(^.*image.\d+.\d+)\//]
  end

  def suffix
    image_url[/((\.u\d+)?\.(jpe?g|png))$/]
  end

  def image_url
    @image_url ||= `curl #{page_url}`[/<meta name=\"sailthru.image.designfull\" content=\"([^\"]*)\"/, 1]
  end
end

cropped_url = Redbubble.new(ARGV[0]).cropped_url
`open #{cropped_url}`
