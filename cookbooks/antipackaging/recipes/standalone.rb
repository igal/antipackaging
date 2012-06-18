# Install stow
package "stow"

# Define stow directory
stow = "/usr/local/stow"

# Create stow directory
directory stow

#=======================================================================

# Uninstall system package
package "nginx" do
  action :purge
end

# Install dependencies
%w[build-essential libpcre3-dev dtrx].each do |name|
  package name
end

#=======================================================================

# Variables
name = "nginx"
name_and_version = "#{name}-1.3.1" # <- "nginx-1.3.1"
check = "sbin/nginx"
url = "https://s3.amazonaws.com/igalfiles/#{name_and_version}.tar.gz"
# NOT: url = "http://nginx.org/download/#{name_and_version}.tar.gz"

# Derived variables
cache = Chef::Config[:file_cache_path]
downloaded = ::File.join(cache, ::File.basename(url))
extracted = ::File.join(cache, name_and_version)
installed = ::File.join(stow, name_and_version)
check_installed = ::File.join(installed, check) # <- "/usr/local/stow/ngnix-1.3.1/sbin/ngnix"
check_stowed = ::File.join(stow, "..", check) # <- "/usr/local/sbin/nginx"

# Ensure nginx
if (::File.stat(check_stowed).ino != ::File.stat(check_installed).ino rescue true)
  # Download archive
  remote_file downloaded do
    source url
  end

  # Install nginx
  bash "install_nginx" do
    cwd cache
    code <<-HERE
      set -e -x
      (cd #{stow} && stow -D #{name}-*) || true
      rm -rf #{installed}
      rm -rf #{extracted}
      dtrx -n #{downloaded}
      (cd #{extracted} && ./configure --prefix=#{installed} && make && make install && cd #{stow} && stow #{name_and_version})
    HERE
  end
end
