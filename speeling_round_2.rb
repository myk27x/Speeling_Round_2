require "webrick"
require 'json'
require 'erb'

JSON_FILE = File.dirname(__FILE__) + "/my_dict.json"

class Dictionary < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    array = JSON.parse(File.read(JSON_FILE))
    array.sort!

    response.status = 200
    response.body = ERB.new(File.read("templates/home.html.erb")).result(binding)
  end
end

class AddWord < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)

    response.status = 200
    response.body = ERB.new(File.read("templates/add.html.erb")).result(binding)
  end
end

class SaveWord < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    array = JSON.parse(File.read(JSON_FILE))
    array << "#{request.query["word"]}"
    File.write(JSON_FILE, array.to_json)

    response.status = 302
    response.header["Location"] = "/"
    response.body = "Saved"
  end
end

class SearchWord < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    array = JSON.parse(File.read(JSON_FILE))
      # chomped = lines.map do |line|
      #   line.chomp
      # end
      found = array.select do |match|
        match.start_with?(request.query["search"])
      end

    response.status = 200
    response.body = ERB.new(File.read("templates/search.html.erb")).result(binding)
  end
end

server = WEBrick::HTTPServer.new(Port:3027)
server.mount "/", Dictionary
server.mount "/add", AddWord
server.mount "/save", SaveWord
server.mount "/search", SearchWord
trap("INT") { server.shutdown }

server.start
