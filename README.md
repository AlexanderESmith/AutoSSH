# AutoSSH
Automated server selection/connection via GNUScreen windows

# Purpose
Shows all servers in your ~/.ssh/config file and gives you a menu to connect to them in an organized and efficiant way. Best when used with environments that contain many servers.

# Features
* Tiny, portable, self-contained
* Supports regex based and token based searching (space seperated, each additional token refines the search)
* When run inside GNUScreen, opens servers with a named tab
* If the connection is lost, you can easily reconnect with a keypress
* If that server is already open, you switch to that tab instead of opening a new one
* Supports the use of external scripts (e.g. using vncviewer, xfreerdp, custom bash scripts, etc)

# Todo
* Add toggle for opening the existing tab or intentionally opening a new one
* Maybe change the name from AutoSSH (because **ass**h, and also it supports more than just SSH)
