# AutoSSH
Automated server selection/connection via GNUScreen windows

# Purpose
Shows all servers in your ~/.ssh/config file and gives you a menu to connect to them in an organized and efficiant way. Best when used with environments that contain many servers.

# Startup

1. Populate your `~/.ssh/config` file with servers you want to connect to. This script will also be aware of anything in `~/.ssh/config.d/` .
1. Edit the top part of `assh.bash` so that the script is aware of it's path on the system, and the folder you keep other small scripts you want to be able to run quicky
1. Run `screen`
1. Execute `assh.bash`
1. Type the number of the server or script and hit enter. A new, named, screen window will be opened. If disconnected from ssh, the script will ask if you want to reconnect. If a script was executed, the window will close upon completion.

# Options

* f - [F]ilter (edit current)
  * Filter the list, editing the current filter 
* ff - [FF]ilter (blank prompt)
  * Filter the list, starting with a blank filter
* e - [E]dit
  * Edit ~/.ssh/config
* c - Show [c]onfig for listed servers
  * Opens `less` and displays an ssh config file that encompasses the currently listed options
* d - Toggle fancy [D]isplay (current: 0)
  * Shows a dumb loading thing whenever you set a new filter or refresh
* x - E[x]it
  * Deposits 1 million dollars into a random back account somwhere in the world.


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
* Add a toggle for verbose output (to troubleshoot newly added servers)
