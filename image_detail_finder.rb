class ImageDetailFinder
  def initialize(filename)
    @filename = filename
  end

  def write_out_with_bounding_box(output_filename="out-#{filename}")
    rect = "%d,%d %d,%d" % rectangle_coords
    `convert #{filename} -stroke red -strokewidth 1 -fill none -draw "rectangle #{rect} " #{output_filename}`
  end

  def rectangle_coords_for_crop
    point_coords = detailed_pixel_coords
    half_square = square_size / 2
    [
      point_coords[0] - half_square,
      point_coords[1] - half_square,
      square_size,
      square_size
    ]
  end

  def rectangle_coords
    point_coords = detailed_pixel_coords
    half_square = square_size / 2
    [
      point_coords[0] - half_square,
      point_coords[1] - half_square,
      point_coords[0] + half_square,
      point_coords[1] + half_square
    ]
  end

  def image_dimensions
    `convert #{filename} -format "%wx%h" info:`.split('x').map(&:to_i)
  end

  private

  attr_reader :filename

  def square_size
    image_dimensions.max / 10
  end

  def detailed_pixel_coords
    `convert #{filename} -edge 1 #{filename}.tmp1`
    `convert #{filename}.tmp1 -statistic Mean 5x5 #{filename}.tmp2`
    result = `identify -define identify:locate=maximum -define identify:limit=2 #{filename}.tmp2`
    `rm #{filename}.tmp*`
    result[/(\d+,\d+)\n/, 1].split(',').map(&:to_i)
  end
end

# ImageDetailFinder.new(ARGV[0]).write_out_with_bounding_box
