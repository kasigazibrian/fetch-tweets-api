require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/contrib'
require 'sidekiq'
require 'sidekiq-status'
require_relative '../helpers/application_helper'
require_relative '../../workers/fetch_tweets'

class ApplicationController < Sinatra::Base
  helpers Sinatra::ApplicationHelper
  configure do
    set :show_exceptions, false
  end

  error do
    json error: 'An error has occurred: ' + request.env['sinatra.error'].message
  end

  get '/download_tweets' do
    count = params[:count] || 10
    job_id = FetchTweets.perform_async(count)
    Job.create(job_id: job_id)
    json message: 'Yo! Downloading is happening'
  end

  get '/check_status/:job_id' do
    data = Sidekiq::Status.get_all params[:job_id]
    json data: data
  end

  get '/stored_tweets' do
    tweets = JSON.parse(Tweet.all.to_json)
    tweets.each do |tweet|
      tweet['user'] = JSON.parse(User.find(tweet['user_id']).to_json)
    end
    json tweets: tweets
  end

  not_found do
    status 404
    json message: 'Unknown url'
  end
end

