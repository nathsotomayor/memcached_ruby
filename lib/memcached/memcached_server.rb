require 'socket' # Call sockets from stdlib
require File.expand_path('../../memcached', __FILE__)
require File.expand_path('../connection', __FILE__)

# This class listen on the defined port and creates a
# instance of Connection class creating a TCP connection
class MyServer
  attr_reader :server, :port

  # Creates a new MyServer instance
  # Params:
  # +port+:: port number
  def initialize(port)
    @port = port
    @server =
      begin
        TCPServer.new(@port) # Socket to listen on port (2000)
      rescue SystemCallError => error
        raise "Can't create TCP server on port #{@port}: #{error}"
      end
  end

  # Creates a connection for incoming requests
  def start
    memcached = Memcached.new
    puts "Server running and listening on port #{port}...\n"
    loop do
      Thread.start(server.accept) do |client| # Wait for a client to connect
        begin
          Connection.new(memcached, client).accept_requests
        ensure
          client.close if client # Disconnect from the client
          puts 'Client sesion closed!'
        end
      end
    end
  end
end
