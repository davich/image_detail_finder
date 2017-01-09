require_relative 'image_detail_finder'

page_url = ARGV[0]
html = `curl #{page_url}`
puts 'curled'
image_url = html[/<meta name=\"sailthru.image.designfull\" content=\"([^\"]*)\"/, 1]
image_url_without_pad = image_url.gsub(/\-pad,[^\.\-]*/, '')
puts image_url_without_pad
`curl -o input.jpg #{image_url_without_pad}`

idf = ImageDetailFinder.new('input.jpg')
# idf.write_out_with_bounding_box('output.jpg')

MULTIPLIER = 5
size_str = idf.image_dimensions.map {|i| i * MULTIPLIER }.join('x')
crop_str = idf.rectangle_coords_for_crop.map {|i| i * MULTIPLIER }.join(',')
puts image_url_without_pad.gsub(/flat,\d+x\d+,/, "flat,#{size_str},").gsub(/((\.u\d+)?\.(jpg|png))/, "-c,#{crop_str}" + '\0')
