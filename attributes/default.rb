# coding: UTF-8 

default["serf"]["user"] = "serf"
default["serf"]["group"] = "serf"

default["serf"]["agent"] = {}
default["serf"]["event_handlers"] = []

default["serf"]["base_binary_url"] = "https://dl.bintray.com/mitchellh/serf/"
default["serf"]["version"] = "0.3.0"
default['serf']['arch'] = kernel['machine'] =~ /x86_64/ ? "amd64" : "386"

default["serf"]["base_directory"] = "/opt/serf"
default["serf"]["log_directory"] = "/var/log/serf"
default["serf"]["conf_directory"] = "/etc/serf"
   