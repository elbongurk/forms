namespace :deploy do
  after 'deploy:finished', 'airbrake:deploy'
end

namespace :load do
  task :defaults do
    airbrake_env = {
      'AIRBRAKE_PROJECT_ID' => ENV['AIRBRAKE_PROJECT_ID'],
      'AIRBRAKE_API_KEY' => ENV['AIRBRAKE_API_KEY']
    }
    set :default_env, fetch(:default_env, {}).merge(airbrake_env)
  end
end
