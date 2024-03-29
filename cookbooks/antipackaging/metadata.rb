name 'antipackaging'
version '0.0.1'
depends 'stow', '~> 0.0.1'
description 'Examples of avoiding packaging like a barbarian.'
maintainer_email 'igal@pragmaticraft.com'
maintainer 'Igal Koshevoy'
license 'MIT'
supports 'ubuntu', '>= 10.04'
recipe 'antipackaging::standalone', 'Example of a standalone recipe to build and stow software'
recipe 'antipackaging::standalone', 'Example of using recipe to install software'
recipe 'antipackaging::stow', 'Example of using custom resource to install software'
recipe 'antipackaging::uninstall', 'Example of using custom resource to uninstall software'
