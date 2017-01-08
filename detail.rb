def calculate_square_size(filename)
  `convert #{filename} -format "%wx%h" info:`.split('x').map(&:to_i).max / 10
end

def rectangle_coords(point_coords, square_size)
  half_square = square_size/2
  coord_array = [
    point_coords[0] - half_square,
    point_coords[1] - half_square,
    point_coords[0] + half_square,
    point_coords[1] + half_square
  ]
  "%d,%d %d,%d" % coord_array
end

def detailed_pixel_coords(filename)
  `convert #{filename} -edge 1 #{filename}.tmp1`
  `convert #{filename}.tmp1 -statistic Mean 5x5 #{filename}.tmp2`
  result = `identify -define identify:locate=maximum -define identify:limit=2 #{filename}.tmp2`
  `rm #{filename}.tmp*`
  result[/(\d+,\d+)\n/, 1].split(',').map(&:to_i)
end

coords = detailed_pixel_coords(ARGV[0])

square_size = calculate_square_size(filename)

`convert #{filename} -stroke red -strokewidth 1 -fill none -draw "rectangle #{rectangle_coords(coords, square_size)} " out-#{filename}`
