require_relative './config/environment'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require 'sinatra/contrib'

Dir.glob('lib/tasks/*.rake').each { |task| load task }

task :console do
  Pry.start
end
