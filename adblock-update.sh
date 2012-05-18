#!/bin/bash


[[ -d /tmp ]] && cd /tmp/

while ! wget https://easylist-downloads.adblockplus.org/easylist.txt; do
    sleep 20s;
done;

if [[ -d ~/.local/share/luakit/adblock/ ]]; then
    mv easylist.txt ~/.local/share/luakit/adblock/;
else
    mv easylist.txt ~/.local/share/luakit/
fi;

exit
