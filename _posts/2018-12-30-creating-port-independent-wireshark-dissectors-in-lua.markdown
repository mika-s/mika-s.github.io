---
layout: post
title:  "Creating port-independent (heuristic) Wireshark dissectors in Lua"
date:   2018-12-30 17:00:00 +0100
categories: wireshark lua dissector
---

In this post I'll describe how we can make dissectors, written in Lua, independent of the port
that the protocol uses. This type of dissector is called a *heuristic dissector*.

### How heuristic dissectors work

A heuristic dissector is a dissector that reads the content of packets in order to determine
whether it's the right dissector to use or not. This is compared to a "normal" dissector that is
registered to a port and will try to dissect all packets that are received on that port. For
example, the early bytes of a packet are usually metadata that are unique to a particular protocol:
magic number such as flags, message IDs and so on. If enough of the metadata in the incoming packet
match, we can assume the dissector is correct to use for the packet that is being dissected.

You might want to make a dissector heuristic if you don't know what port a protocol will operate
on, if it uses random ports, if the port it uses is also used by another protocol, and so on.
However, be aware that many protocols share structure and metadata such as message IDs and flags.
It's important that a protocol is unique enough before using the heurisitic dissector functionality.

Registering a dissector as a heurisitic dissector is done with `register_heuristic()`. Before we start,
let's take a look at the protocol we'll use first.

### Protocol example

Let's use a simple self-made protocol to illustrate how we can make heuristic dissectors. The
protocol I'll use is a client-server chat protocol with the following properties:

- It uses UDP on port 4000 and 4001.
- It is big endian.
- It has the following structure:

<table style="text-align: center; font-size: 0.9rem">
  <tr>
    <th style="padding: 0">Name</th>
    <th style="padding: 0">Type</th>
    <th style="padding: 0">Header or payload</th>
    <th style="padding: 0">Description</th>
  </tr>
  <tr>
    <td style="padding-top: 0;">Protocol flag</td>
    <td style="padding-top: 0;">uint8</td>
    <td style="padding-top: 0;">Header</td>
    <td style="padding-top: 0;">Always 0xD3.</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">Message ID</td>
    <td style="padding-top: 0;">uint16</td>
    <td style="padding-top: 0;">Header</td>
    <td style="padding-top: 0;">The ID of the message.</td>
  </tr>
  <tr>
    <td style="padding-top: 0;">Data</td>
    <td style="padding-top: 0;">string</td>
    <td style="padding-top: 0;">Payload</td>
    <td style="padding-top: 0;">The actual payload. E.g. chat message, nickname, etc.</td>
  </tr>
</table>

- It has the following messages (with message ID):
    * Connect: 0x0001
    * Connect ok: 0x0101
    * Disconnect: 0x0002
    * Disconnect ok: 0x0102
    * Chat message to server: 0x0003
    * Chat message from server: 0x0103

So one connect message could look like this:

`d3 00 01 74 65 73 74 75 73 65 72`

Where `d3` is the protocol flag, `00 01` is the message ID for connect, and
`74 65 73 74 75 73 65 72` is a string that means *testuser* in ASCII.

I've made a "normal" dissector for it that looks like this (it only parses the header):

```lua
scp_protocol = Proto("SCP", "Simple Chat Protocol")

-- Header fields
proto_flag = ProtoField.uint8 ("scp_protocol.proto_flag", "protoFlag", base.HEX)
msg_id     = ProtoField.uint16("scp_protocol.msg_id"    , "msdId"    , base.HEX)

scp_protocol.fields = { proto_flag, msg_id }

local function get_message_name(msg_id)
    local message_name = "Unknown"

        if msg_id == 0x0001 then message_name = "Connect"
    elseif msg_id == 0x0101 then message_name = "Connect ok"
    elseif msg_id == 0x0002 then message_name = "Disconnect"
    elseif msg_id == 0x0102 then message_name = "Disconnect ok"
    elseif msg_id == 0x0003 then message_name = "Chat message to server"
    elseif msg_id == 0x0103 then message_name = "Chat message from server" end

    return message_name
end

function scp_protocol.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then return end

    pinfo.cols.protocol = scp_protocol.name

    local subtree = tree:add(scp_protocol, buffer(), "Simple Chat Protocol Data")

    -- Header
    subtree:add(proto_flag, buffer(0,1))

    local read_msg_id = buffer(1,2):uint()
    local message_name = get_message_name(read_msg_id)
    subtree:add(msg_id, buffer(1,2)):append_text(" (" .. message_name .. ")")
end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(4000, scp_protocol)
udp_port:add(4001, scp_protocol)
```

It puts the protocol flag and message ID on the subtree and is registered to UDP ports 4000 and 4001.

Let's convert this into a heuristic dissector.

### Creating a heuristic dissector

