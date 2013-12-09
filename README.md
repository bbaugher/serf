Serf Cookbook
=============

Installs and configures [Serf](http://www.serfdom.io/).

Usage
-----

Using the default attributes will setup a single Serf agent in its own cluster.

If you already have a Serf agent (or cluster) running specify the address(es) with the 
`node["serf"]["join_addresses"]` attribute so the agent will join the cluster(s).

What does the installation look like
------------------------------------

All of Serf's files will be located under `node["serf"]["base_directory"]` (or /opt/serf/ by default). 
An init.d script is created under `/etc/init.d/serf` which can also be used like `service serf start`. 
Serf's agent logs will be made available under `node["serf"]["log_directory"]` or (`/var/log/serf` by 
default).

Attributes
----------

 * `node["serf"]["join_addresses"]` : An array of addresses the Serf agent should try to join (default=[])
 * `node["serf"]["event_handlers"]` : An array of hashes that represent [event handlers](http://www.serfdom.io/docs/agent/event-handlers.html). See 'Event Handlers' below for more details (default=[])
 * `node["serf"]["role"]` : The role of the Serf agent (default="")
 * `node["serf"]["node"]` : The node name of the Serf agent (default=`node["fqdn"]`)
 * `node["serf"]["base_binary_url"]` : The base url used to download the binary zip (default="https://dl.bintray.com/mitchellh/serf/")
 * `node["serf"]["version"]` : The version of the Serf agent to install (default="0.1.1")
 * `node["serf"]["arch"]` : The architecture of the Serf agent to install (default=`kernel['machine'] =~ /x86_64/ ? "amd64" : "386"`)
 * `node["serf"]["binary_url"]` : The full binary url of the Serf agent (default=`File.join node["serf"]["base_binary_url"], "#{node["serf"]["version"]}_linux_#{node["serf"]["arch"]}.zip"`)
 * `node["serf"]["rpc_port"]` : The rpc port the Serf agent uses for communication between other serf commands (default=7373)
 * `node["serf"]["rpc_address"]` : The rpc ip address the Serf agent uses for communication between other Serf commands (default=`127.0.0.1`)
 * `node["serf"]["bind_port"]` : The bind port the Serf agent uses for communication between other Serf agents (default=7946)
 * `node["serf"]["bind_address"]` : The bind ip address the Serf agent uses for communication between other Serf agents (default=`0.0.0.0`)
 * `node["serf"]["log_level"]` : The log level of the Serf agent (default="info")
 * `node["serf"]["base_directory"]` : The base directory Serf should be installed into (default="/opt/serf")
 * `node["serf"]["log_directory"]` : The directory of the Serf agent logs (default="/var/log/serf")
 
Event Handlers
--------------

An [event handler](http://www.serfdom.io/docs/agent/event-handlers.html) is a script that is run when the Serf agent
recieves an event (member-join, member-leave, member-failed, or user).

The format for configuring an event handler throught the serf cookbook is,

    {
      "url" : "URL", # REQUIRED
      "event_type" : "EVENT_TYPE", #OPTIONAL
    }
    
The `event_type` value filters the event handler for certain events. Use [this doc](http://www.serfdom.io/docs/agent/event-handlers.html) 
to figure out the `event_type` you need.
