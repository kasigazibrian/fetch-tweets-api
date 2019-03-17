require_relative './../config/environment'
require 'sidekiq'
require 'sidekiq-status'
require_relative '../config/twitter_config'


Sidekiq.configure_client do |config|
  # accepts :expiration (optional)
  Sidekiq::Status.configure_client_middleware config, expiration: 30.minutes
end

class FetchTweets
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  sidekiq_options retry: false
  uri = URI.parse(ENV['REDISCLOUD_URL'] || 'redis://localhost:6379/')
  @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)

  def perform(count)
    @client = TwitterConfig.configure
    tweets = @client.user_timeline('rubyinside', count: count)
    tweet_list = []
    tweets.each do |tweet|
      tweet_list << pick_required_attributes(tweet.to_h)
    end
    tweet_list.each do |tweet|
      user = User.find_or_create_by(tweet[:user])
      Tweet.find_or_create_by(text: tweet[:text], truncated: tweet[:truncated],
                              retweet_count: tweet[:retweet_count],
                              favorite_count: tweet[:favorite_count],
                              user_id: user.id, id: tweet[:id])
    end
    puts 'Completed downloading tweets'
  end

  private

  def pick_required_attributes(tweet_hash)
    allowed_attributes = %i[location name id description verified]
    allowed_keys = %i[text user truncated id favorite_count retweet_count]
    tweet = tweet_hash.select { |k, _| allowed_keys.include? k }
    tweet[:user] = tweet[:user].select { |key, _val| allowed_attributes.include? key }
    tweet
  end
end
