lock '3.4.0'

set :application, 'forms'
set :repo_url, "git@github.com:elbongurk/#{fetch(:application)}.git"

set :deploy_to, "/usr/share/nginx/#{fetch(:application)}"
