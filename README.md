luakit-adblock
==============

AdBlock for luakit browser.

Origin: https://github.com/quigybo/luakit/

## Installing AdBlock

Install this module by copying adblock.lua into your $XDG_CONFIG_HOME/luakit/ (defaults to ~/.config/luakit/) directory, then (re)start luakit.

You will need to:

 * Obtain EasyList filter rules file (and/or any other AdBlock rules file); EasyList official can be found there: https://easylist-downloads.adblockplus.org/easylist.txt
 * Create adblock directory in $XDG_DATA_HOME/luakit/ (defaults to ~/.local/share/luakit/) to use multiple files simultaneously and copy them to that directory; or put `easylist.txt’ into $XDG_DATA_HOME/luakit/
 * Start luakit and either type `gA’ or `:open luakit://adblock/’ to visit AdBlock module settings page; there you may find current state of AdBlock module («Enabled» or «Disabled), toggle its state (use `:adblock-enable’ and `:adblock-disable’ commands accordingly) and enable/disable files with ad-blocking rules (use `:adblock-list-enable <file_number>’ and `:adblock-list-disable <file_number>’)

## Bug reporting

Your feedback and problem reporting is always welcome, just visit our Issues page here: https://github.com/Plaque-fcc/luakit-adblock/issues