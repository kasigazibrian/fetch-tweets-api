module Sinatra
  # module with application helper methods
  module ApplicationHelper
    def pick_required_attributes(tweet_hash)
      allowed_attributes = %i[location name description]
      allowed_keys = %i[text user]
      tweet = tweet_hash.select { |k, _| allowed_keys.include? k }
      tweet[:user] = t[:user].select { |key, _val| allowed_attributes.include? key }
      tweet
    end
  end
end
