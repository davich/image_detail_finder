require_relative 'image_detail_finder'
require_relative 'imagehaus'

class Service
  def initialize(image_id, work_id)
    @image_id = image_id
    @work_id = work_id
  end

  def run
    puts small_url
    t = Thread.new do
      `curl -o input.png #{small_url}`
      idf = ImageDetailFinder.new('input.png')
      idf.rectangle_coords_for_crop
    end

    puts "QQQ #{Imagehaus.image_url(@image_id)}"
    `curl -o original.png #{Imagehaus.image_url(@image_id)}`
    dims = image_dimensions('original.png')
    t.join
    rect = "%dx%d+%d+%d" % t.value
    `convert -crop #{rect} original.png cropped.png`
    puts "done"
  end

  def image_dimensions(filename)
    @image_dimensions ||= `convert #{filename} -format "%wx%h" info:`.split('x').map(&:to_i)
  end

  def small_url
    "http://ih1.redbubble-staging.net/image.#{@image_id}.#{@work_id}/flat,550x550,075,f.jpg"
  end
end

Service.new(7188853, '0690').run
