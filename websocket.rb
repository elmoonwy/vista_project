require 'em-websocket'

class Client
  attr_accessor :ws
  def initialize(ws)
    @ws=ws
  end
end


EM.run {
  @clients = []
  EM::WebSocket.run(:host => "10.0.80.59", :port => 8998) do |ws|
    ws.onopen do |handshake|
      client=Client.new(ws)
      @clients << client
      puts "WebSocket connection open"
      puts handshake.query
      # Access properties on the EM::WebSocket::Handshake object, e.g.
      # path, query_string, origin, headers
      # Publish message to the client
      # ws.send "Hello Client, you connected to #{handshake.path}"
    end

    ws.onclose do
      ws.send "Closed."
      @clients.each do |client|
        @clients.delete client if client.ws==ws
      end
    end


    ws.onmessage do |msg|
      puts "Recieved message: #{msg}"
      ws.send "#{msg}"
      @clients.each do |client|
        client.ws.send msg
        puts "Sent msg:"+msg
      end
    end
  end
}

