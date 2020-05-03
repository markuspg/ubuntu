require "serverspec"
require "net/ssh"

set :backend, :ssh
set :disable_sudo, true

def vm_user
  "vagrant"
end

# run the given command in the same environment as if you were logged in to the VM
def user_command(cmd)
  command("sudo -u #{vm_user} bash -i -c '#{cmd}; exit $?'")
end
