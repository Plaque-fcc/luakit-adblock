#!/bin/bash

[[ -z "$XDG_DATA_HOME" ]] && DATADIR="$HOME/.local/share" || DATADIR="$XDG_DATA_HOME"

# look for adblock directory or fallback
[[ -d "$DATADIR/luakit/adblock/" ]] && cd "$DATADIR/luakit/adblock/" || cd "$DATADIR/luakit/"

# backup the old list
[[ -f easylist.txt ]] && cp -p easylist.txt easylist.txt.b

wget -N --connect-timeout=10 --tries=20 --retry-connrefused --waitretry=5 https://easylist-downloads.adblockplus.org/easylist.txt

# if download failed move old file back in place
if (( $? != 0 )); then
	[[ -f easylist.txt.b ]] && mv easylist.txt.b easylist.txt
	echo "Error: Easylist Download Failed!"
	exit 11
else
	[[ -f easylist.txt.b ]] && rm easylist.txt.b # if all went well remove backup
	echo "All went well. :)"
	exit 0
fi
