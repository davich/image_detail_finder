require_relative 'image_detail_finder'

page_url = ARGV[0]
html = `curl #{page_url}`
image_url = html[/<meta name=\"sailthru.image.designfull\" content=\"([^\"]*)\"/, 1]
prefix = image_url[/(^.*image.\d+.\d+)\//, 1]
suffix = image_url[/((\.u\d+)?\.(jpeg|jpg|png))$/]



image_url_without_pad = "#{prefix}/flat,550x550,075,t#{suffix}"
puts image_url_without_pad

`curl -o input.jpg #{image_url_without_pad}`

idf = ImageDetailFinder.new('input.jpg')
# idf.write_out_with_bounding_box('output.jpg')

MULTIPLIER = 3
size_str = idf.image_dimensions.map {|i| i * MULTIPLIER }.join('x')
crop_str = idf.rectangle_coords_for_crop.map {|i| i * MULTIPLIER }.join(',')
cropped_url = "#{prefix}/flat,#{size_str},075,t-c,#{crop_str}#{suffix}"
puts cropped_url
`open #{cropped_url}`
