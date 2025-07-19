def broadcast_to_all(message)
  json_message = JSON.generate(message)
  $clients.each do |client_id, client_data|
    begin
      client_data[:ws].send(json_message)
    rescue => e
      puts "Error sending to #{client_id}: #{e.message}"
      $clients.delete(client_id)
    end
  end
end

def broadcast_to_others(exclude_client_id, message)
  json_message = JSON.generate(message)
  $clients.each do |client_id, client_data|
    next if client_id == exclude_client_id
    begin
      client_data[:ws].send(json_message)
    rescue => e
      puts "Error sending to #{client_id}: #{e.message}"
      $clients.delete(client_id)
    end
  end
end