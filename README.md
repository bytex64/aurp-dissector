# AURP Dissector

This is a Lua script Wireshark dissector for the AppleTalk Update-Based Routing
Protocol, or AURP. AURP is a routing and tunneling protocol that operates over
UDP port 387. Currently, this only decodes the routing-related packets
described in "AppleTalk Update-Based Routing Protocol - Enhanced AppleTalk
Routing". It will also delegate tunneled data (packet type 2) to the Datagram
Delivery Protocol (DDP) dissector so you can see what's inside.

## Status

All AURP packets should be decoded, but I don't have dumps that exercise every
part of the protocol so it is quite likely there are errors. Also my brain is
fried from trying to interpret diagrams, so maybe even the stuff I have tested
is wrong.

## Installing

Copy `aurp-dissector.lua` to your Wireshark plugins directory. This is
`~/.local/lib/wireshark/plugins` on Unix-like systems and
`%APPDATA%\Wireshark\plugins` on Windows. Restart Wireshark or press
Cmd/Ctrl-Shift-L to reload Lua scripts.

## It doesn't work!

ᖍ(ᐙ)ᖌ

If you can figure out what broke, send me a patch. If you can't figure out what
broke, send me a packet dump. If you can't figure out either, I can't help you.
