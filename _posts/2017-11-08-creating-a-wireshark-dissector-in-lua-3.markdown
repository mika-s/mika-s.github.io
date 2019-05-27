---
layout: post
title:  "Creating a Wireshark dissector in Lua - part 3 (parsing the payload)"
date:   2017-11-08 16:00:00 +0100
categories: wireshark lua dissector
---

This post continues where [the second post]({% post_url 2017-11-06-creating-a-wireshark-dissector-in-lua-2 %}) left off.

In part 1 and 2 we looked at the header of the [MongoDB wire protocol][mongodb-wire-protocol]
messages. This time it's time to parse the content of the messages. However, we will not actually
decode the documents returned by MongoDB, as that falls outside the scope of this tutorial.

### Decoding the *OP_QUERY* message

The *OP_QUERY* message is used to query the database for documents in a collection. The format of
this message is:

![OP_QUERY message format]({{ "/assets/creating-wireshark-dissectors-3/OP_QUERY-message.png" | absolute_url }}){: style="margin-top: 15px; margin-bottom: 30px;" }

What the various fields mean can be seen in the [specification][mongodb-wire-protocol]. In the
header we only had to deal with int32s, but now we have a string as well. We can start by parsing
the *flags* field:

```lua
mongodb_protocol = Proto("MongoDB",  "MongoDB Protocol")

-- Header fields
message_length = ProtoField.int32("mongodb.message_length", "messageLength", base.DEC)
request_id     = ProtoField.int32("mongodb.requestid"     , "requestID"    , base.DEC)
response_to    = ProtoField.int32("mongodb.responseto"    , "responseTo"   , base.DEC)
opcode         = ProtoField.int32("mongodb.opcode"        , "opCode"       , base.DEC)

-- Payload fields
flags          = ProtoField.int32("mongodb.flags"         , "flags"        , base.DEC)

mongodb_protocol.fields = {
  message_length, request_id, response_to, opcode,    -- Header
  flags                                               -- OP_QUERY
}

function mongodb_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = mongodb_protocol.name

  local subtree = tree:add(mongodb_protocol, buffer(), "MongoDB Protocol Data")

  -- Header
  subtree:add_le(message_length, buffer(0,4))
  subtree:add_le(request_id,     buffer(4,4))
  subtree:add_le(response_to,    buffer(8,4))

  local opcode_number = buffer(12,4):le_uint()
  local opcode_name = get_opcode_name(opcode_number)
  subtree:add_le(opcode,         buffer(12,4)):append_text(" (" .. opcode_name .. ")")

  -- Payload
  if opcode_name == "OP_QUERY" then
    local flags = buffer(16,4):le_uint()
    subtree:add_le(flags,      buffer(16,4))
  end
end

function get_opcode_name(opcode)
  ...
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(59274, mongodb_protocol)
```

To make the distinction clearer between the header and the actual payload of the message we will
use comments to show where the different sections start. Because the different opcodes have
different structure we have to check what type of message we are dissecting with an `if` statement.
We are only dissecting the `OP_QUERY` message in the code above.

The script is starting to get big for a blog post now, so I will start shortening the content that
we have already looked at before with ...

So the `flags` field is now shown in the sub tree for `OP_QUERY` messages. Similar to the `opcode`,
it would be nice we if could have a description of the flag value in parentheses beside the value.
The description of the values are found in the spec. As with the opcode description we make a lookup
function to get the flag description:

```lua
function get_flag_description(flags)
  local flags_description = "Unknown"

      if flags == 0 then flags_description = "Reserved"
  elseif flags == 1 then flags_description = "TailableCursor"
  elseif flags == 2 then flags_description = "SlaveOk.Allow"
  elseif flags == 3 then flags_description = "OplogReplay"
  elseif flags == 4 then flags_description = "NoCursorTimeout"
  elseif flags == 5 then flags_description = "AwaitData"
  elseif flags == 6 then flags_description = "Exhaust"
  elseif flags == 7 then flags_description = "Partial"
  elseif 8 <= flags and flags <= 31 then flags_description = "Reserved" end

  return flags_description
end
```

and then change how we add the field to the sub tree:

