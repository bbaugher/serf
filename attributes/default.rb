# coding: UTF-8 

default["serf"]["event_handlers"] = []

default["serf"]["join_addresses"] = []

default["serf"]["role"] = ""
default["serf"]["node"] = node["fqdn"]

default["serf"]["base_binary_url"] = "https://dl.bintray.com/mitchellh/serf/"
default["serf"]["version"] = "0.1.1"
default['serf']['arch'] = kernel['machine'] =~ /x86_64/ ? "amd64" : "386"

default["serf"]["rpc_port"] = 7373
default["serf"]["bind_port"] = 7946

default["serf"]["log_level"] = "info"

default["serf"]["base_directory"] = "/opt/serf"
default["serf"]["log_directory"] = "/var/log/serf"
