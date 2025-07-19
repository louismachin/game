TILE_WIDTH = 16
TILE_HEIGHT = 16

$tile_cache = {}

$tile_definitions = {
  0 => '/tile/tiny_dungeon_world/8/5', # Grass
  1 => '/tile/tiny_dungeon_world/8/6', # Path
  2 => '/tile/tiny_dungeon_world/12/5', # Flower
}

def extract_tile(sheet, tile_x, tile_y, scale_factor = 2)
  start_x = tile_x * TILE_WIDTH
  start_y = tile_y * TILE_HEIGHT
  scaled_width = TILE_WIDTH * scale_factor
  scaled_height = TILE_HEIGHT * scale_factor
  tile = ChunkyPNG::Image.new(scaled_width, scaled_height, ChunkyPNG::Color::TRANSPARENT)
  (0...scaled_height).each do |y|
    (0...scaled_width).each do |x|
      source_x = start_x + (x / scale_factor)
      source_y = start_y + (y / scale_factor)
      next unless source_x < sheet.width && source_y < sheet.height
      tile[x, y] = sheet[source_x, source_y]
    end
  end
  return tile
end

get '/tile/:name/:x/:y' do
  tilesheet_name = params[:name]
  file_path = APP_ROOT + '/public/tilesheets/' + tilesheet_name + '.png'
  if File.file?(file_path)
    tile_x = params[:x].to_i
    tile_y = params[:y].to_i
    cache_index = [tilesheet_name, tile_x, tile_y]
    if $tile_cache[cache_index]
      tile_image = $tile_cache[cache_index]
    else
      tilesheet = ChunkyPNG::Image.from_file(file_path)
      tile_image = extract_tile(tilesheet, tile_x, tile_y)
      $tile_cache[cache_index] = tile_image
    end
    content_type 'image/png'
    tile_image.to_blob
  else
    status 404
    content_type 'json'
    { error: 'Tilesheet not found' }.to_json
  end
end

get '/tile/:id' do
  id = params[:id].to_i
  if $tile_definitions[id]
    redirect $tile_definitions[id]
  else
    status 404
    content_type :json
    { error: 'Tile definition not found' }.to_json
  end
end