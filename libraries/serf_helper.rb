# coding: UTF-8
require 'json'

class Chef::Recipe::SerfHelper < Chef::Recipe

  SERF_VERSION_REGEX = /^Serf v\d.\d.\d/
  VERSION_REGEX = /\d.\d.\d/

  # Initializes the helper class
  def initialize chef_recipe
    super(chef_recipe.cookbook_name, chef_recipe.recipe_name, chef_recipe.run_context)

    # TODO: Support other distributions besides 'linux'
    node.default["serf"]["binary_url"] = File.join node["serf"]["base_binary_url"], "#{node["serf"]["version"]}", "serf_#{node["serf"]["version"]}_linux_#{node["serf"]["arch"]}.zip"

    current_version = get_serf_installed_version
    if current_version
      Chef::Log.info "Current Serf Version : [#{current_version}]"
    end
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
    File.join Chef::Config[:file_cache_path], "serf-#{node["serf"]["version"]}_linux_#{node["serf"]["arch"]}.zip"
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

end
