# coding: UTF-8

default["serf"]["user"] = "serf"
default["serf"]["group"] = "serf"

default["serf"]["on_config_change"] = :reload

default["serf"]["agent"] = {}
default["serf"]["agent"]["event_handlers"] = []

default["serf"]["event_handlers"] = []

default["serf"]["version"] = "0.7.0"
default['serf']['arch'] = node['kernel']['machine'] =~ /x86_64/ ? "amd64" : "386"

default["serf"]["base_binary_url"] = "https://releases.hashicorp.com/serf/"
default["serf"]["binary_url"] = nil

default["serf"]["base_directory"] = "/opt/serf"
default["serf"]["log_directory"] = "/var/log/serf"
default["serf"]["conf_directory"] = "/etc/serf"

default["serf"]["init_info"]["Provides"] = "serf"
default["serf"]["init_info"]["Short-Description"] = "Serf agent"
default["serf"]["init_info"]["Default-Start"] = "3 4 5"
default["serf"]["init_info"]["Default-Stop"] = "0 1 2 6"
default["serf"]["init_info"]["Required-Start"] = ""
default["serf"]["init_info"]["Required-Stop"] = ""
default["serf"]["init_info"]["Should-Start"] = ""
default["serf"]["init_info"]["Should-Stop"] = ""
default["serf"]["init_info"]["chkconfig"] = "2345 95 20"
default["serf"]["init_info"]["description"] = "Serf agent"
default["serf"]["init_info"]["processname"] = "serf"