```lua
if opcode_name == "OP_QUERY" then
    local flags = buffer(16,4):le_uint()
    local flags_description = get_flag_description(flags)
    subtree:add_le(flags, buffer(16,4)):append_text(" (" .. flags_description .. ")")
end
```

The MongoDB sub tree will then look like this for messages with the `OP_QUERY` opcode:

![Flag with description]({{ "/assets/creating-wireshark-dissectors-3/flag-with-description.png" | absolute_url }}){: style="margin-top: 15px; margin-bottom: 30px;" }

The flag field will not be there for other messages, as they never enter the `OP_QUERY` *if* block.

The next field is a bit different than the previous ones: we must now dissect something else
than an int32. In this case it's a string. A string is different from the other types in that it
doesn't have a fixed length. So we have to loop over the bytes in the buffer until we hit the end
of the string. How we determine the end of the string is depends on what type of string it is. In
this case, it's a *[cstring][wikipedia-null-terminated-string]*, which means the string is
terminated by *[NUL][wikipedia-nul]* (the byte 00).

```lua
-- Loop over string
local string_length

for i = 20, length - 1, 1 do
  if (buffer(i,1):le_uint() == 0) then
    string_length = i - 20
    break
  end
end

subtree:add_le(full_coll_name, buffer(20,string_length))
```

We loop over the bytes from the start of the string (byte 20) to the end of the entire message. We
then read one byte at a time with `buffer(i,1):le_uint()` and check whether it's the *NUL* byte,
which indicates the end of the string. If it is, we store the length of the string in `string_length`
and break the loop.

We can then add the field to the sub tree. We must also make the field by adding this line to
the top of the script:

```lua
full_coll_name = ProtoField.string("mongodb.full_coll_name", "fullCollectionName", base.ASCII)
```

We can see that we use the `string` function of `ProtoField` rather than `int32` this time. We also
want to represent the string in ASCII rather than decimal, so we have to use `base.ASCII`. The field
also has to be added to the `fields` table:

```lua
mongodb_protocol.fields = {
  message_length, request_id, response_to, opcode,    -- Header
  flags, full_coll_name                               -- OP_QUERY
}
```

We now have the collection name in the packet details pane:

![Packet details with Collection name]({{ "/assets/creating-wireshark-dissectors-3/collectionname.png" | absolute_url }}){: style="margin-top: 15px; margin-bottom: 30px;" }

The rest of the fields are simple. I will not explain them in detail but show the final code
instead. The field called `query` contains BSON documents, but as mentioned before, decoding them
are outside the scope of this post. I'll use `ProtoField.none` for that field, which is a type that
can be used for unstructured data. The script with `OP_QUERY` added is then:

