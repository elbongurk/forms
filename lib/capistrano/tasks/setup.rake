namespace :setup do  
  desc "Adds requried ubuntu packages"
  task :apt do
    on roles(:app) do |host|
      template 'ruby.list', '/etc/apt/sources.list.d/ruby.list'
      execute 'apt-key', 'adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C3173AA6'
    end
    on roles(:db) do |host|
      template 'postgres.list', '/etc/apt/sources.list.d/postgres.list'
      execute :wget, '--quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -'
    end
    on roles(:web) do |host|
      template 'nginx.list', '/etc/apt/sources.list.d/nginx.list'
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

  desc 'Adds environment variables'
  task :environment do
    on roles(:app) do |host|
      options = { }
      options[:rails_env] = fetch(:rails_env) || fetch(:stage)
      options[:host] = host
      options[:secret_key_base] = capture(:openssl, 'rand -hex 64')
      template 'environment.local', '/etc/environment.local', options
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
      template 'nginx.conf', "/etc/nginx/conf.d/#{fetch(:application)}.conf"
    end
  end

  desc "Setup puma"
  task :puma do
    on roles(:app) do |host|
      template 'puma.conf', '/etc/init/puma.conf', { user: host.user }
      template 'puma-manager.conf', '/etc/init/puma-manager.conf'
      append current_path, '/etc/puma.conf'
    end
  end

  desc "Setup que"
  task :que do
    on roles(:app) do |host|
      template 'que.conf', '/etc/init/que.conf', host
      template 'que-manager.conf', '/etc/init/que-manager.conf', host
      append current_path, '/etc/que.conf'
    end
  end

  desc "Create SSH deploy key for github"
  task :ssh do
    on roles(:all) do |host|
      unless test('[ -s $HOME/.ssh/id_rsa.pub ]')
        execute 'ssh-keygen', '-t rsa -b 4096 -f $HOME/.ssh/id_rsa -N ""'
        key = capture :cat, '$HOME/.ssh/id_rsa.pub'
        info "SSH Key for Github Deploy @ https://github.com/owner/repo/settings/keys:\n#{key}"
      end
    end
  end

  desc "Prep setup for run"
  task cold: %w(apt sys reboot)
end

desc "Run setup"
task setup: [ 'setup:binaries',
              'setup:environment',
              'setup:ruby',
              'setup:postgres',
              'setup:nginx',
              'setup:puma',
              'setup:que',
              'setup:ssh' ]

namespace :deploy do
  task :set_linked_dirs do
    set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/sockets', 'tmp/pids', 'tmp/cache')
  end

  desc 'Restarts services if running'
  task :restart do
    on roles(:app) do |host|
      if test("status puma app=#{current_path}")
        execute :restart, "puma app=#{current_path}"
      end
      if test("status que app=#{current_path}")
        execute :restart, "que app=#{current_path}"
      end
    end
  end

  after 'deploy:finished', 'deploy:restart'
end

Capistrano::DSL.stages.each do |stage|
  after stage, 'deploy:set_linked_dirs'
end

def template(from, to, options = {})
  unless test("[ -s #{to} ]")
    template_path = File.expand_path("../../templates/#{from}.erb", __FILE__)
    template = ERB.new(File.new(template_path).read).result(binding)
    upload! StringIO.new(template), to
    execute :chmod, "644 #{to}"
  end
end

def append(text, to)
  unless test("[ -s #{to} ] && grep -q '#{text}' #{to}")
    execute :echo, "'#{text}' >> #{to}"
  end
end
