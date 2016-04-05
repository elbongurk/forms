namespace :setup do  
  desc "Adds requried ubuntu packages"
  task :apt do
    on roles(:app) do |host|
      template 'ruby.list', '/etc/apt/sources.list.d/ruby.list', host
      execute 'apt-key', 'adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C3173AA6'
    end
    on roles(:db) do |host|
      template 'postgres.list', '/etc/apt/sources.list.d/postgres.list', host
      execute :wget, '--quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -'
    end
    on roles(:web) do |host|
      template 'nginx.list', '/etc/apt/sources.list.d/nginx.list', host
      execute :wget, '--quiet -O - http://nginx.org/keys/nginx_signing.key | apt-key add -'
    end
  end
  
  desc "Update all ubuntu packages"
  task :sys do
    on roles(:all) do |host|
      execute 'apt-get', 'update'
      execute 'apt-get', 'upgrade -y'
      execute 'apt-get', 'dist-upgrade -y'
      execute 'apt-get', 'autoremove -y'
    end
  end

  desc "Reboots the server(s)"
  task :reboot do
    on roles(:all) do
      execute :reboot
    end
  end

  desc "Install required packages"
  task :binaries do
    on roles(:app) do |host|
      execute 'apt-get', 'install -y git build-essential libssl-dev libpq-dev ruby2.3 ruby2.3-dev nodejs'
    end
    on roles(:db) do |host|
      execute 'apt-get', 'install -y postgresql-9.4'
    end
    on roles(:web) do |host|
      execute 'apt-get', 'install -y nginx'
    end
  end

  desc "Setup ruby"
  task :ruby do
    on roles(:app) do |host|
      execute :echo, "'gem: --no-document' > $HOME/.gemrc"
      execute 'gem update --system'
      execute 'gem install bundler'
    end
  end

  desc "Setup rails"
  task :rails do
    on roles(:app) do |host|
      execute :echo, "'export HOST=\"#{host}\"' > /etc/environment.local"
      rails_env = fetch(:rails_env) || fetch(:stage)
      execute :echo, "'export RAILS_ENV=\"#{rails_env}\"' >> /etc/environment.local"
      secret_key_base = capture(:openssl, 'rand -hex 64')      
      execute :echo, "'export SECRET_KEY_BASE=\"#{secret_key_base}\"' >> /etc/environment.local"
    end
  end

  desc "Setup postgres"
  task :postgres do
    on roles(:db) do |host|
      execute :sudo, "-u postgres createuser -s #{host.user}"
      execute :createdb, "#{fetch(:application)}_#{fetch(:rails_env) || fetch(:stage)}"
    end
  end
  
  desc "Setup nginx"
  task :nginx do
    on roles(:web) do |host|
      execute :rm, '-f /etc/nginx/conf.d/default.conf'
      template 'nginx.conf', "/etc/nginx/conf.d/#{fetch(:application)}.conf", host
    end
  end

  desc "Setup puma"
  task :puma do
    on roles(:app) do |host|
      template 'puma.conf', '/etc/init/puma.conf', host
      template 'puma-manager.conf', '/etc/init/puma-manager.conf', host
      execute :echo, "'#{current_path}' > /etc/puma.conf"
    end
  end

  desc "Setup que"
  task :que do
    on roles(:app) do |host|
      template 'que.conf', '/etc/init/que.conf', host
      template 'que-manager.conf', '/etc/init/que-manager.conf', host
      execute :echo, "'#{current_path}' > /etc/que.conf"
    end
  end

  desc "Create SSH deploy key for github"
  task :ssh do
    on roles(:all) do |host|
      execute 'ssh-keygen', '-t rsa -b 4096 -f $HOME/.ssh/id_rsa -N ""'
      key = capture :cat, '$HOME/.ssh/id_rsa.pub'
      puts "SSH Key for Github Deploy @ https://github.com/owner/repo/settings/keys"
      puts key
    end
  end

  desc "Prep setup for run"
  task cold: %w(apt sys reboot)
end

desc "Run setup"
task setup: [ 'setup:binaries',
              'setup:ruby',
              'setup:rails',
              'setup:postgres',
              'setup:nginx',
              'setup:puma',
              'setup:que',
              'setup:ssh' ]

task :load do
  task :defaults do
    set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/sockets', 'tmp/pids')
  end
end

def template(from, to, host)
  template_path = File.expand_path("../../templates/#{from}.erb", __FILE__)
  template = ERB.new(File.new(template_path).read).result(binding)
  upload! StringIO.new(template), to
  execute :chmod, "644 #{to}"
end
