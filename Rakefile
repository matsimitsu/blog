desc "Build the website from source"
task :build do
  puts "## Building website"
  status = system("middleman build --clean")
  puts status ? "OK" : "FAILED"
end

desc "Run the preview server at http://localhost:4567"
task :preview do
  system("middleman server")
end

desc "Deploy website via rsync"
task :deploy do
  require 'yaml'
  @config = YAML.load_file('data/config.yml')

  puts "## Deploying website via rsync to #{@config['ssh_host']}"
  status = system("rsync --update -avze 'ssh' build/ #{@config['ssh_user']}@#{@config['ssh_host']}:#{@config['ssh_dir']}/site")
  puts status ? "OK" : "FAILED"
end

desc "Build and deploy website"
task :build_deploy => [:build, :deploy]
