# coding: UTF-8

require 'spec_helper'

describe user('serf') do
  it { should exist }
  it { should belong_to_group 'serf' }
end

describe service('serf') do
  it { should be_running   }
end

describe file('/etc/serf/serf_agent.json') do
  it { should be_file }
  it { should be_owned_by 'serf' }
  it { should be_grouped_into 'serf' }
  it { should contain '"log_level": "info"' }
end

describe file('/etc/init.d/serf') do
  it { should be_file }
  it { should be_owned_by 'serf' }
  it { should be_grouped_into 'serf' }
  it { should contain 'Provides: serf' }
  it { should contain 'Default-Start: 3 4 5' }
  it { should contain 'Default-Stop: 0 1 2 6' }
  it { should contain 'fake: value' }
  it { should contain 'chkconfig: 2345 95 20' }
end