The function that has to be called in order to register a heuristic dissector is `register_heuristic()`.
It's a method of the Proto object. In my case it's called like this:

```lua
scp_protocol:register_heuristic("udp", heuristic_checker)
```

`heuristic_checker()` is a function that is passed as an argument to `register_heuristic()`.
It has three parameters: `buffer` (Tvb object), `pinfo` (Pinfo object) and `tree` (TreeItem object).
You can find the documentation for it [here][protofield-functions] (search for register_heuristic).

In my case it looks like this:

```lua
local function heuristic_checker(buffer, pinfo, tree)
    -- guard for length
    length = buffer:len()
    if length < 3 then return false end

    local potential_proto_flag = buffer(0,1):uint()
    if potential_proto_flag ~= 0xd3 then return false end

    local potential_msg_id = buffer(1,2):uint()

    if get_message_name(potential_msg_id) ~= "Unknown"
    then
        scp_protocol.dissector(buffer, pinfo, tree)
        return true
    else return false end
end
```

The goal of the heuristic checker function is to return false if the dissector doesn't belong to the
packet in question, and return true otherwise. So what I'm doing in the function above is to check
that the length of the packet is long enough to actually be a SCP packet. This is just a guard so we
don't end up trying to read values outside the buffer.

The first real check I do is to look for the protocol flag: `0xD3`. If this doesn't exist as the first
byte it can't be a SCP packet and we can return false immidiatly.

The second check I do is for the two next bytes, which represents the message ID. This is checked with
the `get_message_name()` function which looks for valid message IDs in a bunch of if-elseifs. If it doesn't
find a valid message ID it will return "Unknown" and we can return false in `heuristic_checker()`. If
it returns a proper message name we consider the dissector to belong to the packet and we can call the
dissector function and return true.

Note that I only check the protocol flag and message IDs in this heuristic dissector. I do this because
this is a blog post and I have to keep it simple. In reality you want to test as many things as possible
before you return true. As mentioned before, many protocols have similar structure and the same magic
numbers, so you might end up registering a dissector to a wrong protocol if you only test for things like
protocol flag, message IDs and so on. The further you check the more confidence you get in that the
registration is correct.

The final heuristic dissector looks like this:

```lua
scp_protocol = Proto("SCP", "Simple Chat Protocol")

-- Header fields
proto_flag = ProtoField.uint8 ("scp_protocol.proto_flag", "protoFlag", base.HEX)
msg_id     = ProtoField.uint16("scp_protocol.msg_id"    , "msdId"    , base.HEX)

scp_protocol.fields = { proto_flag, msg_id }

local function get_message_name(msg_id)
    local message_name = "Unknown"

        if msg_id == 0x0001 then message_name = "Connect"
    elseif msg_id == 0x0101 then message_name = "Connect ok"
    elseif msg_id == 0x0002 then message_name = "Disconnect"
    elseif msg_id == 0x0102 then message_name = "Disconnect ok"
    elseif msg_id == 0x0003 then message_name = "Chat message to server"
    elseif msg_id == 0x0103 then message_name = "Chat message from server" end

    return message_name
end

local function heuristic_checker(buffer, pinfo, tree)
    -- guard for length
    length = buffer:len()
    if length < 3 then return false end

    local potential_proto_flag = buffer(0,1):uint()
    if potential_proto_flag ~= 0xd3 then return false end

    local potential_msg_id = buffer(1,2):uint()

    if get_message_name(potential_msg_id) ~= "Unknown"
    then
        scp_protocol.dissector(buffer, pinfo, tree)
        return true
    else return false end
end

function scp_protocol.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then return end

    pinfo.cols.protocol = scp_protocol.name

    local subtree = tree:add(scp_protocol, buffer(), "Simple Chat Protocol Data")

    -- Header
    subtree:add(proto_flag, buffer(0,1))

    local read_msg_id = buffer(1,2):uint()
    local message_name = get_message_name(read_msg_id)
    subtree:add(msg_id, buffer(1,2)):append_text(" (" .. message_name .. ")")
end

scp_protocol:register_heuristic("udp", heuristic_checker)
```

Note that the port registration is gone. You can use both port registration and heuristic functionality,
but I won't go into that here.

`scp_protocol.dissector()` could also be passed in as an argument to `register_heuristic()`, rather
than having a separate function for this. There is more written about that in the [official manual][protofield-functions]
(search for register_heuristic) and in [this][example-heuristic-dissector] dissector. That makes
it possible to reuse the parsing logic.

For more information on heuristic dissectors, please also read the official [readme][readme-heuristic].

[readme-heuristic]: https://github.com/wireshark/wireshark/blob/master/doc/README.heuristic
[protofield-functions]: https://www.wireshark.org/docs/wsdg_html_chunked/lua_module_Proto.html
[example-heuristic-dissector]: https://github.com/zonque/wireshark/blob/master/test/lua/dissector.lua
