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
      `curl -o #{input_filename} #{small_url}`
      idf = ImageDetailFinder.new(input_filename)
      crop_coords = idf.rectangle_coords_for_crop
      `rm #{input_filename}`
      crop_coords
    end

    `curl -o #{original_filename} "#{Imagehaus.image_url(@image_id)}"`
    dims = image_dimensions(original_filename)

    t.join
    crop_coords = t.value.map {|i| i*dims.max/550 }

    rect = "%dx%d+%d+%d" % crop_coords
    `convert #{original_filename} -crop #{rect} -resize 800x800\\> result.png`
    `rm #{original_filename}`
    puts "done"
  end

  def image_dimensions(filename)
    @image_dimensions ||= `convert #{filename} -format "%wx%h" info:`.split('x').map(&:to_i)
  end

  def small_url
    "http://ih1.redbubble-staging.net/image.#{@image_id}.#{@work_id}/flat,550x550,075,f.png"
  end

  def input_filename
    "#{@image_id}-#{@work_id}-input.#{@format}"
  end

  def original_filename
    "#{@image_id}-#{@work_id}-original.#{@format}"
  end
end

Service.new(7198014, 1623).run
# Service.new(7188853, '0690').run
# Service.new(7414867, 2906).run
