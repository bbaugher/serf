# coding: UTF-8
require 'octokit'

REPO = "bbaugher/serf"

task :release do
  
  # Get current version
  version = IO.read(File.join(File.dirname(__FILE__), 'VERSION')).chomp
  
  # Update change log
  puts "Updating change log ..."
  update_change_log version
  puts "Change log updated!"
  
  # Share the cookbook
  puts "Sharing cookbook ..."
  run_command "knife cookbook site share serf Other"
  puts "Shared cookbook!"
 
  # Tag the release
  puts "Tagging the #{version} release ..."
  run_command "git tag -a #{version} -m 'Released #{version}'"
  run_command "git push origin #{version}"
  puts "Release tagged!"
  
  # Bump VERSION file
  versions = version.split "."
  versions[1] = versions[1].to_i + 1
  new_version = versions.join "."
  
  puts "Updating version from #{version} to #{new_version} ..."
  File.open('VERSION', 'w') { |file| file.write(new_version) }
  puts "Version updated!"
  
  # Commit the updated VERSION file
  puts "Commiting the new version ..."
  run_command "git add VERSION"
  run_command "git commit -m 'Released #{version} and bumped version to #{new_version}'"
  run_command "git push origin HEAD"
  puts "Version commited!"
end

task :build_change_log do
  closed_milestones = Octokit.milestones REPO, {:state => "closed"}
  
  version_to_milestone = Hash.new
  versions = Array.new
  
  closed_milestones.each do |milestone|
    version = Gem::Version.new(milestone.title)
    version_to_milestone.store version, milestone
    versions.push version
  end
  
  versions = versions.sort.reverse
  
  change_log = File.open('CHANGELOG.md', 'w')
  
  begin
    change_log.write "Change Log\n"
    change_log.write "==========\n"
    change_log.write "\n"
    
    versions.each do |version|
      milestone = version_to_milestone[version]
      change_log.write generate_milestone_markdown(milestone)
      change_log.write "\n"
    end
  ensure
    change_log.close
  end
end

def update_change_log version
  change_log_lines = IO.read(File.join(File.dirname(__FILE__), 'CHANGELOG.md')).split("\n")
  
  change_log = File.open('CHANGELOG.md', 'w')
  
  begin
    
    # Keep change log title
    change_log.write change_log_lines.shift
    change_log.write "\n"
    change_log.write change_log_lines.shift
    change_log.write "\n"
    change_log.write "\n"
    
    # Write new milestone info
    change_log.write generate_milestone_markdown(milestone(version))
    
    # Add previous change log info
    change_log_lines.each do |line|
      change_log.write line
      change_log.write "\n"
    end
    
  ensure
    change_log.close
  end
end

def generate_milestone_markdown milestone
  strings = Array.new
  
  title = "[#{milestone.title}](https://github.com/#{REPO}/issues?milestone=#{milestone.number}&state=closed)"
  
  strings.push "#{title}"
  strings.push "-" * title.length
  strings.push ""
  
  issues = Octokit.issues REPO, {:milestone => milestone.number, :state => "closed"}
  
  issues.each do |issue|
    strings.push "  * [#{issue_type issue}] [Issue-#{issue.number}](https://github.com/#{REPO}/issues/#{issue.number}) : #{issue.title}"
  end
  
  strings.push ""
  
  strings.join "\n"
end

def milestone version
  closedMilestones = Octokit.milestones REPO, {:state => "closed"}
  
  closedMilestones.each do |milestone|
    if milestone["title"] == version
      return milestone
    end
  end
  
  openMilestones = Octokit.milestones REPO
  
  openMilestones.each do |milestone|
    if milestone["title"] == version
      return milestone
    end
  end
  
  raise "Unable to find milestone with title [#{version}]"
end

def issue_type issue
  labels = Array.new
  issue.labels.each do |label|
    labels.push label.name.capitalize
  end
  labels.join "/"
end

def run_command command
  output = `#{command}`
  unless $?.success?
    raise "Command : [#{command}] failed.\nOutput : \n#{output}"
  end
end
