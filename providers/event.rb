#
# Cookbook Name:: serf
# Provider:: event
#

use_inline_resources

def whyrun_supported?
  true
end

action :create do
  converge_by("Create #{@new_resource}") do
    serf_cmd = "serf event -coalesce=#{new_resource.coalesce}"
    serf_cmd << " -rpc-addr=#{new_resource.rpc_addr}" if new_resource.rpc_addr
    serf_cmd << " -rpc-auth=#{new_resource.rpc_auth || node['serf']['agent']['rpc_auth']}" if new_resource.rpc_auth || node['serf']['agent']['rpc_auth']
    serf_cmd << " #{new_resource.event_name || new_resource.name}"
    serf_cmd << " #{new_resource.payload}" if new_resource.payload

    execute "Fire serf event #{new_resource.name}" do
      command serf_cmd
    end
  end
end
