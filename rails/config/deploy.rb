set :application, "test"
set :deploy_to, "/var/www/apps/#{application}"

#no scm for this little test app
set :repository, "."
set :scm, :none
set :deploy_via, :copy
set :copy_exclude, ".git/*"

set :user, "deploy"
set :runner, user
default_run_options[:pty] = true

role :app, "test.jnewland.com"
role :web, "test.jnewland.com"
role :db,  "test.jnewland.com", :primary => true

require 'san_juan'
san_juan.role :app, %w(mongrels)

#overwrite the default start, stop, and restart tasks to use god
namespace :deploy do

  desc "Use god to restart the app"
  task :restart do
    god.all.reload
    god.app.mongrels.restart
  end

  desc "Use god to start the app"
  task :start do
    god.all.start
  end

  desc "Use god to stop the app"
  task :stop do
    god.all.terminate
  end

end