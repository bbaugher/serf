Serf Cookbook
=============

[![Cookbook Version](https://img.shields.io/cookbook/v/serf.svg)](https://community.opscode.com/cookbooks/serf)

Installs and configures [Serf](http://www.serfdom.io/).

View the [Change Log](https://github.com/bbaugher/serf/blob/master/CHANGELOG.md) to see what has changed.

Supports
--------

 * Serf >= 0.3 (uses config reloading via SIGHUP)
 * Linux OS'es

Usage
-----

Using the default attributes will setup a single Serf agent in its own cluster.

If you already have a Serf agent (or cluster) running specify the array of address(es) with the
`node["serf"]["agent"]["start_join"]` attribute so the agent will join the cluster(s).

What does the installation look like
------------------------------------

By default the installation will look like,

    serf | /usr/bin/serf  - The serf binary command
    /opt/serf/*           - All of serf's files (config, binaries, event handlers, logs...)
    /etc/serf/*           - Link to all of serf's config files
    /var/log/serf/*       - Link to all of serf's log files
    /etc/init.d/serf      - An init.d script to start/stop the agent. You can use service
                    serf [start|stop|restart|status] instead

Event Handlers
--------------

An [event handler](http://www.serfdom.io/docs/agent/event-handlers.html) is a script that is run when the Serf agent
recieves an event (member-join, member-leave, member-failed, or user).

You can configure an event handler via the attribute `node["serf"]["event_handlers"]`. The format of the `event_handlers`
attribute is the following,

    [
      {
        "url" : "URL", # REQUIRED
        "event_type" : "EVENT_TYPE" #OPTIONAL
      },
      ...
    ]

Chef will download the event handler and ensure it stays up to date. It will also add it to the serf agent's list of event handlers.
Each event handler must have a unique name.

The `event_type` value filters the event handler for certain events. Use [this doc](http://www.serfdom.io/docs/agent/event-handlers.html)
to figure out the `event_type` you need.

It is also possible to add event handlers via the attribute `node["serf"]["agent"]["event_handlers"]`. The `node["serf"]["event_handlers"]`
helps with the deployment of the event handler file itself and will add the event handler to the `node["serf"]["agent"]["event_handlers"]`
attribute.

Resources and Providers
-----------------------
### `serf_event`
The `serf_event` LWRP resource dispatches a custom user event into a Serf cluster by executing serf CLI.

#### Actions
- :create: Executes serf cli with parameters required to send an event.

#### Attribute Parameters
- event_name: name attribute. The name of the event to send
- payload: Optional event's payload. Any string you want.
- coalesce: Coalesce option. `true` by default
- rpc_addr: Address of serf node to connect for event dispatching. Local node by default.
- rpc_auth: RPC auth token. If not set, `node['serf']['agent']['rpc_auth']` will be used.

#### Example

Send custom user event

```ruby
serf_event 'deploy' do
  payload '1234567890'
  rpc_auth 'secret'
end
```

It would look like this in serf log:

```
2014/07/08 22:53:07 [INFO] agent: Received event: user-event: deploy
Event Info:
    Coalesce: true
    Event: "user"
    LTime: 7
    Name: "deploy"
    Payload: []byte{0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30}
```

Attributes
----------

 * `node["serf"]["user"]` : The user that owns the serf installation (default="serf")
 * `node["serf"]["group"]` : The group that owns the serf installation (default="serf")
 * `node["serf"]["agent"][*]` : A hash of key/values that will be added to the agent's config file (default={}). Use [this doc](http://www.serfdom.io/docs/agent/options.html) to configure the agent.
 * `node["serf"]["event_handlers"]` : An array of hashes that represent [event handlers](http://www.serfdom.io/docs/agent/event-handlers.html). See 'Event Handlers' above for more details (default=[])
 * `node["serf"]["base_binary_url"]` : The base url used to download the binary zip (default="https://dl.bintray.com/mitchellh/serf/")
 * `node["serf"]["version"]` : The version of the Serf agent to install (default="0.3.0")
 * `node["serf"]["arch"]` : The architecture of the Serf agent to install (default=`kernel['machine'] =~ /x86_64/ ? "amd64" : "386"`)
 * `node["serf"]["binary_url"]` : The full binary url of the Serf agent. If you override this value make sure to provide a valid and up to date value for `node["serf"]["version"]` (default=`File.join node["serf"]["base_binary_url"], "#{node["serf"]["version"]}_linux_#{node["serf"]["arch"]}.zip"`)
 * `node["serf"]["base_directory"]` : The base directory Serf should be installed into (default="/opt/serf")
 * `node["serf"]["log_directory"]` : The directory of the Serf agent logs (default="/var/log/serf")
 * `node["serf"]["conf_directory"]` : The directory of the Serf agent config (default="/etc/serf")
 * `node["serf"]["on_config_change"]` : An action to be performed if config is changed (default=:reload)
 * `node["serf"]["init_info"]` : A hash of init information used by the init service script (see attributes file for defaults)