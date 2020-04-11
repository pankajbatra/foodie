# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

require 'capistrano/rails/migrations'

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

require 'capistrano/bundler'
# require 'capistrano/rails'
require 'capistrano/file-permissions'
# require 'whenever/capistrano'
require 'capistrano/rbenv'
require 'capistrano/rake'
# require 'capistrano/delayed_job'
# require 'capistrano/monit'
require 'capistrano/puma'
require 'capistrano/ssh_doctor'
install_plugin Capistrano::Puma # Default puma tasks
install_plugin Capistrano::Puma::Workers # if you want to control the workers (in cluster mode)
install_plugin Capistrano::Puma::Nginx # if you want to upload a nginx site template
