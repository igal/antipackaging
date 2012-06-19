actions :install, :uninstall
default_action :install

# Name of software to install, e.g. "ngnix".
attribute :name, :kind_of => String, :name_attribute => true

# Version of software to install, e.g. "1.3.1".
attribute :version, :kind_of => String

# Basename of file to check to determine if the software is installed. E.g. "sbin/nginx" will compare "/usr/local/sbin/nginx" against "/usr/local/stow/nginx-1.3.1/sbin/nginx".
attribute :check, :kind_of => String, :required => true

# URL to download software from.
attribute :url, :kind_of => String

# Install the software with this shell command.
#
# If the argument is a String and a "@@PREFIX@@" string is present, it will be replaced by the path that the software should be installed into, e.g.:
#
#     install "./configure --prefix=@@PREFIX@@ && make && make install"
#
# If the argument is a Proc, then it will be called with the prefix as its first argument, e.g.:
#
#     install lambda { |prefix| "./configure --prefix=#{prefix} && make && make install" }
attribute :install, :kind_of => [String, Proc]

# Placeholder to use in "install" command. Defaults to "@@PREFIX@@".
attribute :placeholder, :kind_of => String, :default => "@@PREFIX@@"

# Separator of name and version. Defaults to "-".
attribute :separator, :kind_of => String, :default => "-"

# Array of strings with the names of packages to install, as a convenience.
attribute :dependencies, :kind_of => Array
