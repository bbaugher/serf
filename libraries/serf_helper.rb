# coding: UTF-8
require 'json'

class Chef::Recipe::SerfHelper < Chef::Recipe
  
  SERF_VERSION_REGEX = /^Serf v\d.\d.\d/
  VERSION_REGEX = /\d.\d.\d/
  
  # Initializes the helper class
  def initialize chefRecipe
    super(chefRecipe.cookbook_name, chefRecipe.recipe_name, chefRecipe.run_context)
    
    # TODO: Support other distributions besides 'linux'
    node.default["serf"]["binary_url"] = File.join node["serf"]["base_binary_url"], "#{node["serf"]["version"]}_linux_#{node["serf"]["arch"]}.zip"
    
    currentVersion = getSerfInstalledVersion
    if currentVersion
      Chef::Log.info "Current Serf Version : [#{currentVersion}]"
    end
  end
  
  def getBinDirectory
     File.join node["serf"]["base_directory"], "bin"
  end
  
  def getSerfBinary
    File.join getBinDirectory, "serf"
  end

  def getSerfAgentBinary(agent_name)
    if agent_name.nil?
      getSerfBinary
    else
      File.join getBinDirectory, agent_name
    end
  end
  
  def getEventHandlersDirectory
    File.join node["serf"]["base_directory"], "event_handlers"
  end
  
  def getHomeConfigDirectory
    File.join node["serf"]["base_directory"], "config"
  end
  
  def getAgentConfig(agent_name)
    if agent_name.nil?
      File.join getHomeConfigDirectory, "serf_agent.json"
    else
      File.join getHomeConfigDirectory, agent_name, "serf_agent.json"
    end
  end
  
  def getHomeLogDirectory
    File.join node["serf"]["base_directory"], "logs"
  end
  
  def getAgentLog(agent_name)
    if agent_name.nil?
      File.join getHomeLogDirectory, "agent.log"
    else
      File.join getHomeLogDirectory, agent_name, "agent.log"
    end
  end
  
  def getAgentJson(agent_name)
    if agent_name.nil?
      JSON.pretty_generate(node["serf"]["agent"].to_hash)
    else
      JSON.pretty_generate(node["serf"]["agents"][agent_name].to_hash)
    end
  end
  
  def getZipFilePath
    File.join Chef::Config[:file_cache_path], "serf-#{node["serf"]["version"]}_linux_#{node["serf"]["arch"]}.zip"
  end
  
  def getSerfInstalledVersion
    unless File.exists? getSerfBinary
      return "NONE"
    end
    
    cmd = Mixlib::ShellOut.new("#{getSerfBinary} version")
    cmd.run_command
    versionOutput = cmd.stdout.chomp
    serfMatch = SERF_VERSION_REGEX.match(versionOutput)
      
    if serfMatch.size == 0
      raise "Unable to parse version from `serf version` output [#{versionOutput}]"
    end
    
    versionMatch = VERSION_REGEX.match(serfMatch[0])
    
    # Should never happen
    if versionMatch.size == 0
      raise "Unable to parse version from `serf version` output [#{versionOutput}]"
    end
    
    versionMatch[0]
  end
  
end