```lua
mongodb_protocol = Proto("MongoDB",  "MongoDB Protocol")

-- Header fields
message_length  = ProtoField.int32 ("mongodb.message_length"  , "messageLength"     , base.DEC)
request_id      = ProtoField.int32 ("mongodb.requestid"       , "requestID"         , base.DEC)
response_to     = ProtoField.int32 ("mongodb.responseto"      , "responseTo"        , base.DEC)
opcode          = ProtoField.int32 ("mongodb.opcode"          , "opCode"            , base.DEC)

-- Payload fields
flags           = ProtoField.int32 ("mongodb.flags"           , "flags"             , base.DEC)
full_coll_name  = ProtoField.string("mongodb.full_coll_name"  , "fullCollectionName", base.ASCII)
number_to_skip  = ProtoField.int32 ("mongodb.number_to_skip"  , "numberToSkip"      , base.DEC)
number_to_return= ProtoField.int32 ("mongodb.number_to_return", "numberToReturn"    , base.DEC)
query           = ProtoField.none  ("mongodb.query"           , "query"             , base.HEX)

mongodb_protocol.fields = {
    message_length, request_id, response_to, opcode,                  -- Header
    flags, full_coll_name, number_to_skip, number_to_return, query    -- OP_QUERY
}

function mongodb_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = mongodb_protocol.name

  local subtree = tree:add(mongodb_protocol, buffer(), "MongoDB Protocol Data")

  -- Header
  subtree:add_le(message_length, buffer(0,4))
  subtree:add_le(request_id,     buffer(4,4))
  subtree:add_le(response_to,    buffer(8,4))
  local opcode_number = buffer(12,4):le_uint()
  local opcode_name = get_opcode_name(opcode_number)
  subtree:add_le(opcode,         buffer(12,4)):append_text(" (" .. opcode_name .. ")")

  -- Payload
  if opcode_name == "OP_QUERY" then
    local flags_number = buffer(16,4):le_uint()
    local flags_description = get_flag_description(flags_number)
    subtree:add_le(flags,      buffer(16,4)):append_text(" (" .. flags_description .. ")")

    -- Loop over string
    local string_length
    for i = 20, length - 1, 1 do
      if (buffer(i,1):le_uint() == 0) then
        string_length = i - 20
        break
      end
    end

    subtree:add_le(full_coll_name,   buffer(20,string_length))
    subtree:add_le(number_to_skip,   buffer(20+string_length,4))
    subtree:add_le(number_to_return, buffer(24+string_length,4))
    subtree:add_le(query,            buffer(28+string_length,length-string_length-28))
  end
end

function get_opcode_name(opcode)
  local opcode_name = "Unknown"

      if opcode ==    1 then opcode_name = "OP_REPLY"
  elseif opcode == 2001 then opcode_name = "OP_UPDATE"
  elseif opcode == 2002 then opcode_name = "OP_INSERT"
  elseif opcode == 2003 then opcode_name = "RESERVED"
  elseif opcode == 2004 then opcode_name = "OP_QUERY"
  elseif opcode == 2005 then opcode_name = "OP_GET_MORE"
  elseif opcode == 2006 then opcode_name = "OP_DELETE"
  elseif opcode == 2007 then opcode_name = "OP_KILL_CURSORS"
  elseif opcode == 2010 then opcode_name = "OP_COMMAND"
  elseif opcode == 2011 then opcode_name = "OP_COMMANDREPLY" end

  return opcode_name
end

function get_flag_description(flags)
  local flags_description = "Unknown"

      if flags == 0 then flags_description = "Reserved"
  elseif flags == 1 then flags_description = "TailableCursor"
  elseif flags == 2 then flags_description = "SlaveOk.Allow"
  elseif flags == 3 then flags_description = "OplogReplay"
  elseif flags == 4 then flags_description = "NoCursorTimeout"
  elseif flags == 5 then flags_description = "AwaitData"
  elseif flags == 6 then flags_description = "Exhaust"
  elseif flags == 7 then flags_description = "Partial"
  elseif 8 <= flags and flags <= 31 then flags_description = "Reserved" end

  return flags_description
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(59274, mongodb_protocol)
```

The packet details for `OP_QUERY` ends up looking like this:

![OP_QUERY message finished]({{ "/assets/creating-wireshark-dissectors-3/OP_QUERY-finished.png" | absolute_url }}){: style="margin-top: 15px; margin-bottom: 30px;" }

### Decoding the *OP_REPLY* message

I am not going to decode all the messages, but we can look at one more. It has the following fields:

![OP_REPLY message]({{ "/assets/creating-wireshark-dissectors-3/OP_REPLY-message.png" | absolute_url }}){: style="margin-top: 15px; margin-bottom: 30px;" }

We have one new type here: int64. We won't touch the *documents* field, as that gets to
complicated. We make the following fields:

```lua
response_flags =ProtoField.int32 ("mongodb.response_flags" ,"responseFlags" ,base.DEC)
cursor_id      =ProtoField.int64 ("mongodb.cursor_id"      ,"cursorId"      ,base.DEC)
starting_from  =ProtoField.int32 ("mongodb.starting_from"  ,"startingFrom"  ,base.DEC)
number_returned=ProtoField.int32 ("mongodb.number_returned","numberReturned",base.DEC)
documents      =ProtoField.none  ("mongodb.documents"      ,"documents"     ,base.HEX)
```

We must also add the fields to the `fields` table:

```lua
mongodb_protocol.fields = {
  message_length, request_id, response_to, opcode,                     -- Header
  flags, full_coll_name, number_to_skip, number_to_return, query,      -- OP_QUERY
  response_flags, cursor_id, starting_from, number_returned, documents -- OP_REPLY
}
```

Parsing the fields are done like this:

