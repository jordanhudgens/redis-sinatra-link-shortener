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
  erb :index
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
