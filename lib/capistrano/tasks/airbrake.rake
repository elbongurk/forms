namespace :deploy do
  after 'deploy:finished', 'airbrake:deploy'
end
