require_relative 'image_detail_finder'

page_url = ARGV[0]
html = `curl #{page_url}`
puts 'curled'
image_url = html[/<meta name=\"sailthru.image.designfull\" content=\"([^\"]*)\"/, 1]
image_url_without_pad = image_url.gsub(/\-pad,[^\.\-]*/, '')
puts image_url_without_pad
`curl -o input.jpg #{image_url_without_pad}`

ImageDetailFinder.new('input.jpg').write_out_with_bounding_box('output.jpg')
