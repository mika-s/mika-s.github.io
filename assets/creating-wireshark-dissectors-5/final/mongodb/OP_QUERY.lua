function get_response_flag_description(flags)
    local flags_description = "Unknown"

        if flags == 0 then flags_description = "CursorNotFound"
    elseif flags == 1 then flags_description = "QueryFailure"
    elseif flags == 2 then flags_description = "ShardConfigStale"
    elseif flags == 3 then flags_description = "AwaitCapable"
    elseif 4 <= flags and flags <= 31 then flags_description = "Reserved" end

    return flags_description
end

local m = {
    flags            = ProtoField.int32 ("mongodb.flags"           , "flags"             , base.DEC),
    full_coll_name   = ProtoField.string("mongodb.full_coll_name"  , "fullCollectionName", base.ASCII),
    number_to_skip   = ProtoField.int32 ("mongodb.number_to_skip"  , "numberToSkip"      , base.DEC),
    number_to_return = ProtoField.int32 ("mongodb.number_to_return", "numberToReturn"    , base.DEC),
    query            = ProtoField.none  ("mongodb.query"           , "query"             , base.HEX)
}

function m.get_fields()
    local fields = {
        flags = m.flags,
        full_coll_name = m.full_coll_name,
        number_to_skip = m.number_to_skip,
        number_to_return = m.number_to_return,
        query = m.query
    }

    return fields
end

function m.parse(payloadSubtree, buffer, length)
    local flags_number = buffer(16,4):le_uint()
    local flags_description = get_flag_description(flags_number)
    payloadSubtree:add_le(m.flags,      buffer(16,4)):append_text(" (" .. flags_description .. ")")

    -- Loop over string
    local string_length
    for i = 20, length - 1, 1 do
        if (buffer(i,1):le_uint() == 0) then
            string_length = i - 20
            break
        end
    end

    payloadSubtree:add_le(m.full_coll_name,   buffer(20,string_length))
    payloadSubtree:add_le(m.number_to_skip,   buffer(20+string_length,4))
    payloadSubtree:add_le(m.number_to_return, buffer(24+string_length,4))
    payloadSubtree:add_le(m.query,            buffer(28+string_length,length-string_length-28))
end

return m
