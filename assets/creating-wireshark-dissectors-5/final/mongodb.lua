package.prepend_path("plugins/mongodb")
local helpers  = require("helpers")
local header   = require("header")
local op_query = require("OP_QUERY")
local op_reply = require("OP_REPLY")

mongodb_protocol = Proto("MongoDB", "MongoDB Protocol")

local header_fields   =   header.get_fields()
local op_query_fields = op_query.get_fields()
local op_reply_fields = op_reply.get_fields()

helpers.merge_tables(  header_fields, mongodb_protocol.fields)
helpers.merge_tables(op_query_fields, mongodb_protocol.fields)
helpers.merge_tables(op_reply_fields, mongodb_protocol.fields)

function mongodb_protocol.dissector(buffer, pinfo, tree)
    local length = buffer:len()
    if length == 0 then return end

    pinfo.cols.protocol = mongodb_protocol.name

    local subtree        =    tree:add(mongodb_protocol, buffer(), "MongoDB Protocol Data")
    local headerSubtree  = subtree:add(mongodb_protocol, buffer(), "Header")
    local payloadSubtree = subtree:add(mongodb_protocol, buffer(), "Payload")

    local opcode_name = header.parse(headerSubtree, buffer)

        if opcode_name == "OP_QUERY" then op_query.parse(payloadSubtree, buffer, length)
    elseif opcode_name == "OP_REPLY" then op_reply.parse(payloadSubtree, buffer, length) end
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(59274, mongodb_protocol)
