get '/websocket' do
  if Faye::WebSocket.websocket?(request.env)
    ws = Faye::WebSocket.new(request.env)
    client_id = "client_#{rand(10000)}"
    ws.on :open do |event|
      puts "Client connected: #{client_id}"
      # Create new player
      player_id = "player_#{rand(1000)}"
      $players[player_id] = { x: 5, y: 5, id: player_id }
      $clients[client_id] = { ws: ws, player_id: player_id }
      ws.send(JSON.generate({
        type: 'welcome',
        player_id: player_id,
        position: $players[player_id],
        all_players: $players
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

        case direction
        when 'up'    then player[:y] -= 1
        when 'down'  then player[:y] += 1
        when 'left'  then player[:x] -= 1
        when 'right' then player[:x] += 1
        end

        # Keep in bounds
        player[:x] = [0, [15, player[:x]].min].max
        player[:y] = [0, [15, player[:y]].min].max

        # Tell everyone about the move
        broadcast_to_all({
          type: 'player_moved',
          player: player
        })

        puts "#{player_id} moved to (#{player[:x]}, #{player[:y]})"
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