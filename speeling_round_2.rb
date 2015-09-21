# require "webrick"
require "sinatra"
set :port, 3027
require 'json'
require 'erb'

JSON_FILE = File.dirname(__FILE__) + "/my_dict.json"

get "/" do
    array = JSON.parse(File.read(JSON_FILE))
    array.sort!

    response.status = 200
    response.body = ERB.new(File.read("templates/home.html.erb")).result(binding)
end

get "/add" do
    response.status = 200
    response.body = ERB.new(File.read("templates/add.html.erb")).result(binding)
end

post "/save" do
    array = JSON.parse(File.read(JSON_FILE))
    array << "#{request.query["word"]}"
    File.write(JSON_FILE, array.to_json)

    response.status = 302
    response.header["Location"] = "/"
    response.body = "Saved"
end

get "/search" do
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
