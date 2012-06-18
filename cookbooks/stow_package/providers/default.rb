StowPaths = Struct.new(:name, :version, :name_and_version, :separator, :url, :downloaded, :extracted, :installed, :stow, :cache, :check, :check_installed, :check_stowed, :placeholder) do
  def self.parse(node, resource)
    o = self.new
    o.name = resource.name
    o.version = resource.version
    o.url = resource.url
    o.separator = resource.separator
    o.placeholder = resource.placeholder

    o.stow = node.stow.dir
    o.cache = Chef::Config[:file_cache_path]
    o.name_and_version = [o.name, o.separator, o.version].join if o.version
    o.downloaded = ::File.join(o.cache, ::File.basename(o.url)) if o.url
    o.extracted = ::File.join(o.cache, o.name_and_version) if o.version
    o.installed = ::File.join(o.stow, o.name_and_version) if o.version
    o.check = resource.check
    o.check_installed = ::File.join(o.installed, o.check) if o.installed
    o.check_stowed = ::File.join(o.stow, "..", o.check)
    return o
  end
end

action :install do
  %w[version check url install].each do |name|
    unless new_resource.send(name)
      raise ArgumentError, "stow: '#{name}' must be specified"
    end
  end

  s = StowPaths.parse(node, new_resource)

  package "dtrx"
  package "stow"
  directory node.stow.dir

  if (::File.stat(s.check_installed).ino != ::File.stat(s.check_stowed).ino rescue true)
    # Download
    remote_file s.downloaded do
      source s.url
    end

    # Dependencies
    if new_resource.dependencies
      new_resource.dependencies.each do |name|
        package name
      end
    end

    # Install
    bash "install_#{s.name_and_version}" do
      installer =
        case new_resource.install
        when String
          new_resource.install.gsub(/#{s.placeholder}/, s.installed)
        when Proc
          new_resource.install.call(s.installed)
        else
          raise ArgumentError, "stow: 'install' must be a String or Proc, not: #{new_resource.install.class}"
        end
      cwd s.cache
      code <<-HERE
        set -e -x
        (cd #{s.stow} && stow -D #{s.name}#{s.separator}*) || true
        rm -rf #{s.installed}
        rm -rf #{s.extracted}
        dtrx -n #{s.downloaded}
        (cd #{s.extracted} && #{installer} && cd #{s.stow} && stow #{s.name_and_version})
      HERE
    end
  end
end

action :uninstall do
  s = StowPaths.parse(node, new_resource)
  execute "uninstall_#{new_resource.name}" do
    only_if { ::File.exist?(s.check_stowed) }
    cwd s.stow
    if s.name_and_version
      command "stow -D #{s.name_and_version}"
    else
      command "stow -D #{s.name}#{s.separator}*"
    end
  end
end
