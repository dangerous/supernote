require 'cairo'

# Device
width = 1920
height = 2560
pixels_per_mm = 12

# settings
colors = {
  plain: {
    background: 1,
    dot_color: 0.5,
    dot_radius: 2,
    line_color: 0.2,
    line_width: 1,
  },
  white: {
    background: 0.80,
    dot_color: 1,
    dot_radius: 3,
    line_color: 1,
    line_width: 4,
  },
  "white dark": {
    background: 0.78,
    dot_color: 1,
    dot_radius: 3,
    line_color: 1,
    line_width: 4,
  }
}

['dot grid', 'lines', 'grid'].each do |style|
  colors.each do |theme, colors|
    background = colors[:background]
    dot_color = colors[:dot_color]
    dot_radius = colors[:dot_radius]
    line_color = colors[:line_color]
    line_width = colors[:line_width]

    [2, 3, 4, 5].each do |grid_size_mm|
      square_size = pixels_per_mm * grid_size_mm
      background_color = [background, background, background]
      dot_color_color = [dot_color, dot_color, dot_color]
      line_color_color = [line_color, line_color, line_color]

      rows = height % square_size != 0 ? height / square_size : height / square_size - 1
      columns = width % square_size != 0 ? width / square_size : width / square_size - 1

      offset_x = (width - (square_size * columns)) / 2
      offset_y = (height - (square_size * rows)) / 2

      # Create a PNG surface
      surface = Cairo::ImageSurface.new(:argb32, width, height)
      context = Cairo::Context.new(surface)

      # Fill the background
      context.set_source_rgb(*background_color)
      context.paint

      if (style == 'dot grid')
        context.set_source_rgb(*dot_color_color)

        (rows + 1).times do |row|
          (columns + 1).times do |col|
            x = offset_x + col * square_size
            y = offset_y + row * square_size
            context.arc(x, y, dot_radius, 0, 2 * Math::PI) # Draw a circle (dot)
            context.fill # Fill the dot
          end
        end
      else
        # Draw the grid
        context.set_source_rgb(*line_color_color)
        context.set_line_width(line_width)

        # Draw vertical grid lines
        if (style == 'grid')
          (columns + 1).times do |col|
            x = offset_x + col * square_size
            context.move_to(x, 0)            # Start at the top edge
            context.line_to(x, height)       # Go to the bottom edge
          end
        end

        # Draw horizontal grid lines
        (rows + 1).times do |row|
          y = offset_y + row * square_size
          context.move_to(0, y)            # Start at the left edge
          context.line_to(width, y)        # Go to the right edge
        end

        # Stroke the grid lines
        context.stroke
      end

      # Save to a PNG file
      output_file = "#{grid_size_mm}mm #{style} #{theme}.png"
      surface.write_to_png(output_file)
      puts "PNG file saved as #{output_file}"
    end
  end
end
