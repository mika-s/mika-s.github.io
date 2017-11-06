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
    subtree:add_le(opcode,         buffer(12,4))
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(59274, mongodb_protocol)
