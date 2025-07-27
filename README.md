# Overview
The goal of File Keeper is to keep track of important config files on your machine.<br>
I've made this because I struggle keeping track of what / where are the config files of the
different services on the containers of my Proxmox server.

This tool was made only to keep track of max 10 files, but it is more than enough for a CT with a single service.

# How to use
```
git clone https://github.com/AlexAuragan/file-keeper.git
cd file-keeper
chmod +x fk
./fk --init
```
