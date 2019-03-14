---
layout: post
title:  "Creating a Wireshark dissector in Lua - part 5 (modularization)"
date:   2018-12-18 18:00:00 +0100
categories: wireshark lua dissector
---

This post continues where [the fourth post]({% post_url 2018-12-16-creating-a-wireshark-dissector-in-lua-4 %}) left off.
Here I will explain how we can separate the code into several modules. In my case, I will separate the header and payload
parts into separate files.

### Dividing up the code

I want to have a separate file for the header stuff, a file for the OP_REPLY message, a file for the OP_QUERY message,
a file for helper functions and the main file. The final file structure looks like this:

![File structure]({{ "/assets/creating-wireshark-dissectors-5/file-structure.png" | absolute_url }}){: style="margin-top: 15px; margin-bottom: 30px;" }

I've made a separate folder called *mongodb*. This will contain all the modules for the protocol. The main file still lives
in the plugin director.

### Requiring the files

In Lua we generally have two functions that can load files: `dofile` and `require`. I'll use `require` for the following [reason][lua-pil-8.1]:

*Lua offers a higher-level function to load and run libraries, called require. Roughly, require does the same job as dofile, but with two important differences. First, require searches for the file in a path; second, require controls whether a file has already been run to avoid duplicating the work. Because of these features, require is the preferred function in Lua for loading libraries.*

In addition to `require` we have to use `package.prepend_path()`. `package.path` is where Wireshark looks for files.
`prepend_path` will add a new path to `package.path`. In my particular case, the working directory is the Wireshark root
directory, which means I have to add *"plugins/mongodb"* to `package.path`. You might have another path than mine if you
use another OS than me, or place the files in another folder (e.g. user plugins directory rather than the global plugins
directory).

To import modules we have to add the following at the start of the main file:

```lua
package.prepend_path("plugins/mongodb")
local header = require("header")
```

As mentioned, the `prepend_path()` line will make it possible for Wireshark to find files in the *plugins/mongodb* directory,
and the `require` line will import the code in header.lua. The file ending should not be included. As we see further down,
I'm "exporting" a table (object) in header.lua that we can use with dot notation in the main file: `local var = header.myFunction()`.

### Creating header.lua

I'm moving some of the header related code from the main file to the header.lua file (click [here][mikas-github-part4-mongodb] to
see what the code looked like initially):

```lua
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

local m = {}

function m.parse(headerSubtree, buffer, message_length, request_id, response_to, opcode)
    headerSubtree:add_le(message_length, buffer(0,4))
    headerSubtree:add_le(request_id,     buffer(4,4))
    headerSubtree:add_le(response_to,    buffer(8,4))

    local opcode_number = buffer(12,4):le_uint()
    local opcode_name = get_opcode_name(opcode_number)
    headerSubtree:add_le(opcode, buffer(12,4)):append_text(" (" .. opcode_name .. ")")

    return opcode_name
end

return m
```

I've moved `get_opcode_name()` from mongodb.lua to header.lua. I've also made a table (object) called `m` where I create
a new function called `parse()`. The `parse()` function contains the header fields parsing logic that was in the main
file before. Because `headerSubtree` is a reference type I don't have to return it from the function: it will still be
modified after we return from `parse()`. However, I need `opcode_name` in the main file, so I'll return that. The table
`m` is returned from the file so it can be used in the main file. We don't have to add `get_opcode_name()` to `m` because
it's only used inside header.lua.

The main file looks like this after some of the header stuff is taken out:

