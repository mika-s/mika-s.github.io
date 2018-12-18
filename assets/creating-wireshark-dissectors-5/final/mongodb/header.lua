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
    message_length  = ProtoField.int32("mongodb.message_length"  , "messageLength"     , base.DEC),
    request_id      = ProtoField.int32("mongodb.requestid"       , "requestID"         , base.DEC),
    response_to     = ProtoField.int32("mongodb.responseto"      , "responseTo"        , base.DEC),
    opcode          = ProtoField.int32("mongodb.opcode"          , "opCode"            , base.DEC)
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
    headerSubtree:add_le(m.opcode,         buffer(12,4)):append_text(" (" .. opcode_name .. ")")

    return opcode_name
end

return m
