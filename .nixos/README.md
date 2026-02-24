# Hunter's NixOS Configuration
This repository contains my personal NixOS configuration(s) and is not necessarily intended for personal use, though I am keeping it public in the hopes it may one day prove useful for someone out there working on their own configuration. It's nowhere near where I want it to be yet, but we're getting there.

*This repository is a work in progress.*

## What I'd Like to Accomplish with this Project
- Create a stable, reproducible configuration that sets up my computer exactly the way I like it
- Keep my configuration consistent on all of my devices: my desktop PC, laptop, and (eventually, once I figure out how) my cell phone.
- Document everything. The Readme should (eventually) contain a clear, consise explanation of how it all fits together, my thought processes and reasoning behind the way I've structured things, and recommendations for how I think a new NixOS user should go about building their own system(s). I want this project to be a useful reference for anyone looking to enter the world of Nix.
- Push myself to learn new things. I want to be more efficient and effective in what I do, so I've been dabbling in new tools like Vim and Bash scripting to help me go about my day-to-day life. In the near future I plan on breaking into a few new ones that I think will be useful (listed below).

## What I am Currently Struggling With
- NixOS module option types. Holy crapoly the Nix Manual is cryptic.
- My Nvidia settings are causing a lot of screen tearing, visual glitches, hitching, etc. in Old School Runescape but not in any other games—naturally it had to happen to my favorite one,eh?. Something is wrong with the Nvidia settings I have, but I haven't been able to figure it out yet.

## What's Next?
- Get `nvim` and `emacs` to use the `electro-swing` color scheme I created for `alacritty`
- Create a "specialisation" that keeps KDE Plasma as my default (for now) but adds a boot entry that switches over to Hyprland for when I'm working on configuring that
- Set up Emacs with Evil Mode, Magit, and Org-Mode. Make sure it runs as a server & client so I don't have to perform startup tasks every time I launch a new window
- Switch from KDE Plasma to Hyprland
- Personalize my workspaces, window rules, and keybinds so that window management & navigation is as smooth and easy as possible
- Build my own desktop environment with Quickshell
- Apply unified themes, color schemes, etc. with Stylix or some similar utility
- Expand on the documentation for my configuration so it becomes a useful example
- Modularize my configuration so I can use it for my desktop, laptop, and (eventually) a small NAS box running on a Raspberry Pi. Build it in a way that I can reuse certain modules on multiple devices while retaining the ability to customize certain aspects when needed
- Create a Nix function like "createUser" that allows me to group `system.user.user` definitions and `home.user.user` definitions together in the same file. I currently have to define a new user in two different places and it irks me.
- Move toward a "dendritic" structure; this would allow me to group NixOS system and Home Manager options together, so I could have one file (and only one file) for each "component"  of my system (meaning option definitions that logically belong together)
- Automate certain mundane tasks like garbage collection, updating from upstream sources, file backups, etc.
- Utilize a separate, private repo for secrets management
- Create a live ISO with my preferred settings & utilities for setting up new hosts
