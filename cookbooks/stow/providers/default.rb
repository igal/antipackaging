# Structure representing paths and other properties of a stow resource, which
# can be reused by both the :install and :uninstall actions. See the actions
# definitions below to see how this is used.
StowStruct = Struct.new(:name, :version, :name_and_version, :separator, :url,
      :install, :dependencies, :downloaded_file, :extracted_directory,
      :installed_directory, :stow_directory, :cache_directory, :check,
      :check_installed, :check_stowed, :placeholder) do

  # Return new structure parsed from a +node+ and +new_resource+.
  def self.parse(node, new_resource)
    struct = self.new
    struct.name = new_resource.name
    struct.version = new_resource.version
    struct.url = new_resource.url
    struct.separator = new_resource.separator
    struct.placeholder = new_resource.placeholder
    struct.dependencies = new_resource.dependencies
    struct.install = new_resource.install

    struct.stow_directory = node.stow.directory
    struct.cache_directory = Chef::Config[:file_cache_path]
    struct.name_and_version = [struct.name, struct.separator, struct.version].join if struct.version
    struct.downloaded_file = ::File.join(struct.cache_directory, ::File.basename(struct.url)) if struct.url
    struct.extracted_directory = ::File.join(struct.cache_directory, struct.name_and_version) if struct.version
    struct.installed_directory = ::File.join(struct.stow_directory, struct.name_and_version) if struct.version
    struct.check = new_resource.check
    struct.check_installed = ::File.join(struct.installed_directory, struct.check) if struct.installed_directory
    struct.check_stowed = ::File.join(struct.stow_directory, "..", struct.check)
    return struct
  end
end

action :install do
  # Ensure all required arguments were specified
  %w[version check url install].each do |name|
    unless new_resource.send(name)
      raise ArgumentError, "stow: '#{name}' must be specified"
    end
  end

  struct = StowStruct.parse(node, new_resource)

  # Install tools needed for extracting and stowing
  package "dtrx"
  package "stow"
  directory struct.stow_directory

  # Only build new software if it's not already present
  if (::File.stat(struct.check_installed).ino != ::File.stat(struct.check_stowed).ino rescue true)
    # Download source
    remote_file struct.downloaded_file do
      source struct.url
    end

    # Install dependencies
    if struct.dependencies
      struct.dependencies.each do |name|
        package name
      end
    end

    # Install software
    bash "install_#{struct.name_and_version}" do
      # Figure out what commands to run to install the software
      installer =
        case struct.install
        when String
          # When given a string, substitute the placeholder ("@@PREFIX@@") with name of install directory.
          struct.install.gsub(/#{struct.placeholder}/, struct.installed_directory)
        when Proc
          # When given a proc, call it with the name of the install directory.
          struct.install.call(struct.installed_directory)
        else
          raise ArgumentError, "stow: 'install' must be a String or Proc, not: #{struct.install.class}"
        end

      # Go into directory with the downloaded file
      cwd struct.cache_directory

      code <<-HERE
        set -e -x
        (cd #{struct.stow_directory} && stow -D #{struct.name}#{struct.separator}*) || true
        rm -rf #{struct.installed_directory}
        rm -rf #{struct.extracted_directory}
        dtrx -n #{struct.downloaded_file}
        (cd #{struct.extracted_directory} && #{installer} && cd #{struct.stow_directory} && stow #{struct.name_and_version})
      HERE
    end
  end
end

action :uninstall do
  struct = StowStruct.parse(node, new_resource)

  execute "uninstall_#{struct.name}" do
    only_if { ::File.exist?(struct.check_stowed) }

    cwd struct.stow_directory

    if struct.name_and_version
      command "stow -D #{struct.name_and_version}"
    else
      command "stow -D #{struct.name}#{struct.separator}*"
    end
  end
end
