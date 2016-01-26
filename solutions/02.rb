def move(snake, direction)
  moved_snake = grow(snake, direction)
  moved_snake.shift
  moved_snake
end

def grow(snake, direction)
  snake + [(snake.last.zip(direction)).map { |x| x.reduce(:+) }]
end

def obstacle_ahead?(snake, direction, dimensions)
  next_position = (snake.last.zip(direction)).map { |x| x.reduce(:+) }
  wall_ahead?(next_position, dimensions) or snake.include?(next_position)
end

def wall_ahead?(next_position, dimensions)
  next_position.all? { |x| x < 0 } or
    next_position.first >= dimensions[:width] or
    next_position.last >= dimensions[:height]
end

def danger?(snake, direction, dimensions)
  obstacle_ahead?(snake, direction, dimensions) or
    obstacle_ahead?(grow(snake, direction), direction, dimensions)
end

def new_food(food, snake, dimensions)
  map = (0...dimensions[:width]).to_a.product (0...dimensions[:height]).to_a
  (map - food - snake).sample
end

def valid_food_position?(new_food_coordinates, invalid_points, dimensions)
  not invalid_points.include?(new_food_coordinates) and
    point_on_field(new_food_coordinates, dimensions)
end

def point_on_field(point, dimensions)
  point.all? { |x| x >= 0 } and point.first < dimensions[:width] and
    point.last < dimensions[:height]
end
