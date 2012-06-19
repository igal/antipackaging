# Install stow
package "stow"

# Define stow directory
stow_directory = "/usr/local/stow"

# Create stow directory
directory stow_directory

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
cache_directory = Chef::Config[:file_cache_path]
downloaded_file = ::File.join(cache_directory, ::File.basename(url))
extracted_directory = ::File.join(cache_directory, name_and_version)
installed_directory = ::File.join(stow_directory, name_and_version)
check_installed = ::File.join(installed_directory, check) # <- "/usr/local/stow/ngnix-1.3.1/sbin/ngnix"
check_stowed = ::File.join(stow_directory, "..", check) # <- "/usr/local/sbin/nginx"

# Ensure nginx
if (::File.stat(check_stowed).ino != ::File.stat(check_installed).ino rescue true)
  # Download archive
  remote_file downloaded_file do
    source url
  end

  # Install nginx
  bash "install_nginx" do
    cwd cache_directory
    code <<-HERE
      set -e -x
      (cd #{stow_directory} && stow -D #{name}-*) || true
      rm -rf #{installed_directory}
      rm -rf #{extracted_directory}
      dtrx -n #{downloaded_file}
      (cd #{extracted_directory} && ./configure --prefix=#{installed_directory} && make && make install && cd #{stow_directory} && stow #{name_and_version})
    HERE
  end
end
