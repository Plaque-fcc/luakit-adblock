#!/bin/bash

# look for adblock directory or fallback
[[ -d ~/.local/share/luakit/adblock/ ]] && cd ~/.local/share/luakit/adblock/ || cd ~/.local/share/luakit/

# backup the old list
[[ -f easylist.txt ]] && cp easylist.txt easylist.txt.b

wget -N --connect-timeout=10 --retry-connrefused --wait=5 https://easylist-downloads.adblockplus.org/easylist.txt

# if download failed move old file back in place
if [[ $? != 0 ]]; then
	[[ -f easylist.txt.b ]] && mv easylist.txt.b easylist.txt
	echo "Error: Easylist Download Failed!"
	exit 1
else
	[[ -f easylist.txt.b ]] && rm easylist.txt.b # if all went well remove backup
	echo "All went well. :)"
	exit 0
fi
