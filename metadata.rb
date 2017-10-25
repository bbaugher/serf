name             'serf'
maintainer       'Bryan Baugher'
maintainer_email 'Bryan.Baugher@Cerner.com'
license          'The MIT License (MIT)'
description      'Installs/Configures serf'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

%w{ ubuntu centos }.each do |os|
  supports os
end

depends 'logrotate'

version          '1.3.0'