```lua
if opcode_name == "OP_QUERY" then
...
elseif opcode_name == "OP_REPLY" then
  local response_flags_number = buffer(16,4):le_uint()
  local response_flags_description = get_response_flag_description(response_flags_number)

  subtree:add_le(response_flags, buffer(16,4)):append_text(" (" .. response_flags_description .. ")")
  subtree:add_le(cursor_id,      buffer(20,8))
  subtree:add_le(starting_from,  buffer(28,4))
  subtree:add_le(number_returned,buffer(32,4))
  subtree:add_le(documents,      buffer(36,length-36))
end
```

It's like how the other fields are parsed. `cursor_id` is an int64, which means it's 8 bytes long
(8*8 = 64). That means we must read 8 bytes. The lookup function for the response flags looks
like this:

```lua
function get_response_flag_description(flags)
  local flags_description = "Unknown"

      if flags == 0 then flags_description = "CursorNotFound"
  elseif flags == 1 then flags_description = "QueryFailure"
  elseif flags == 2 then flags_description = "ShardConfigStale"
  elseif flags == 3 then flags_description = "AwaitCapable"
  elseif 4 <= flags and flags <= 31 then flags_description = "Reserved" end

  return flags_description
end
```

An *OP_REPLY* message will finally look like this in the packet details pane:

![OP_REPLY message finished]({{ "/assets/creating-wireshark-dissectors-3/OP_REPLY-finished.png" | absolute_url }}){: style="margin-top: 15px; margin-bottom: 30px;" }

The documents field is pretty much unparsed. It's simply read as a string. The final code looks
like this:

