namespace :deploy do
  after :finished, 'airbrake:deploy'
end
