namespace :deploy do
  task :set_default_env do
    airbrake_env = {
      'AIRBRAKE_PROJECT_ID' => ENV['AIRBRAKE_PROJECT_ID'],
      'AIRBRAKE_API_KEY' => ENV['AIRBRAKE_API_KEY']
    }
    set :default_env, fetch(:default_env, {}).merge(airbrake_env)
  end
  
  after :finished, 'airbrake:deploy'
end

Capistrano::DSL.stages.each do |stage|
  before stage, 'deploy:set_default_env'
end
