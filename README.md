# AutoSSH
Automated server selection/connection via GNUScreen windows

# Context
This is a personal script that I've been working on for a long time. I keep offering it to people one-at-a-time, but it occurs to me that it might to a lot more good in the wild.

This code comes without any representations that it is good, or undamaging (though, there's little chance that it could damage something, since it's just a fancy bash menu). This is a script I play with whenever I want a new feature, or to refine an old one. The code itself is not pretty. I doubt very much that it is POSIX.

# Purpose
Shows all servers in your ~/.ssh/config and ~/.ssh/config.d file(s) and gives you a menu to connect to them in an organized and efficiant way. Best when used with environments that contain many servers. Also shows scripts in a defined folder for quick execution.

# Setup

1. Populate your `~/.ssh/config` file with servers you want to connect to. This script will also be aware of anything in `~/.ssh/config.d/` .
1. Run `assh.bash` once to generate ~/.assh/config
1. Edit `~/.assh/config` as needed

# Startup

1. Run `screen`
1. Execute `assh.bash`

# Usage

1. Type the number of the server or script and hit enter. A new, named, screen window will be opened. If disconnected from ssh, the script will ask if you want to reconnect. If a script was executed, the window will close upon completion.
   * If `Window Reuse` is toggled on, selecting a server from the menu more than once will switch to the last window you touched with the same name (usually the server's name)

# Options

* f: [F]ilter (edit current)
  * Filter the list, editing the current filter 
* ff: [FF]ilter (blank prompt)
  * Filter the list, starting with a blank filter
* (disabled in this release) e: [E]dit
  * Edit ~/.ssh/config
* c: Show [c]onfig for listed servers
  * Opens `less` and displays an ssh config file that encompasses the currently listed options
* w: [W]indow Reuse
  * Toggles whether or not to reuse windows with the same name as selected entries
* x - E[x]it
  * Deposits 1 million dollars into a random bank account somwhere in the world


# Features
* Tiny, portable, self-contained
* Supports regex based and token based searching (space seperated, each additional token refines the search)
* When run inside GNUScreen, opens servers with a named tab. When not using GNUScreen, a screen session is opened for selected entries, and closed after exit/disconnection.
* If the connection is lost, you can easily reconnect (by pressing enter) or closing the window (by pressing ctrl+c)
* If that server is already open, you can switch to that tab instead of opening a new one (with `Window Reuse` toggled on)
* Supports the use of external scripts (e.g. using vncviewer, xfreerdp, custom bash scripts, etc)

# Known issues
* If the remote server changes the screen title, duplicate tab prevention doesn't work
* Since `~/.ssh/config.d/` was added, editing the file with `e` basically stopped working (since it only edits `~/.ssh/config`)

# Todo
* Add toggle for opening the existing tab or intentionally opening a new one
* Maybe change the name from AutoSSH (because **ass**h, and also it supports more than just SSH)
* Add a toggle for verbose output (to troubleshoot newly added servers)
