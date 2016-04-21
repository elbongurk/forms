namespace :rails do
  desc "Open rails console on remote host"
  task :console do
    on roles(:app).first do |host|
      execute_interactively('console')
    end
  end

  desc "Open rails dbconsole on remote host"
  task :dbconsole do
    on roles(:app).first do |host|
      execute_interactively('dbconsole')
    end
  end

  def execute_interactively(command)
    user = host.user
    exec "ssh -l #{user} #{host} -t 'cd #{current_path} && source /etc/environment.local && bundle exec rails #{command}'"
  end
end
  
