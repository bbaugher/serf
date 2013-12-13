Change Log
==========

0.2.1
-----

 * Fixed bug where `/var/log/serf` and `/etc/serf` would point to files instead of internal serf log and config directories

0.2
---

[Milestone](https://github.com/bbaugher/serf/issues?milestone=1&state=closed)

 * Upgraded default serf to 0.2.1
 * Requires serf >= 0.2 (config file support)
 * Switched to using config file instead of specifying all options
 * Gracefully shutdown serf agent

0.1
---

 * Initial working cookbook