# AURP Dissector

This is a Lua script Wireshark dissector for the AppleTalk Update-Based Routing
Protocol, or AURP. AURP is a routing and tunneling protocol that operates over
UDP port 387. Currently, this only decodes the routing-related packets
described in "AppleTalk Update-Based Routing Protocol - Enhanced AppleTalk
Routing". It does not decode any encapsulated AppleTalk data.

## Status

Some packets are decoded, but some of the more complicated ones I haven't
implemented yet. I plan to finish everything described in the AURP paper.

## Installing

Copy `aurp-dissector.lua` to your Wireshark plugins directory. This is
`~/.local/lib/wireshark/plugins` on Unix-like systems and
`%APPDATA%\Wireshark\plugins` on Windows. Restart Wireshark or press
Cmd/Ctrl-Shift-L to reload Lua scripts.

## It doesn't work!

ᖍ(ᐙ)ᖌ

If you can figure out what broke, send me a patch.
