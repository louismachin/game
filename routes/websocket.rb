get '/websocket' do
  if Faye::WebSocket.websocket?(request.env)
    ws = Faye::WebSocket.new(request.env)
    client_id = "client_#{rand(10000)}"
    ws.on :open do |event|
      puts "Client connected: #{client_id}"
      # Create new player
      player_id = "player_#{rand(1000)}"
      $players[player_id] = { x: 5, y: 5, id: player_id, room_id: 0 }
      $clients[client_id] = { ws: ws, player_id: player_id }
      ws.send(JSON.generate({
        type: 'welcome',
        player_id: player_id,
        position: $players[player_id],
        all_players: $players,
        room: get_room(0),
      }))
      broadcast_to_others(client_id, {
        type: 'player_joined',
        player: $players[player_id]
      })
    end

    ws.on :message do |event|
      data = JSON.parse(event.data)
      player_id = $clients[client_id][:player_id]

      if data['type'] == 'move'
        direction = data['direction']
        player = $players[player_id]

        new_x, new_y = player[:x], player[:y]

        case direction
        when 'up'    then new_y -= 1
        when 'down'  then new_y += 1
        when 'left'  then new_x -= 1
        when 'right' then new_x += 1
        end

        # Keep in bounds
        room = get_room(player[:room_id])
        new_x = [0, [15, new_x].min].max
        new_y = [0, [15, new_y].min].max

        valid_movement = true

        # Test collision
        unless room[:tiles][new_y][new_x] == 0
          valid_movement = false
        end

        if valid_movement
          player[:x], player[:y] = new_x, new_y
          broadcast_to_all({
            type: 'player_moved',
            player: player
          })
          puts "#{player_id} moved to (#{player[:x]}, #{player[:y]})"
        else
          broadcast_to_all({
            type: 'player_stuck',
            player: player
          })
        end
      end
    end
    
    ws.on :close do |event|
      if $clients[client_id]
        player_id = $clients[client_id][:player_id]
        $players.delete(player_id)
        broadcast_to_others(client_id, {
          type: 'player_left',
          player_id: player_id
        })
        puts "Client disconnected: #{client_id}"
      end
      $clients.delete(client_id)
    end
    ws.rack_response
  else
    status 400
    "WebSocket required"
  end
end