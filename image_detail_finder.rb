class ImageDetailFinder
  def initialize(filename)
    @filename = filename
  end

  def write_out_with_bounding_box(output_filename="out-#{filename}")
    rect = "%d,%d %d,%d" % rectangle_coords
    `convert #{filename} -stroke red -strokewidth 2 -fill none -draw "rectangle #{rect} " #{output_filename}`
  end

  def write_out_cropped_image(output_filename="cropped_#{filename}")
    rect = "%dx%d+%d+%d" % [square_size, square_size, square_top_left[0], square_top_left[1]]
    `convert -crop #{rect} #{filename} #{output_filename}`
  end

  def rectangle_coords_for_crop
    [
      square_top_left[0],
      square_top_left[1],
      square_size,
      square_size
    ]
  end

  def rectangle_coords
    [
      square_top_left[0],
      square_top_left[1],
      square_top_left[0] + square_size,
      square_top_left[1] + square_size,
    ]
  end

  def image_dimensions
    @image_dimensions ||= `convert #{filename} -format "%wx%h" info:`.split('x').map(&:to_i)
  end

  private

  attr_reader :filename

  def square_top_left
    @square_top_left ||= begin
      point_coords = detailed_pixel_coords
      half_square = square_size / 2
      [
        clip(point_coords[0] - half_square, image_dimensions[0] - square_size),
        clip(point_coords[1] - half_square, image_dimensions[1] - square_size),
      ]
    end
  end

  def clip(x, upper_bounds)
    return 0 if x < 0
    return upper_bounds if x > upper_bounds
    x
  end

  def square_size
    image_dimensions.max / 5
  end

  def detailed_pixel_coords
    `convert #{filename} -edge 1 #{filename}.tmp1`
    `convert #{filename}.tmp1 -statistic Mean 5x5 #{filename}.tmp2`
    result = `identify -define identify:locate=maximum -define identify:limit=2 #{filename}.tmp2`
    `rm #{filename}.tmp*`
    result[/(\d+,\d+)\n/, 1].split(',').map(&:to_i)
  end
end

# idf = ImageDetailFinder.new(ARGV[0])
# idf.write_out_with_bounding_box
# idf.write_out_cropped_image
