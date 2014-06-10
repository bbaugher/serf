# coding: UTF-8 
#
# Cookbook Name:: serf
# Recipe:: default
#

# Initializes the SerfHelper class by giving it access to `node`
helper = SerfHelper.new self

# Create serf user/group
group node["serf"]["group"] do
  action :create
end
  
user node["serf"]["user"] do
  gid node["serf"]["group"]
end

# Create serf directories

# /opt/serf
directory node["serf"]["base_directory"] do
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode 00755
  recursive true
  action :create
end

# /opt/serf/event_handlers
directory helper.getEventHandlersDirectory do
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode 00755
  recursive true
  action :create
end

# /opt/serf/bin
directory helper.getBinDirectory do
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode 00755
  recursive true
  action :create
end

# /opt/serf/config
directory helper.getHomeConfigDirectory do
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode 00755
  recursive true
  action :create
end

# /opt/serf/log
directory helper.getHomeLogDirectory do
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode 00755
  recursive true
  action :create
end

# Create unix expected directories (/etc/serf, /var/log/serf, ...)

# /var/log/serf
link node["serf"]["log_directory"] do
  to helper.getHomeLogDirectory
end

# /etc/serf
link node["serf"]["conf_directory"] do
  to helper.getHomeConfigDirectory
end

# Download binary zip file
remote_file helper.getZipFilePath do
  action :create_if_missing
  source node["serf"]["binary_url"]
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode 00644
  backup false
end

# Make sure unzip is available to us
package "unzip" do
  action :install
end

# check validity of agent parameter
agents = nil 
if node["serf"]["agent"].is_a? Hash
  agents = [ node["serf"]["agent"] ]
  agents[0]["name"] = "serf"
else
   raise "'agent' attribute needs to be either a hash or an array" unless node["serf"]["agent"].is_a? Array
   agents = node["serf"]["agent"]
end


# Unzip serf binary
execute "unzip serf binary" do
  
  user node["serf"]["user"]
  cwd helper.getBinDirectory
  
  # -q = quiet, -o = overwrite existing files
  command "unzip -qo #{helper.getZipFilePath}"
  notifies :run, "ruby_block[reload_agents]", :immediately 
  only_if { 
      currentVersion = helper.getSerfInstalledVersion
      if currentVersion != node["serf"]["version"]
        Chef::Log.info "Changing Serf Installation from [#{currentVersion}] to [#{node["serf"]["version"]}]"
      end
      currentVersion != node["serf"]["version"]
  }
end

ruby_block "reload_agents" do
  block do
    agents.each { |agent|
      raise "Each serf agent must have a name" unless agent.has_key?("name")

      serf_agent = Chef::Resource::SerfAgent.new(agent["name"], run_context)
      serf_agent.params = {
        :user => node["serf"]["user"],
        :group => node["serf"]["group"],
        :base_directory => node["serf"]["base_directory"],
        :log_directory => node["serf"]["log_directory"],
        :conf_directory => node["serf"]["conf_directory"],
        :agent => agent
      }
      serf_agent.run_action(:restart)
    }
  end
  action :nothing 
end

# Ensure serf binary has correct permissions
file helper.getSerfBinary do
  group node["serf"]["group"]
  owner node["serf"]["user"]
  mode 00755
end

# Add serf to /usr/bin so it is on our path
link "/usr/bin/serf" do
  to helper.getSerfBinary
end

# Download and configure specified event handlers
node["serf"]["event_handlers"].each do |event_handler|
  
  unless event_handler.is_a? Hash
    raise "Event handler [#{event_handler}] is required to be a hash"
  end

  if agents.length() == 1
    event_handler["name"] = "serf" unless event_handler.has_key?("name")
  end
  
  event_handler_command = ""
  if event_handler.has_key? "event_type"
    event_handler_command << "#{event_handler["event_type"]}="
  end
  
  if event_handler.has_key? "url"
    event_handler_path = File.join(helper.getEventHandlersDirectory, event_handler["name"], File.basename(event_handler["url"]))
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

  agents.find { |agent| agent["name"] == event_handler["name"] }["event_handlers"] << event_handler_command
end

# install agents
agents.each { |agent|
  serf_agent agent["name"] do
    user            node["serf"]["user"]
    group           node["serf"]["group"]
    base_directory  node["serf"]["base_directory"]
    log_directory   node["serf"]["log_directory"]
    conf_directory  node["serf"]["conf_directory"]
    agent           agent
    action [ :create, :start ] 
  end
}