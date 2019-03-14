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

local m = {
    response_flags  = ProtoField.int32 ("mongodb.response_flags"  , "responseFlags"     , base.DEC),
    cursor_id       = ProtoField.int64 ("mongodb.cursor_id"       , "cursorId"          , base.DEC),
    starting_from   = ProtoField.int32 ("mongodb.starting_from"   , "startingFrom"      , base.DEC),
    number_returned = ProtoField.int32 ("mongodb.number_returned" , "numberReturned"    , base.DEC),
    documents       = ProtoField.none  ("mongodb.documents"       , "documents"         , base.HEX)
}

function m.get_fields()
    local fields = {
        response_flags = m.response_flags,
        cursor_id = m.cursor_id,
        starting_from = m.starting_from,
        number_returned = m.number_returned,
        documents = m.documents
    }

    return fields
end

function m.parse(payloadSubtree, buffer, length)
    local response_flags_number = buffer(16,4):le_uint()
    local response_flags_description = get_response_flag_description(response_flags_number)

    payloadSubtree:add_le(m.response_flags,  buffer(16,4)):append_text(" (" .. response_flags_description .. ")")
    payloadSubtree:add_le(m.cursor_id,       buffer(20,8))
    payloadSubtree:add_le(m.starting_from,   buffer(28,4))
    payloadSubtree:add_le(m.number_returned, buffer(32,4))
    payloadSubtree:add_le(m.documents,       buffer(36,length-36))
end

return m