```lua
package.prepend_path("plugins/mongodb")
local header = require("header")

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
    local headerSubtree = subtree:add(mongodb_protocol, buffer(), "Header")
    local payloadSubtree = subtree:add(mongodb_protocol, buffer(), "Payload")

    -- Header
    local opcode_name = header.parse(headerSubtree, buffer, message_length, request_id, response_to, opcode)

    -- Payload
    if opcode_name == "OP_QUERY" then
        local flags_number = buffer(16,4):le_uint()
        local flags_description = get_flag_description(flags_number)
        payloadSubtree:add_le(flags,      buffer(16,4)):append_text(" (" .. flags_description .. ")")

        -- Loop over string
        local string_length
        for i = 20, length - 1, 1 do
            if (buffer(i,1):le_uint() == 0) then
                string_length = i - 20
                break
            end
        end

        payloadSubtree:add_le(full_coll_name,   buffer(20,string_length))
        payloadSubtree:add_le(number_to_skip,   buffer(20+string_length,4))
        payloadSubtree:add_le(number_to_return, buffer(24+string_length,4))
        payloadSubtree:add_le(query,            buffer(28+string_length,length-string_length-28))
    elseif opcode_name == "OP_REPLY" then
        local response_flags_number = buffer(16,4):le_uint()
        local response_flags_description = get_response_flag_description(response_flags_number)

        payloadSubtree:add_le(response_flags,   buffer(16,4)):append_text(" (" .. response_flags_description .. ")")
        payloadSubtree:add_le(cursor_id,        buffer(20,8))
        payloadSubtree:add_le(starting_from,    buffer(28,4))
        payloadSubtree:add_le(number_returned,  buffer(32,4))
        payloadSubtree:add_le(documents,        buffer(36,length-36))
    end
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

Notice the call to `header.parse()`. As mentioned, I return `opcode_name` because I need it further down in the code. The
subtree `headerSubtree` will also be modified (fields added to it), because it's a reference type and thus mutable inside
`parse()`.

### Creating OP_QUERY.lua and OP_REPLY.lua

As you can see, there are still a lot of header stuff in the main file that can be moved into the header module. I'll
move that later, but first I want to do the same to the OP_QUERY and OP_REPLY parsing code as I did with the header code.

I'm making OP_QUERY.lua and moving `get_flag_description()` and the OP_QUERY parsing logic to it:

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

local m = {}

function m.parse(payloadSubtree, buffer, length, flags, full_coll_name, number_to_skip, number_to_return, query)
    local flags_number = buffer(16,4):le_uint()
    local flags_description = get_flag_description(flags_number)
    payloadSubtree:add_le(flags, buffer(16,4)):append_text(" (" .. flags_description .. ")")

    -- Loop over string
    local string_length
    for i = 20, length - 1, 1 do
        if (buffer(i,1):le_uint() == 0) then
            string_length = i - 20
            break
        end
    end

    payloadSubtree:add_le(full_coll_name,   buffer(20,string_length))
    payloadSubtree:add_le(number_to_skip,   buffer(20+string_length,4))
    payloadSubtree:add_le(number_to_return, buffer(24+string_length,4))
    payloadSubtree:add_le(query,            buffer(28+string_length,length-string_length-28))
end

return m
```

I'm also making OP_REPLY.lua and moving `get_response_flag_description()` and the OP_REPLY parsing logic to it:

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

local m = {}

function m.parse(payloadSubtree, buffer, response_flags, cursor_id, starting_from, number_returned, documents)
    local response_flags_number = buffer(16,4):le_uint()
    local response_flags_description = get_response_flag_description(response_flags_number)

    payloadSubtree:add_le(response_flags,  buffer(16,4)):append_text(" (" .. response_flags_description .. ")")
    payloadSubtree:add_le(cursor_id,       buffer(20,8))
    payloadSubtree:add_le(starting_from,   buffer(28,4))
    payloadSubtree:add_le(number_returned, buffer(32,4))
    payloadSubtree:add_le(documents,       buffer(36,length-36))
end

return m
```

The main file will now look like this:

```lua
package.prepend_path("plugins/mongodb")
local header   = require("header")
local op_query = require("OP_QUERY")
local op_reply = require("OP_REPLY")

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
    local headerSubtree = subtree:add(mongodb_protocol, buffer(), "Header")
    local payloadSubtree = subtree:add(mongodb_protocol, buffer(), "Payload")

    -- Header
    local opcode_name = header.parse(headerSubtree, buffer, message_length, request_id, response_to, opcode)

    -- Payload
    if opcode_name == "OP_QUERY" then
        op_query.parse(payloadSubtree, buffer, length, flags, full_coll_name, number_to_skip, number_to_return, query)
    elseif opcode_name == "OP_REPLY" then
        op_reply.parse(payloadSubtree, buffer, response_flags, cursor_id, starting_from, number_returned, documents)
    end
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(59274, mongodb_protocol)
```

We have to `require` the two new files, of course.

### Moving the field creation code

The main file, *mongodb.lua*, looks cleaner now. There are still header, OP_QUERY and OP_REPLY related logic remaining
that can be moved into their respective files. After moving the field creation code we can also get rid of the awkward
calls to the three `parse()` methods. They contain too many parameters that they should know about from the module
already.

Let's move the field creation code inside the modules. Here is header.lua:

```lua
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

