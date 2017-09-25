require 'sinatra'
require 'redis'

redis = Redis.new

helpers do
  include Rack::Utils

  def random_string(length)
    SecureRandom.base64.tr('+/=', 'Qrt')
  end
end

get '/' do
  erb :index, layout: :master
end

get '/links' do
  @links_and_short_codes = redis.keys("*").each_with_object({}) do |link, hash|
    hash[link] = redis.get(link)
  end
  erb :links, layout: :master
end

post '/' do
  if params[:url] and not params[:url].empty?
    @shortcode = random_string 5
    redis.setnx "links:#{@shortcode}", params[:url]
  end
  erb :index
end

get '/:shortcode' do
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || '/'
end
