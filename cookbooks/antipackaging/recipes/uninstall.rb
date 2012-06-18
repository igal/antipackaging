stow_package "nginx" do
  check "sbin/nginx"
  action :uninstall
end

stow_package "ts" do
  check "bin/ts"
  action :uninstall
end
