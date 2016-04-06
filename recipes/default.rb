# coding: UTF-8
#
# Cookbook Name:: serf
# Recipe:: default
#

include_recipe 'logrotate'

# Initializes the serf_helper class by giving it access to `node`
helper = SerfHelper.new node

# Create serf user/group
group node["serf"]["group"] do
  action :create
end

user node["serf"]["user"] do
  gid node["serf"]["group"]
end

# Create serf directories
[
  helper.get_home_log_directory,
  helper.get_home_config_directory,
  helper.get_bin_directory,
  helper.get_event_handlers_directory
].each do |dir|
  directory dir do
    group node["serf"]["group"]
    owner node["serf"]["user"]
    mode 00755
    recursive true
    action :create
  end
end

# /var/log/serf
link node["serf"]["log_directory"] do
  to helper.get_home_log_directory
end

# /etc/serf
link node["serf"]["conf_directory"] do
  to helper.get_home_config_directory
end

# Download binary zip file
remote_file helper.get_zip_file_path do
  action :create_if_missing
  source helper.get_binary_url
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode 00644
  backup false
end

# Make sure unzip is available to us
package "unzip" do
  action :install
end

# Unzip serf binary
execute "unzip serf binary" do

  user node["serf"]["user"]
  cwd helper.get_bin_directory

  # -q = quiet, -o = overwrite existing files
  command "unzip -qo #{helper.get_zip_file_path}"

  notifies :restart, "service[serf]"
  only_if do
    current_version = helper.get_serf_installed_version
    if current_version != node["serf"]["version"]
      Chef::Log.info "Changing Serf Installation from [#{current_version}] to [#{node["serf"]["version"]}]"
    end
    current_version != node["serf"]["version"]
  end
end

# Ensure serf binary has correct permissions
file helper.get_serf_binary do
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode 00755
end

# Add serf to /usr/bin so it is on our path
link "/usr/bin/serf" do
  to helper.get_serf_binary
end

logrotate_app 'serf' do
  cookbook  'logrotate'
  path      [helper.get_agent_log]
  options   ['compress', 'copytruncate', 'dateext', 'delaycompress', 'missingok']
  create    "644 #{node['serf']['user']} #{node['serf']['group']}"
  frequency 'daily'
  rotate    7
end

# Download and configure specified event handlers
node["serf"]["event_handlers"].each do |event_handler|

  unless event_handler.is_a? Hash
    raise "Event handler [#{event_handler}] is required to be a hash"
  end

  event_handler_command = ""
  if event_handler.has_key? "event_type"
    event_handler_command << "#{event_handler["event_type"]}="
  end

  if event_handler.has_key? "url"
    event_handler_path =  File.join helper.get_event_handlers_directory, File.basename(event_handler["url"])
    event_handler_command << event_handler_path

    # Download event handler script
    remote_file event_handler_path do
      source event_handler["url"]
      group node["serf"]["group"]
      owner node["serf"]["user"]
      mode 00755
      backup false
    end

  else
    raise "Event handler [#{event_handler}] has no 'url'"
  end

  node.default["serf"]["agent"]["event_handlers"] << event_handler_command
end

# Create serf_agent.json
template helper.get_agent_config do
  source  "serf_agent.json.erb"
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode 00755
  variables( agent_json: helper.get_agent_json)
  backup false
  notifies node["serf"]["on_config_change"], "service[serf]"
end

# Create init.d script
template "/etc/init.d/serf" do
  source  "serf_service.erb"
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode  00755
  variables(helper: helper)
  backup false
  notifies :restart, "service[serf]"
end

# Ensure everything is owned by serf user/group
execute "chown -R #{node["serf"]["user"]}:#{node["serf"]["group"]} #{node["serf"]["base_directory"]}"

# Start agent service
service "serf" do
  supports status: true, restart: true, reload: true
  action [ :enable, :start ]
end
