stow "nginx" do
  check "sbin/nginx"
  action :uninstall
end

stow "ts" do
  check "bin/ts"
  action :uninstall
end
