# coding: UTF-8
require 'json'

class Chef::Recipe::SerfHelper

  SERF_VERSION_REGEX = /^Serf v\d.\d.\d/
  VERSION_REGEX = /\d.\d.\d/

  attr_accessor :node

  def initialize(node)
    @node = node
  end

  def get_bin_directory
     File.join node["serf"]["base_directory"], "bin"
  end

  def get_serf_binary
    File.join get_bin_directory, "serf"
  end

  def get_event_handlers_directory
    File.join node["serf"]["base_directory"], "event_handlers"
  end

  def get_home_config_directory
    File.join node["serf"]["base_directory"], "config"
  end

  def get_agent_config
    File.join get_home_config_directory, "serf_agent.json"
  end

  def get_home_log_directory
    File.join node["serf"]["base_directory"], "logs"
  end

  def get_agent_log
    File.join get_home_log_directory, "agent.log"
  end

  def get_agent_json
    JSON.pretty_generate(node["serf"]["agent"].to_hash)
  end

  def get_zip_file_path
    File.join Chef::Config[:file_cache_path], get_binary_filename
  end

  def get_binary_url
    node["serf"]["binary_url"] ||
    File.join(node["serf"]["base_binary_url"], node["serf"]["version"], get_binary_filename)
  end

  def get_serf_installed_version
    unless File.exists? get_serf_binary
      return "NONE"
    end

    version_output = `#{get_serf_binary} version`.chomp
    serf_match = SERF_VERSION_REGEX.match(version_output)

    if serf_match.size == 0
      raise "Unable to parse version from `serf version` output [#{version_output}]"
    end

    version_match = VERSION_REGEX.match(serf_match[0])

    # Should never happen
    if version_match.size == 0
      raise "Unable to parse version from `serf version` output [#{version_output}]"
    end

    version_match[0]
  end

  private

  def get_binary_filename
    "serf_#{node["serf"]["version"]}_linux_#{node["serf"]["arch"]}.zip"
  end
end
