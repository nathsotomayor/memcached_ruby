#!/usr/bin/env ruby

require 'socket' # Call sockets from stdlib
require 'optparse' # Call OptionParse class for command-line option analysis

options = {}
OptionParser.new do |opt|
  opt.banner = 'Usage: memcached_client.rb [options]'

  opt.on('-p', '--port port', 'Port') do |each|
    options[:port] = each
  end
end.parse!

options[:port] ||= 2000 # Assigning the port 2000 for the connection

begin
  my_socket = TCPSocket.open('localhost', options[:port]) # Opens a TCP connection to localhost on the port (2000)
  info_message = '
  ********************* Memcached Commands *********************
  ______________________________________________________________
 |                                                              |
 | Storage Commands   | set, add, replace, append, prepend, cas |
 |______________________________________________________________|
 |                                                              |
 | Retrieval Commands | get, gets                               |
 |______________________________________________________________|
  
 Or (quit) to exit
 '
  puts info_message # Show an intro message about commands
  loop do
    puts 'Enter a command:'
    command = gets.chomp # Read lines from the socket
    command += "\r\n#{gets.chomp}" if %w(set add replace append prepend cas).include?(command.split.first)
    my_socket.write command
    answer = my_socket.recv(1024)
    if answer == 'quit'
      puts '*** Bye! ***'
      break
    else
      puts answer
    end
  end
  my_socket.close # Close the socket when done
rescue SystemCallError => error
  raise "Can't connect to TCP server on port #{options[:port]}: #{error}"
end
