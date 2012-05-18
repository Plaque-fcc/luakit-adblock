------------------------------------------------------------------------
-- Simple URI-based content filter                                    --
-- (C) 2010 Chris van Dijk (quigybo) <quigybo@hotmail.com>            --
-- (C) 2010 Mason Larobina (mason-l) <mason.larobina@gmail.com>       --
--                                                                    --
-- Download an Adblock Plus compatible filter list to $XDG_DATA_HOME  --
-- and update the "filterfiles" entry below. EasyList is the most     --
-- popular Adblock Plus filter list: http://easylist.adblockplus.org/ --
-- Filterlists need to be updated regularly (~weekly), use cron!      --
------------------------------------------------------------------------
--require "webview"

local info = info
local ipairs = ipairs
local io = io
local os = os
local string = string
local table = table
local tostring = tostring
local webview = webview
local lousy = require "lousy"
local capi = { luakit = luakit }
local out = io.stdout

module("adblock")

--- Module global variables
local enabled = true
-- Adblock Plus compatible filter lists
local adcat, why = io.popen("ls " .. capi.luakit.data_dir .. "/adblock/*.txt", "r")

if not adcat then
    out:write(why .. "\n")
else
    out:write("Ok.\n")
end

local filterfiles = {}

for line in adcat:lines() do
    out:write("Found adblock list: " .. line .. "\n")
    table.insert(filterfiles, line )
end

out:write( "Found " .. table.maxn(filterfiles) .. " rules lists.\n" )

--local filterfiles = { capi.luakit.data_dir .. "/easylist.txt" }
-- String patterns to filter URI's with
local whitelist = {}
local blacklist = {}
-- Functions to filter URI's by
-- Return true or false to allow or block respectively, nil to continue matching
local filterfuncs = {}

-- Enable or disable filtering
enable = function ()
    enabled = true
end
disable = function ()
    enabled = false
end

-- Convert Adblock Plus filter description to lua string pattern
-- See http://adblockplus.org/en/filters for more information
abp_to_pattern = function (s)
    -- Strip filter options
    local opts
    local pos = string.find(s, "%$")
    if pos then
        s, opts = string.sub(s, 0, pos-1), string.sub(s, pos+1)
    end

    -- Protect magic characters (^$()%.[]*+-?) not used by ABP (^$()[]*)
    s = string.gsub(s, "([%%%.%+%-%?])", "%%%1")

    -- Wildcards are globbing
    s = string.gsub(s, "%*", "%.%*")

    -- Caret is separator (anything but a letter, a digit, or one of the following:Â - . %)
    s = string.gsub(s, "%^", "[^%%w%%-%%.%%%%]")

    -- Double pipe is domain anchor (beginning only)
    -- Unfortunately "||example.com" will also match "wexample.com" (lua doesn't do grouping)
    s = string.gsub(s, "^||", "^https?://w?w?w?%%d?%.?")

    -- Pipe is anchor
    s = string.gsub(s, "^|", "%^")
    s = string.gsub(s, "|$", "%$")

    -- Convert to lowercase ($match-case option is not honoured)
    s = string.lower(s)
    

    return s
end

-- Parses an Adblock Plus compatible filter list
parse_abpfilterlist = function (filename)
    if os.exists(filename) then
        info("adblock: loading filterlist %s", filename)
    else
        info("adblock: error loading filter list (%s: No such file or directory)", filename)
    end
    local pat
    local white, black = {}, {}
    for line in io.lines(filename) do
        -- Ignore comments, header and blank lines
        if line:match("^[![]") or line:match("^$") then
            -- dammitwhydoesntluahaveacontinuestatement

        -- Ignore element hiding
        elseif line:match("#") then

        -- Check for exceptions (whitelist)
        elseif line:match("^@@") then
            pat = abp_to_pattern(string.sub(line, 3))
            if pat and pat ~= "^http://" then
                table.insert(white, pat)
            end

        -- Add everything else to blacklist
        else
            pat = abp_to_pattern(line)
            if pat and pat ~= "^http:" then
                table.insert(black, pat)
            end
        end
    end

    return white, black
end

-- Load filter list files
load = function ()
    for _, filename in ipairs(filterfiles) do
        local white, black = parse_abpfilterlist(filename)
        whitelist = lousy.util.table.join(whitelist or {}, white)
        blacklist = lousy.util.table.join(blacklist or {}, black)
    end
end

-- Tests URI against user-defined filter functions, then whitelist, then blacklist
match = function (uri, signame)
    -- Matching is not case sensitive
    uri = string.lower(uri)
    signame = signame or ""

    -- Test uri against filterfuncs
    for _, func in ipairs(filterfuncs) do
        local ret = func(uri)
        if ret ~= nil then
            info("adblock: filter function %s returned %s to uri %s", tostring(func), tostring(ret), uri)
            return ret
        end
    end

    -- Check for a match to whitelist
    for _, pattern in ipairs(whitelist) do
        if string.match(uri, pattern) then
            info("adblock: allowing %q as pattern %q matched to uri %s", signame, pattern, uri)
            out:write ("Allowed " .. signame .. " as pattern " .. pattern .. " matched to uri " .. uri .. "\n")
            return true
        end
    end

    -- Check for a match to blacklist
    for _, pattern in ipairs(blacklist) do
        if string.match(uri, pattern) then
            info("adblock: blocking %q as pattern %q matched to uri %s", signame, pattern, uri)
            out:write ("Blocked " .. signame .. " as pattern " .. pattern .. " matched to uri " .. uri .. "\n")
            return false
        end
    end
end

-- Direct requests to match function
filter = function (v, uri, signame)
    if enabled then return match(uri, signame or "") end
end

-- Connect signals to all webview widgets on creation
webview.init_funcs.adblock_signals = function (view, w)
    view:add_signal("navigation-request",        function (v, uri) return filter(v, uri, "navigation-request")        end)
    view:add_signal("resource-request-starting", function (v, uri) return filter(v, uri, "resource-request-starting") end)
end

-- Initialise module
load()