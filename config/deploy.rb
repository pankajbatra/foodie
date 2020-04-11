# config valid for current version and patch releases of Capistrano
# lock "~> 3.10.2"

set :application, "toptal-food"
set :repo_url, "git@git.toptal.com:Ivan-Ilijasic/pankaj-batra.git"
# set :ssh_options, { :forward_agent => true }

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/ubuntu/apps/toptal-food"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

set :log_level, :debug

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"
append :linked_files, "config/master.key"
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
append :linked_dirs, 'log'
append :linked_dirs, 'tmp/pids'
append :linked_dirs, 'tmp/cache'
append :linked_dirs, 'tmp/sockets'
append :linked_dirs, 'public/system'
append :linked_dirs, 'vendor/bundle'
append :linked_dirs, '.bundle'
append :linked_dirs, 'public/uploads'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure


set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.7.0'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails puma pumactl}
set :rbenv_roles, :all # default value
#set :whenever_roles, ->{:web}

#set :delayed_job_monit_enabled, true
set :templates_path, 'config/deploy/templates'
# set :delayed_job_server_roles, "[:app]"
# set :delayed_job_service, -> { "delayed_job_#{fetch(:application)}_#{fetch(:stage)}" }

set :puma_preload_app, false
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock" #accept array for multi-bind
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log, "#{shared_path}/log/puma_error.log"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
# set :puma_default_control_app, "unix://#{shared_path}/tmp/sockets/pumactl.sock"
# set :puma_plugins, ['tmp_restart']  #accept array of plugins
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_init_active_record, true
# set :puma_user, 'ubuntu'
# set :puma_rackup, -> { File.join(current_path, 'config.ru') }
# set :puma_role, :web
# set :puma_worker_timeout, nil

# set :nginx_use_ssl, true

namespace :deploy do

  # Rake::Task["deploy:check:make_linked_dirs"].clear_actions
  # Rake::Task["deploy:check:linked_files"].clear_actions
  # Rake::Task["deploy:symlink:linked_files"].clear_actions

  desc 'Set the correct permissions for the files'
  task :fix_permissions do
    on roles(:app), in: :sequence, wait: 5 do
      # execute :chmod, "+x #{release_path}/bin/delayed_job"
      # run "chmod 777 #{current_release}/#{ee_system}/cache/"
      # run "chmod 666 #{current_release}/#{ee_system}/config_bak.php"
    end
  end

  desc 'Runs rake db:seed for seed data'
  # => [:set_rails_env]
  task :seed do
    # on primary fetch(:migration_role) do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        # with rails_env: fetch(:rails_env) do
        execute :rake, "db:seed"
        # end
      end
    end
  end

  after :publishing, :fix_permissions

  # desc 'Restart application'
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     # Your restart mechanism here, for example:
  #     execute :touch, release_path.join('tmp/restart.txt')
  #   end
  # end

  # after :fix_permissions, :restart

  after :fix_permissions, :x_bin_rails do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :chmod, 'u+x bin/rails'
      end
    end
  end

  after :fix_permissions, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :rake, 'tmp:cache:clear'
      end
    end
  end

  after :finishing, 'deploy:cleanup'
end

