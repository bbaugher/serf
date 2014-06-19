require 'json'

# Support whyrun
def whyrun_supported?
    true
end

action :create do
    if @current_resource.exists
        Chef::Log.info "#{ @new_resource } already exists - nothing to do."
    else
        converge_by("Create #{ @new_resource }") do
            create_serf_agent
        end
    end
end

action :start do
    if @current_resource.exists
        converge_by("Start #{ @new_resource }") do
            start_serf_agent
        end
    else
        Chef::Log.info "#{ @current_resource } doesn't exist - can't start."
    end
end

action :restart do
    if @current_resource.exists
        converge_by("Restart #{ @new_resource }") do
            restart_serf_agent
        end
    else
        Chef::Log.info "#{ @current_resource } doesn't exist - can't restart."
    end
end

action :stop do
    if @current_resource.exists
        converge_by("Stop #{ @new_resource }") do
            stop_serf_agent
        end
    else
        Chef::Log.info "#{ @current_resource } doesn't exist - can't stop."
    end
end

action :delete do
    if @current_resource.exists
        converge_by("Delete #{ @new_resource }") do
            delete_serf_agent
        end
    else
        Chef::Log.info "#{ @current_resource } doesn't exist - can't delete."
    end
end

def load_current_resource
    @current_resource = Chef::Resource::SerfAgent.new(@new_resource.name)
    @current_resource.name(@new_resource.name)
    @current_resource.group(@new_resource.group)
    @current_resource.user(@new_resource.user)
    @current_resource.base_directory(@new_resource.base_directory)
    @current_resource.log_directory(@new_resource.log_directory)
    @current_resource.conf_directory(@new_resource.conf_directory)
    @current_resource.agent(@new_resource.agent)
  
    if agent_exists?
        @current_resource.exists = true
    end

    @current_resource
end

private
    def agent_exists?
        return false unless ::File.exist?(::File.join(current_resource.conf_directory, "#{current_resource.name}.json") )
        return false unless ::File.exist?(::File.join("/etc/init.d", "#{current_resource.name}") )
        return false unless ::File.exist?(::File.join("/etc/logrotate.d/", "serf_agent_#{current_resource.name}") )
        current_agent = JSON.parse(::File.read(::File.join(current_resource.conf_directory, "#{current_resource.name}.json") ));
        new_resource.agent == current_agent
    end

    def create_serf_agent
        if new_resource.name != "serf"
            link ::File.join(new_resource.base_directory, "bin", new_resource.name) do
              to ::File.join(new_resource.base_directory, "bin", "serf")
            end
        end

        template "/etc/logrotate.d/serf_agent_#{new_resource.name}" do
            source  "serf_log_roll.erb"
            group new_resource.group
            owner new_resource.user
            mode 00755
            variables(:agent_log_file => ::File.join(current_resource.log_directory, "#{current_resource.name}.log"))
            backup false
        end

        service new_resource.name do
            supports :status => true, :restart => true, :reload => true
            action :nothing
        end

        template ::File.join(new_resource.conf_directory, "#{new_resource.name}.json") do
            source  "serf_agent.json.erb"
            group new_resource.group
            owner new_resource.user
            mode 00755
            variables( :agent_json => JSON.pretty_generate(new_resource.agent.to_hash.reject {|key, value| key == "name"}) )
            backup false
            notifies :restart, "service[#{new_resource.name}]"
        end

        template "/etc/init.d/#{new_resource.name}" do
            source  "serf_service.erb"
            group new_resource.group
            owner new_resource.user
            mode  00755
            variables(
                :serf_name => new_resource.name, 
                :serf_binary => ::File.join(new_resource.base_directory, "bin", new_resource.name), 
                :serf_log => ::File.join(new_resource.log_directory, "#{current_resource.name}.log"),
                :serf_conf => ::File.join(new_resource.conf_directory, "#{new_resource.name}.json"),
                :serf_user => new_resource.user)
            backup false
            notifies :restart, "service[#{new_resource.name}]"
        end

        # Ensure everything is owned by serf user/group
        execute "chown -R #{new_resource.user}:#{new_resource.group} #{new_resource.base_directory}"
    end

    def stop_serf_agent
        service new_resource.name do
            action :stop
        end
    end

    def start_serf_agent
        service new_resource.name do
            supports :status => true, :restart => true, :reload => true
            action [ :enable, :start ]
        end
    end

    def restart_serf_agent
        service new_resource.name do
            supports :status => true, :restart => true, :reload => true
            action [ :stop, :reload, :start ]
        end
    end

    def delete_serf_agent
        stop_serf_agent

        link ::File.join(current_resource.base_directory, "bin", current_resource.name) do
          action :delete
        end

        file "/etc/logrotate.d/serf_agent_#{current_resource.name}" do
          action :delete
        end

        file ::File.join(current_resource.conf_directory, "#{current_resource.name}.json") do
          action :delete
        end

        file ::File.join(current_resource.conf_directory, "/etc/init.d/#{current_resource.name}") do
          action :delete
        end
    end