```lua
mongodb_protocol = Proto("MongoDB",  "MongoDB Protocol")

-- Header fields
message_length  = ProtoField.int32 ("mongodb.message_length"  , "messageLength"     , base.DEC)
request_id      = ProtoField.int32 ("mongodb.requestid"       , "requestID"         , base.DEC)
response_to     = ProtoField.int32 ("mongodb.responseto"      , "responseTo"        , base.DEC)
opcode          = ProtoField.int32 ("mongodb.opcode"          , "opCode"            , base.DEC)

-- Payload fields
flags           = ProtoField.int32 ("mongodb.flags"           , "flags"             , base.DEC)
full_coll_name  = ProtoField.string("mongodb.full_coll_name"  , "fullCollectionName", base.ASCII)
number_to_skip  = ProtoField.int32 ("mongodb.number_to_skip"  , "numberToSkip"      , base.DEC)
number_to_return= ProtoField.int32 ("mongodb.number_to_return", "numberToReturn"    , base.DEC)
query           = ProtoField.none  ("mongodb.query"           , "query"             , base.HEX)

response_flags  = ProtoField.int32 ("mongodb.response_flags"  , "responseFlags"     , base.DEC)
cursor_id       = ProtoField.int64 ("mongodb.cursor_id"       , "cursorId"          , base.DEC)
starting_from   = ProtoField.int32 ("mongodb.starting_from"   , "startingFrom"      , base.DEC)
number_returned = ProtoField.int32 ("mongodb.number_returned" , "numberReturned"    , base.DEC)
documents       = ProtoField.none  ("mongodb.documents"       , "documents"         , base.HEX)

mongodb_protocol.fields = {
  message_length, request_id, response_to, opcode,                     -- Header
  flags, full_coll_name, number_to_skip, number_to_return, query,      -- OP_QUERY
  response_flags, cursor_id, starting_from, number_returned, documents -- OP_REPLY
}

function mongodb_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = mongodb_protocol.name

  local subtree = tree:add(mongodb_protocol, buffer(), "MongoDB Protocol Data")

  -- Header
  subtree:add_le(message_length, buffer(0,4))
  subtree:add_le(request_id,     buffer(4,4))
  subtree:add_le(response_to,    buffer(8,4))
  local opcode_number = buffer(12,4):le_uint()
  local opcode_name = get_opcode_name(opcode_number)
  subtree:add_le(opcode,         buffer(12,4)):append_text(" (" .. opcode_name .. ")")

  -- Payload
  if opcode_name == "OP_QUERY" then
    local flags_number = buffer(16,4):le_uint()
    local flags_description = get_flag_description(flags_number)
    subtree:add_le(flags,      buffer(16,4)):append_text(" (" .. flags_description .. ")")

    -- Loop over string
    local string_length

    for i = 20, length - 1, 1 do
      if (buffer(i,1):le_uint() == 0) then
        string_length = i - 20
        break
      end
    end

    subtree:add_le(full_coll_name,   buffer(20,string_length))
    subtree:add_le(number_to_skip,   buffer(20+string_length,4))
    subtree:add_le(number_to_return, buffer(24+string_length,4))
    subtree:add_le(query,            buffer(28+string_length,length-string_length-28))
  elseif opcode_name == "OP_REPLY" then
    local response_flags_number = buffer(16,4):le_uint()
    local response_flags_description = get_response_flag_description(response_flags_number)

    subtree:add_le(response_flags,   buffer(16,4)):append_text(" (" .. response_flags_description .. ")")
    subtree:add_le(cursor_id,        buffer(20,8))
    subtree:add_le(starting_from,    buffer(28,4))
    subtree:add_le(number_returned,  buffer(32,4))
    subtree:add_le(documents,        buffer(36,length-36))
  end
end

function get_opcode_name(opcode)
  local opcode_name = "Unknown"

      if opcode ==    1 then opcode_name = "OP_REPLY"
  elseif opcode == 2001 then opcode_name = "OP_UPDATE"
  elseif opcode == 2002 then opcode_name = "OP_INSERT"
  elseif opcode == 2003 then opcode_name = "RESERVED"
  elseif opcode == 2004 then opcode_name = "OP_QUERY"
  elseif opcode == 2005 then opcode_name = "OP_GET_MORE"
  elseif opcode == 2006 then opcode_name = "OP_DELETE"
  elseif opcode == 2007 then opcode_name = "OP_KILL_CURSORS"
  elseif opcode == 2010 then opcode_name = "OP_COMMAND"
  elseif opcode == 2011 then opcode_name = "OP_COMMANDREPLY" end

  return opcode_name
end

function get_flag_description(flags)
  local flags_description = "Unknown"

      if flags == 0 then flags_description = "Reserved"
  elseif flags == 1 then flags_description = "TailableCursor"
  elseif flags == 2 then flags_description = "SlaveOk.Allow"
  elseif flags == 3 then flags_description = "OplogReplay"
  elseif flags == 4 then flags_description = "NoCursorTimeout"
  elseif flags == 5 then flags_description = "AwaitData"
  elseif flags == 6 then flags_description = "Exhaust"
  elseif flags == 7 then flags_description = "Partial"
  elseif 8 <= flags and flags <= 31 then flags_description = "Reserved" end

  return flags_description
end

function get_response_flag_description(flags)
  local flags_description = "Unknown"

      if flags == 0 then flags_description = "CursorNotFound"
  elseif flags == 1 then flags_description = "QueryFailure"
  elseif flags == 2 then flags_description = "ShardConfigStale"
  elseif flags == 3 then flags_description = "AwaitCapable"
  elseif 4 <= flags and flags <= 31 then flags_description = "Reserved" end

  return flags_description
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(59274, mongodb_protocol)
```

The remaining opcodes are missing from the script. I will not go further into details about those,
as it will just be repetition of what I've written about above.

You can find the final code [here][mikas-github-mongodb].

Two other blogs that describe Wireshark dissectors in Lua can be found [here][delog-wireshark-dissector-in-lua] and
[here][emmanueladenola-wireshark-dissector-with-lua].

If you want to find out how you can separate the fields into separate sub trees, you can take a
look at [part four]({% post_url 2018-12-16-creating-a-wireshark-dissector-in-lua-4 %}) of this
series.

[wikipedia-nul]: https://en.wikipedia.org/wiki/Null_character
[wikipedia-null-terminated-string]: https://en.wikipedia.org/wiki/Null-terminated_string
[mongodb-wire-protocol]: https://docs.mongodb.com/manual/reference/mongodb-wire-protocol/
[mikas-github-mongodb]: https://github.com/mika-s/mika-s.github.io/blob/master/assets/creating-wireshark-dissectors-3/mongodb.lua
[delog-wireshark-dissector-in-lua]: https://tewarid.github.io/2010/09/27/create-a-wireshark-dissector-in-lua.html
[emmanueladenola-wireshark-dissector-with-lua]: https://emmanueladenola.wordpress.com/2013/11/23/wireshark-dissector-with-lua/
