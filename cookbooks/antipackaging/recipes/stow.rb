# Same as `standalone.rb` recipe, but now using a custom resource.
stow_package "nginx" do
  version "1.3.1"
  check "sbin/nginx"
  url "https://s3.amazonaws.com/igalfiles/#{@name}-#{@version}.tar.gz"
  install "./configure --prefix=@@PREFIX@@ && make && make install"
  ### Same as above using a Ruby lambda:
  # install lambda { |prefix| "./configure --prefix=#{prefix} && make && make install" }
  dependencies %w[build-essential libpcre3-dev]
end

# Same resource, but for different software with a trickier installation.
stow_package "ts" do
  version "0.7.3"
  check "bin/ts"
  url "https://s3.amazonaws.com/igalfiles/#{@name}-#{@version}.tar.gz"
  # Software doesn't use `./configure`, so use Ruby to escape `prefix` path and use `sed` to alter `Makefile`:
  install lambda { |prefix| "sed -i 's/^PREFIX\?=\\/usr\\/local$/PREFIX?=#{prefix.gsub(/\//, '\\/')}/' Makefile && make && make install" }
  ### Same as above using a fancy, newfangled sed that allows custom search delimiters:
  # install lambda { |prefix| "sed -i 's|^PREFIX\?=\/usr\/local$|PREFIX?=#{prefix}|' Makefile && make && make install" }
  dependencies %w[build-essential]
end