local m = {
    message_length = ProtoField.int32("mongodb.message_length", "messageLength", base.DEC),
    request_id     = ProtoField.int32("mongodb.requestid"     , "requestID"    , base.DEC),
    response_to    = ProtoField.int32("mongodb.responseto"    , "responseTo"   , base.DEC),
    opcode         = ProtoField.int32("mongodb.opcode"        , "opCode"       , base.DEC)
}

function m.get_fields()
    local fields = {
        message_length = m.message_length,
        request_id = m.request_id,
        response_to = m.response_to,
        opcode = m.opcode
    }

    return fields
end

function m.parse(headerSubtree, buffer)
    headerSubtree:add_le(m.message_length, buffer(0,4))
    headerSubtree:add_le(m.request_id,     buffer(4,4))
    headerSubtree:add_le(m.response_to,    buffer(8,4))

    local opcode_number = buffer(12,4):le_uint()
    local opcode_name = get_opcode_name(opcode_number)
    headerSubtree:add_le(m.opcode, buffer(12,4)):append_text(" (" .. opcode_name .. ")")

    return opcode_name
end

return m
```

The fields exists as members of the `m` table. The `get_fields()` function is used to get the access to them
outside the module. Also notice that the `parse()` function is accessing the fields through the module itself,
rather than being passed them as arguments.

I have also moved the fields for OP_QUERY and OP_REPLY into their respective modules. The main file looks like
this now:

```lua
package.prepend_path("plugins/mongodb")
local helpers  = require("helpers")
local header   = require("header")
local op_query = require("OP_QUERY")
local op_reply = require("OP_REPLY")

mongodb_protocol = Proto("MongoDB",  "MongoDB Protocol")

local   header_fields =   header.get_fields()
local op_query_fields = op_query.get_fields()
local op_reply_fields = op_reply.get_fields()

helpers.merge_tables(  header_fields, mongodb_protocol.fields)
helpers.merge_tables(op_query_fields, mongodb_protocol.fields)
helpers.merge_tables(op_reply_fields, mongodb_protocol.fields)

function mongodb_protocol.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then return end

    pinfo.cols.protocol = mongodb_protocol.name

    local       subtree  =    tree:add(mongodb_protocol, buffer(), "MongoDB Protocol Data")
    local headerSubtree  = subtree:add(mongodb_protocol, buffer(), "Header")
    local payloadSubtree = subtree:add(mongodb_protocol, buffer(), "Payload")

    local opcode_name = header.parse(headerSubtree, buffer)

        if opcode_name == "OP_QUERY" then op_query.parse(payloadSubtree, buffer, length)
    elseif opcode_name == "OP_REPLY" then op_reply.parse(payloadSubtree, buffer) end
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(59274, mongodb_protocol)
```

You can see that all the field initialization code is gone. We still have to insert the fields in
`mongodb_protocol.fields`, which is why we get them with `get_fields()`. I use a helper function
called `merge_tables()` to merge the three tables together. I've put that function in a module
called helpers.lua. It looks like this:

```lua
local m = {}

-- Made by Doug Currie (https://stackoverflow.com/users/33252/doug-currie)
-- on Stack Overflow. https://stackoverflow.com/questions/1283388/lua-merge-tables
function m.merge_tables(from, to)
    for k,v in pairs(from) do to[k] = v end
end

return m
```

As you can see I found the code on Stack Overflow.

Fianlly you can see that the call to `parse()` has been shortened down to:

```lua
local opcode_name = header.parse(headerSubtree, buffer)
    if opcode_name == "OP_QUERY" then op_query.parse(payloadSubtree, buffer, length)
elseif opcode_name == "OP_REPLY" then op_reply.parse(payloadSubtree, buffer) end
```

We don't have to pass in all the fields variables anymore, because they've been put into the modules
themselves.

You can find the final code [here][mikas-github-mongodb].

So that's pretty much how you can separate the code into several files.

tl;dr:

* Use `package.prepend_path()` to add a directory to the package path.
* Use `require()` to read code from another file.
* Make a table (object) inside the module file called `m` or whatever you want.
* Add methods and variables to the table.
* Return the table you made and use it in the main file.

[lua-pil-8.1]: https://www.lua.org/pil/8.1.html
[mikas-github-part4-mongodb]: https://github.com/mika-s/mika-s.github.io/blob/master/assets/creating-wireshark-dissectors-4/mongodb.lua
[mikas-github-mongodb]: https://github.com/mika-s/mika-s.github.io/blob/master/assets/creating-wireshark-dissectors-5/final
