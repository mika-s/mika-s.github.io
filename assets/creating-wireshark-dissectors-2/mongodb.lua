mongodb_protocol = Proto("MongoDB",  "MongoDB Protocol")

message_length  = ProtoField.int32("mongodb.message_length", "messageLength", base.DEC)
request_id      = ProtoField.int32("mongodb.requestid"     , "requestID"    , base.DEC)
response_to     = ProtoField.int32("mongodb.responseto"    , "responseTo"   , base.DEC)
opcode          = ProtoField.int32("mongodb.opcode"        , "opCode"       , base.DEC)

mongodb_protocol.fields = { message_length, request_id, response_to, opcode }

function mongodb_protocol.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length == 0 then return end

	pinfo.cols.protocol = mongodb_protocol.name

	local subtree = tree:add(mongodb_protocol, buffer(), "MongoDB Protocol Data")

    subtree:add_le(message_length, buffer(0,4))
    subtree:add_le(request_id,     buffer(4,4))
    subtree:add_le(response_to,    buffer(8,4))

    local opcode = buffer(12,4):le_uint()
    local opcode_name = get_opcode_name(opcode)
    subtree:add_le(opcode,         buffer(12,4)):append_text(" (" .. opcode_name .. ")")
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

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(59274, mongodb_protocol)
