require 'socket'
 
class Graphite
  def initialize()
	config = YAML.load_file("#{File.dirname(__FILE__)}/../config/config.yml")
	graphite = config['graphite']
    @host = graphite['host']
	@port = graphite['port']
  end
 
  def socket
    return @socket if @socket && !@socket.closed?
	begin
		@socket = TCPSocket.new(@host, @port)
	rescue
		@socket = nil
	end
	return @socket
  end
 
  def report(key, value, time = Time.now)
    begin
      socket.write("#{key.gsub(/[^a-zA-Z0-9_\-\.]/, '')} #{value.to_f} #{time.to_i}\n")
    rescue Errno::EPIPE, Errno::EHOSTUNREACH, Errno::ECONNREFUSED
      puts "ERROR: bad socket"
	  @socket = nil
    end
  end
 
  def close_socket
    @socket.close if @socket
    @socket = nil
  end
end
