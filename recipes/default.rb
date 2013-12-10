# coding: UTF-8 
#
# Cookbook Name:: serf
# Recipe:: default
#

require 'json'

# TODO: Support other distributions besides 'linux'
node.default["serf"]["binary_url"] = File.join node["serf"]["base_binary_url"], "#{node["serf"]["version"]}_linux_#{node["serf"]["arch"]}.zip"

serfBinDirectory = File.join node["serf"]["base_directory"], "bin"
serfBinary = File.join serfBinDirectory, "serf"

serfEventHandlersDirectory = File.join node["serf"]["base_directory"], "event_handlers"

serfInternalConfDirectory = File.join node["serf"]["base_directory"], "config"
serfAgentConf = File.join serfInternalConfDirectory, "serf_agent.json"

serfInternalLogDirectory = File.join node["serf"]["base_directory"], "logs"
serfAgentLogFile = File.join serfInternalLogDirectory, "agent.log"

binaryZipFileName = "serf-#{node["serf"]["version"]}_linux_#{node["serf"]["arch"]}.zip"
cachedZipFilePath = File.join Chef::Config[:file_cache_path], binaryZipFileName

# Create serf directories

# /opt/serf
directory node["serf"]["base_directory"] do
  mode 00755
  recursive true
  action :create
end

# /opt/serf/event_handlers
directory serfEventHandlersDirectory do
  mode 00755
  recursive true
  action :create
end

# /opt/serf/bin
directory serfBinDirectory do
  mode 00755
  recursive true
  action :create
end

# /opt/serf/config
directory serfInternalConfDirectory do
  mode 00755
  recursive true
  action :create
end

# /opt/serf/log
directory serfInternalLogDirectory do
  mode 00755
  recursive true
  action :create
end

# Create unix expected directories (/etc/serf, /var/log/serf, ...)

# /var/log/serf
link node["serf"]["log_directory"] do
  to serfInternalLogDirectory
end

# /etc/serf
link node["serf"]["conf_directory"] do
  to serfInternalConfDirectory
end

# Download binary zip file
remote_file cachedZipFilePath do
  action :create_if_missing
  source node["serf"]["binary_url"]
  mode 00644
  backup false
end

# Make sure unzip is available to us
package "unzip" do
  action :install
end

# Unzip serf binary
execute "unzip serf binary" do
  cwd serfBinDirectory
  
  # -q = quiet, -o = overwrite existing files
  command "unzip -qo #{cachedZipFilePath}"
  
  notifies :restart, "service[serf]"
  only_if do
    if File.exists? serfBinary
      !`#{serfBinary} version`.chomp.include? "Serf v#{node["serf"]["version"]}" 
    else
      true
    end
  end
end

# Ensure serf binary has correct permissions
file serfBinary do
  mode 00755
end

# Add serf to /usr/bin so it is on our path
link "/usr/bin/serf" do
  to serfBinary
end

# Add entry to logrotate.d to log roll agents log files daily
template "/etc/logrotate.d/serf_agent" do
  source  "serf_log_roll.erb"
  mode 00755
  variables(:agent_log_file => serfAgentLogFile)
  backup false
end

# Download and configure specified event handlers
node["serf"]["event_handlers"].each do |event_handler|
  
  unless event_handler.is_a? Hash
    raise "Event handler [#{event_handler}] is required to be a hash"
  end
  
  event_handler_command = ""
  if event_handler.has_key? "event_type"
    event_handler_option << "#{event_handler["event_type"]}="
  end
  
  if event_handler.has_key? "url"
    event_handler_path =  File.join serfEventHandlersDirectory, File.basename(event_handler["url"])
    event_handler_command << event_handler_path
    
    # Download event handler script
    remote_file event_handler_path do
      source event_handler["url"]
      mode 00755
      backup false
    end
    
  else
    raise "Event handler [#{event_handler}] has no 'url'"
  end
  
  node["serf"]["agent"]["event_handlers"].push event_handler_command
end

# Create serf_agent.json
template serfAgentConf do
  source  "serf_agent.json.erb"
  mode 00755
  variables( :agent_json => node["serf"]["agent"].to_hash.to_json)
  backup false
end

# Create init.d script
template "/etc/init.d/serf" do
  source  "serf_service.erb"
  mode  00755
  variables(:agent_binary => serfBinary, :agent_log_file => serfAgentLogFile, 
            :agent_config_file => serfAgentConf)
  backup false
  notifies :restart, "service[serf]"
end

# Start agent service
service "serf" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
