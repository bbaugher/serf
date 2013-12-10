# coding: UTF-8 

default["serf"]["agent"] = {}
default["serf"]["agent"]["event_handlers"] = []

default["serf"]["event_handlers"] = []

default["serf"]["base_binary_url"] = "https://dl.bintray.com/mitchellh/serf/"
default["serf"]["version"] = "0.2.1"
default['serf']['arch'] = kernel['machine'] =~ /x86_64/ ? "amd64" : "386"

default["serf"]["base_directory"] = "/opt/serf"
default["serf"]["log_directory"] = "/var/log/serf"
default["serf"]["conf_directory"] = "/etc/serf"
