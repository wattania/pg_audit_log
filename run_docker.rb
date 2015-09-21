require 'docker'
require 'pathname'

##########################################
pwd = Pathname.new File.expand_path File.dirname __FILE__
CURRENT_DIR = pwd.to_s

DOCKER_USER  = "angstroms"
DOCKER_PROJ = pwd.basename.to_s
##########################################

def docker_repo tag_name = "latest"
  "docker.io/#{DOCKER_USER}/#{DOCKER_PROJ}:#{tag_name}"
end

cmd = [
  "docker run --rm -it",
  "-v #{pwd}/src:/src",
  "--privileged",
  docker_repo,
  "bash"
].join ' '

exec cmd
