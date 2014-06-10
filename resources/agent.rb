actions :create, :delete, :start, :stop, :restart
default_action :create

attribute :name, :name_attribute => true, :kind_of => String,
            :required => true, :default => "serf"
attribute :group, :kind_of => String,
            :required => true, :default => "serf"
attribute :user, :kind_of => String,
            :required => true, :default => "serf"
attribute :base_directory, :kind_of => String,
            :required => true, :default => "/opt/serf"
attribute :log_directory, :kind_of => String,
            :required => true, :default => "/var/log/serf"
attribute :conf_directory, :kind_of => String,
            :required => true, :default => "/etc/serf"
attribute :agent, :kind_of => Hash,
            :required => false, :default => {}

attr_accessor :exists

# Covers 0.10.8 and earlier
def initialize(*args)
  super
  @action = :create
end