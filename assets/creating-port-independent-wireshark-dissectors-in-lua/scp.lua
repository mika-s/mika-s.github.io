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
