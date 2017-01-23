require_relative 'image_detail_finder'
require_relative 'imagehaus'

class Service
  def initialize(image_id, work_id, format='png')
    @image_id = image_id
    @work_id = work_id
    @format = format
  end

  def run
    t = Thread.new do
      `curl -o input.png #{small_url}`
      idf = ImageDetailFinder.new('input.png')
      crop_coords = idf.rectangle_coords_for_crop
    end

    `curl -o original.png "#{Imagehaus.image_url(@image_id)}"`
    dims = image_dimensions('original.png')

    t.join
    crop_coords = t.value.map {|i| i*dims.max/550 }

    rect = "%dx%d+%d+%d" % crop_coords
    `convert -crop #{rect} original.png cropped.png`
    `convert cropped.png -resize 800x800\\> cropped_resized.png`
    puts "done"
  end

  def image_dimensions(filename)
    @image_dimensions ||= `convert #{filename} -format "%wx%h" info:`.split('x').map(&:to_i)
  end

  def small_url
    "http://ih1.redbubble-staging.net/image.#{@image_id}.#{@work_id}/flat,550x550,075,f.png"
  end
end

Service.new(7188853, '0690').run
# Service.new(7414867, 2906).run
