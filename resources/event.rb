#
# Cookbook Name:: serf
# Resource:: event
#

actions :create
default_action :create

attribute :event_name, :kind_of => String, :name_attribute => true
attribute :coalesce, :kind_of => [TrueClass, FalseClass], :default => true
attribute :rpc_addr, :kind_of => [String, NilClass]
attribute :rpc_auth, :kind_of => [String, NilClass]
attribute :payload, :kind_of => [String, NilClass]

attr_accessor :exists
