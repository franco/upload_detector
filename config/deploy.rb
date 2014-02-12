require 'bundler/capistrano'
require "rvm/capistrano"

if ENV['DEPLOY'] == 'production'
  set :user, "manager_staging"
  set :user, "import"
  role :app, "kai.shortcutmedia.com"
else
  puts "*** No default deploy target!"
  #set :port, 2222
  #role :app, "localhost"
  exit
end

set :application, "upload_detector"

# default_run_options[:pty] = true
ssh_options[:forward_agent] = true
#ssh_options[:verbose] = :debug

set :deploy_to, "/srv/#{user}/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, :git
set :repository, "git@github.com:shortcutmedia/upload_detector.git"
#set :branch, "master"
set :branch, "using_tonga"

# install and use rvm
set :rvm_ruby_string, 'ruby-1.9.3-p327'
before 'deploy:setup', 'rvm:install_rvm'   # install RVM
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset


# bundler setup
#
set :bundle_without, [:development, :test ]

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    #run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :rvm do
  task :install_rvm_non_login_shell do
    # This loads RVM into a shell session.  source ~/.rvm/scripts/rvm  source ~/.rvm/environments/default" >> $HOME/.bashrc'
    #run %Q{sed -i '1i [[ -s "~/.rvm/scripts/rvm" ]] && source ~/.rvm/scripts/rvm' $HOME/.bashrc}

    run %q{sed -i '1i [[ -f ~/.rvm/scripts/rvm ]] && [ "$(type -t rvm)" = "function" ] || source ~/.rvm/scripts/rvm' $HOME/.bashrc}
  end
end

after 'rvm:install_ruby', 'rvm:install_rvm_non_login_shell'

