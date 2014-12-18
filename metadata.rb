name             'packer'
maintainer       '18F'
maintainer_email 'sean.herron@gsa.gov'
license          'Public Domain'
description      'Installs/Configures packer'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{ apt }.each do |cookbook|
  depends cookbook
end

supports 'ubuntu'
