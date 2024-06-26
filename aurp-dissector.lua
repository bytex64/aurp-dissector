-- AURP dissector
-- Copyright 2024 Chip Black (bytex64@bytex64.net)
-- You can copy this and use it as long as you're doing it for good reasons.
-- If you use this commercially, let me know so I can have a laugh at your
-- expense.

-- Most of this is based on "AppleTalk Update-Based Routing Protocol: Enhanced AppleTalk Routing",
-- Copyright Apple Computer Inc., 1993. Here is a copy:
-- https://wiki.preterhuman.net/images/6/60/AURP_Enhanced_ATalk_Routing.pdf

flag_text_set = { "Set", "Not set" }
flag_text_active = { "Active", "Inactive" }
flag_tuple_format = { "Optimized", "Long" }

aurp_protocol = Proto("AURP",  "AppleTalk Update-Based Routing Protocol")

-- Network tuples are used in a number of responses
network_tuple = ProtoField.none("aurp.network_tuple", "Network")
-- event code used in updates, not responses
network_tuple_event_code = ProtoField.uint8("aurp.network_tuple.event_code", "Event code")
network_tuple_network = ProtoField.uint16("aurp.network_tuple.network", "Network number")
network_tuple_range_flag = ProtoField.bool("aurp.network_tuple.is_range", "Range", 8, flag_text_set, 0x80)
network_tuple_distance = ProtoField.uint8("aurp.network_tuple.distance", "Distance", nil, nil, 0x7F)
network_tuple_network_range_end = ProtoField.uint16("aurp.network_tuple.network_end", "Network range end")

-- Domain header
di_dest = ProtoField.none("aurp.dest_di", "Destination DI")
di_src = ProtoField.none("aurp.src_di", "Source DI")
ip4_di_dest = ProtoField.ipv4("aurp.dest_di.addr", "IPv4 destination")
ip4_di_src = ProtoField.ipv4("aurp.dest_di.addr", "IPv4 source")
aurp_version = ProtoField.uint16("aurp.version", "Version")
aurp_reserved = ProtoField.uint16("aurp.reserved", "Reserved")
aurp_type = ProtoField.uint16("aurp.type", "Type")

-- Technically AURP-Tr header
aurp_connection_id = ProtoField.uint16("aurp.connection_id", "Connection ID", base.HEX)
aurp_sequence_no = ProtoField.uint16("aurp.sequence_no", "Sequence no.")

-- AURP header
aurp_command = ProtoField.uint16("aurp.command", "Command code")
aurp_flags            = ProtoField.uint16("aurp.flags", "Flags", base.HEX)
aurp_flags_sui_na     = ProtoField.bool("aurp.flags.sui_na", "SUI Network Added", 16, flag_text_set, 0x4000)
aurp_flags_sui_nd_nrc = ProtoField.bool("aurp.flags.sui_nd_nrc", "SUI Network Route Change/Deleted", 16, flag_text_set, 0x2000)
aurp_flags_sui_ndc    = ProtoField.bool("aurp.flags.sui_ndc", "SUI Network Distance Change", 16, flag_text_set, 0x1000)
aurp_flags_sui_zc     = ProtoField.bool("aurp.flags.sui_zc", "SUI Zone Change", 16, flag_text_set, 0x0800)
aurp_flags_last       = ProtoField.bool("aurp.flags.last", "Last", 16, flag_text_set, 0x8000)
aurp_flags_remapping  = ProtoField.bool("aurp.flags.remapping", "Remapping", 16, flag_text_active, 0x4000)
aurp_flags_hop_count  = ProtoField.bool("aurp.flags.hop_count", "Hop-count reduction", 16, flag_text_active, 0x2000)
aurp_flags_reserved1  = ProtoField.bool("aurp.flags.reserved1", "Reserved", 16, flag_text_set, 0x1000)
aurp_flags_reserved2  = ProtoField.bool("aurp.flags.reserved2", "Reserved", 16, flag_text_set, 0x0800)
aurp_flags_szi        = ProtoField.bool("aurp.flags.szi", "Send zone information", 16, flag_text_set, 0x4000)

-- Routing Information Request (no fields)

-- Routing Information Response
aurp_ri_rsp = ProtoField.none("aurp.ri_rsp", "Routing Information Response")

-- Routing Information Acknowledgement (no fields)

-- Routing Information Update
aurp_ri_upd = ProtoField.none("aurp.ri_upd", "Routing Information Update")

-- Router Down
aurp_router_down            = ProtoField.none("aurp.router_down", "Router Down")
aurp_router_down_error_code = ProtoField.int16("aurp.router_down", "Error Code")

-- Zone Information Request
-- subcode is used for both requests and responses
aurp_zone_info_subcode = ProtoField.uint16("aurp.zone_info.subcode", "Subcode")
aurp_zone_info_req     = ProtoField.none("aurp.zone_info_req", "Zone Information Request")
aurp_zone_info_network = ProtoField.uint16("aurp.zone_info_req.network", "Network")

-- Zone Information Response
aurp_zone_info_rsp            = ProtoField.none("aurp.zone_info_rsp", "Zone Information Response")
aurp_zone_info_rsp_num_tuples = ProtoField.uint16("aurp.zone_info_rsp.num_tuples", "Number of zone tuples")
zone_tuple                = ProtoField.none("aurp.zone_tuple", "Zone")
zone_tuple_network        = ProtoField.uint16("aurp.zone_tuple.network", "Network number")
zone_tuple_format         = ProtoField.bool("aurp.zone_tuple.long", "Tuple format", 8, flag_tuple_format, 0x80)
zone_tuple_name_len       = ProtoField.uint8("aurp.zone_tuple.name_len", "Zone name length", nil, nil, 0x7F)
zone_tuple_name           = ProtoField.string("aurp.zone_tuple.name", "Name", base.ASCII)
zone_tuple_name_offset    = ProtoField.uint16("aurp.zone_tuple.long", "Name offset", nil, nil, 0x7FFF)

-- Get Zones Net Request
aurp_get_zones_net_req          = ProtoField.none("aurp.get_zones_net_req", "Get Zones Net Request")
aurp_get_zones_net_req_name_len = ProtoField.uint8("aurp.get_zones_net_req.name_len", "Name length")
aurp_get_zones_net_req_name     = ProtoField.string("aurp.get_zones_net_req.name", "Name")

-- Get Zones Net Response
aurp_get_zones_net_rsp            = ProtoField.none("aurp.get_zones_net_rsp",
  "Get Zones Net Response")
aurp_get_zones_net_rsp_name_len   = ProtoField.uint8("aurp.get_zones_net_rsp.name_len",
  "Name length")
aurp_get_zones_net_rsp_name       = ProtoField.string("aurp.get_zones_net_rsp.name", "Name")
aurp_get_zones_net_rsp_num_tuples = ProtoField.string("aurp.get_zones_net_rsp.name",
  "Number of network tuples")

-- Get Domain Zone List Request
aurp_get_domain_zone_list_req             = ProtoField.none("aurp.get_domain_zone_list_req",
  "Get Domain Zone List Request")
aurp_get_domain_zone_list_req_start_index = ProtoField.uint16("aurp.get_domain_zone_list_req.start",
  "Start index")

-- Get Domain Zone List Response
aurp_get_domain_zone_list_rsp = ProtoField.none("aurp.get_domain_zone_list_rsp",
  "Get Domain Zone List Response")
aurp_get_domain_zone_list_rsp_start_index = ProtoField.none("aurp.get_domain_zone_list_rsp.start",
  "Start index")


-- Open Request
aurp_open_req              = ProtoField.none("aurp.open_req", "Open Request")
aurp_open_req_version      = ProtoField.uint16("aurp.open_req.version", "Version number")
aurp_open_req_option_count = ProtoField.uint8("aurp.open_req.option_count", "Option count")
aurp_open_req_option       = ProtoField.uint8("aurp.open_req.option", "Option")

-- Open Response
aurp_open_rsp              = ProtoField.none("aurp.open_rsp", "Open Response")
aurp_open_rsp_update_rate  = ProtoField.int16("aurp.open_rsp.update_rate", "Update rate")
aurp_open_rsp_error_code   = ProtoField.int16("aurp.open_rsp.error_code", "Error code")
aurp_open_rsp_option_count = ProtoField.uint8("aurp.open_rsp.option_count", "Option count")
aurp_open_rsp_option       = ProtoField.uint8("aurp.open_rsp.option", "Option")

-- Tickle

-- Tickle Acknowledgement

aurp_protocol.fields = {
  di_dest,
  di_src,
  ip4_di_dest,
  ip4_di_src,

  network_tuple,
  network_tuple_event_code,
  network_tuple_network,
  network_tuple_range_flag,
  network_tuple_distance,
  network_tuple_network_range_end,

  aurp_version,
  aurp_reserved,
  aurp_type,

  aurp_connection_id,
  aurp_sequence_no,
  aurp_command,
  aurp_flags,
  aurp_flags_sui_na,
  aurp_flags_sui_nd_nrc,
  aurp_flags_sui_ndc,
  aurp_flags_sui_zc,
  aurp_flags_last,
  aurp_flags_remapping,
  aurp_flags_hop_count,
  aurp_flags_reserved1,
  aurp_flags_reserved2,
  aurp_flags_szi,

  aurp_ri_rsp,

  aurp_ri_upd,

  aurp_router_down,
  aurp_router_down_error_code,

  aurp_zone_info_req,
  aurp_zone_info_network,

  aurp_zone_info_rsp,
  aurp_zone_info_subcode,
  aurp_zone_info_rsp_num_tuples,
  zone_tuple,
  zone_tuple_network,
  zone_tuple_format,
  zone_tuple_name_len,
  zone_tuple_name,
  zone_tuple_name_offset,

  aurp_get_zones_net_req,
  aurp_get_zones_net_req_name,

  aurp_get_zones_net_rsp,
  aurp_get_zones_net_rsp_name_len,
  aurp_get_zones_net_rsp_name,
  aurp_get_zones_net_rsp_num_tuples,

  aurp_get_domain_zone_list_req,
  aurp_get_domain_zone_list_req_start_index,

  aurp_open_req,
  aurp_open_req_version,
  aurp_open_req_option_count,
  aurp_open_req_option,

  aurp_open_rsp,
  aurp_open_rsp_update_rate,
  aurp_open_rsp_error_code,
  aurp_open_rsp_option_count,
  aurp_open_rsp_option,
}

error_codes = {
  [-1] = "Normal connection close",
  [-2] = "Routing loop detected",
  [-3] = "Connection out of sync",
  [-4] = "Option-negotiation error",
  [-5] = "Invalid version number",
  [-6] = "Insufficient resources for connection",
  [-7] = "Authentication error",
}

function error_code(c)
  local s = error_codes[c]
  if s == nil then
    return "Unknown"
  end
  return s
end

function parse_di(buffer, tree, dest)
  -- Get the length of the source DI
  local len = buffer(0, 1):uint() + 1
  local authority = buffer(1, 1):uint()
  local pf, buf, s
  if authority == 0 then
    buf = buffer(2, 0)
    s = "Null"
  elseif authority == 1 then
    if dest then
      pf = ip4_di_dest
    else
      pf = ip4_di_src
    end
    buf = buffer(4, 4)
    s = tostring(buf:ipv4())
  end

  local subtree
  if dest then
    subtree = tree:add(di_dest, buffer(0, len))
  else
    subtree = tree:add(di_src, buffer(0, len))
  end
  subtree:append_text(" (" .. s .. ")")
  if pf ~= nil then
    subtree:add(pf, buf)
  end

  return len
end

function parse_flags(buffer, command, tree)
  local n = buffer:uint()
  local subtree = tree:add(aurp_flags, buffer)
  if command == 1 or command == 8 then  -- Open-Req or RI-Req
    -- Send update information Zone Change flag (bit 13)
    subtree:add(aurp_flags_sui_na, buffer)
    subtree:add(aurp_flags_sui_nd_nrc, buffer)
    subtree:add(aurp_flags_sui_ndc, buffer)
    subtree:add(aurp_flags_sui_zc, buffer)
  elseif command == 2 or command == 7 then  -- Ri-Rsp or GDZL-Rsp
    subtree:add(aurp_flags_last, buffer)
  elseif command == 9 then  -- Open-Rsp
    subtree:add(aurp_flags_remapping, buffer)
    subtree:add(aurp_flags_hop_count, buffer)
    subtree:add(aurp_flags_reserved1, buffer)
    subtree:add(aurp_flags_reserved2, buffer)
  elseif command == 3 then  -- Ri-Ack
    subtree:add(aurp_flags_szi, buffer)
  end
end

function network_event_code(c)
  if c == 0 then
    return "Null"
  elseif c == 1 then
    return "Network Added"
  elseif c == 2 then
    return "Network Deleted"
  elseif c == 3 then
    return "Network Route Change"
  elseif c == 4 then
    return "Network Distance Change"
  elseif c == 5 then
    return "Zone Change"
  else
    return "Unknown"
  end
end

function parse_network_tuple(buffer, tree, is_event)
  local tuple_tree = tree:add(network_tuple, buffer(c))
  if is_event then
    local code = buffer(0, 1):uint()
    tuple_tree.text = network_event_code(code) .. " event"
    if code == 0 then
      -- Null events contain no data
      return 1
    end
    tuple_tree.add(network_tuple_event_code, buffer(0, 1))
    buffer = buffer(1)
  end
  local net_number = buffer(0, 2):uint()
  tuple_tree:add(network_tuple_network, buffer(0, 2))
  local is_range = bit32.extract(buffer(2, 1):uint(), 7) ~= 0
  tuple_tree:add(network_tuple_range_flag, buffer(2, 1))
  tuple_tree:add(network_tuple_distance, buffer(2, 1))
  if is_range then
    local net_range_end = buffer(3, 2):uint()
    tuple_tree:add(network_tuple_network_range_end, buffer(3, 2))
    tuple_tree:append_text(string.format(" range %d-%d ($%04x-$%04x)",
      net_number, net_range_end, net_number, net_range_end))
    -- there is an extra null byte after the range end
    tuple_tree:set_len(6)
    return 6
  else
    tuple_tree:append_text(string.format(" %d ($%04x)", net_number, net_number))
    if is_event then
      tuple_tree:set_len(4)
      return 4
    else
      tuple_tree:set_len(3)
      return 3
    end
  end
end

command_names = {
  [1] = "Routing Information Request",
  [2] = "Routing Information Response",
  [3] = "Routing Information Acknowledgement",
  [4] = "Routing Information Update",
  [5] = "Router Down",
  [6] = {
    [1] = "Zone Information Request",
    [3] = "Get Zones Net Request",
    [4] = "Get Domain Zone List Request",
  },
  [7] = {
    [1] = "Zone Information Response",
    [2] = "Zone Information Response",
    [3] = "Get Zones Net Response",
    [4] = "Get Domain Zone List Response",
  },
  [8] = "Open Request",
  [9] = "Open Response",
  [14] = "Tickle",
  [15] = "Tickle Acknowledgement",
}

function command_name(code, subcode)
  local name = command_names[code]
  if type(name) == "table" then
    local subname = name[subcode]
    if subname == nil then
      return "Unknown"
    end
    return subname .. " (subcode " .. subcode .. ")"
  elseif name == nil then
    return "Unknown"
  end
  return name
end

function parse_command_ri_rsp(buffer, tree)
  local subtree = tree:add(aurp_ri_rsp, buffer)
  if buffer:len() == 0 then
    subtree:append_text(" (empty)")
    return
  end
  local c = 0
  while c < buffer:len() do
    c = c + parse_network_tuple(buffer(c), subtree)
  end
end

function parse_command_ri_upd(buffer, tree)
  local subtree = tree:add(aurp_ri_upd, buffer)
  local c = 0
  while c < buffer:len() do
    c = c + parse_network_tuple(buffer(c), subtree, true)
  end
end

function parse_command_router_down(buffer, tree)
  local subtree = tree:add(aurp_router_down, buffer)
  local code = buffer(0, 2):int()
  subtree:add(aurp_router_down_error_code, buffer):append_text(" (" .. error_code(code) .. ")")
end

function parse_command_zone_req(buffer, tree)
  local subcode = buffer(0, 2):uint()

  local c = 2
  if subcode == 1 then
    -- subcode 1 is a Zone Info Request, a list of networks
    local subtree = tree:add(aurp_zone_info_req, buffer)
    while c < buffer:len() do
      subtree:add(aurp_zone_info_network, buffer(c, 2))
      c = c + 2
    end
  -- there is no subcode 2
  elseif subcode == 3 then
    -- subcode 3 is Get Zones Net Request, one zone name
    local subtree = tree:add(aurp_get_zones_net_req, buffer)
    subtree:add(aurp_zone_info_subcode, buffer(0, 2))
    local name_len = buffer(c, 1):uint()
    subtree:add(aurp_get_zones_net_req_name_len, buffer(c, 1))
    subtree:add(aurp_get_zones_net_req_name, buffer(c + 1, name_len))
  elseif subcode == 4 then
    -- subcode 4 is Get Domain Zone List Request, one start index
    local subtree = tree:add(aurp_get_domain_zone_list_req, buffer)
    subtree:add(aurp_zone_info_subcode, buffer(0, 2))
    subtree:add(aurp_get_domain_zone_list_req_start_index, buffer(c, 2))
  else
    tree:add_expert_info(PI_UNDECODED, PI_ERROR, "unknown zone request type")
  end
end

-- this accepts an offset argument (c) because it might need to look backwards in the buffer for
-- a string reference
function parse_zone_name_list(buffer, tree, c)
  local len
  local f3 = buffer(c + 2, 1):uint()
  local long = bit32.extract(f3, 7) == 0
  if long then
    len = f3 + 3
  else
    len = 4
  end
  local tuple_tree = tree:add(zone_tuple, buffer(c, len))
  tuple_tree:add(zone_tuple_network, buffer(c, 2))
  local zone_network = buffer(c, 2):uint()
  tuple_tree:append_text(string.format(" %d ($%04x) - ", zone_network, zone_network))
  tuple_tree:add(zone_tuple_format, buffer(c + 2, 1))

  if long then
    tuple_tree:add(zone_tuple_name_len, buffer(c + 2, 1))
    local zone_name = buffer(c + 3, len - 3):string(base.ASCII)
    tuple_tree:add(zone_tuple_name, buffer(c + 3, len - 3))
    tuple_tree:append_text(zone_name)
  else
    tuple_tree:add(zone_tuple_name_offset, buffer(c + 2, 2))
    local offset = bit32.band(buffer(c + 2, 2):uint(), 0x7FFF)
    -- offset is from the length byte of the first zone, which should be 6 bytes in
    -- 2 bytes subcode, 2 bytes number of tuples, 2 bytes network number of first zone
    local zone_name_length = buffer(6 + offset, 1):uint()
    local zone_name = buffer(7 + offset, zone_name_length):string(base.ASCII)
    tuple_tree:append_text(zone_name)
  end
  return len
end

function parse_command_zone_rsp(buffer, tree)
  local subcode = buffer(0, 2):uint()
  local c = 2

  if subcode == 1 or subcode == 2 then
    -- subcodes 1 and 2 are Zone Info Response, nonextended and extended, respectively
    -- nonextended and extended don't really need to be parsed any differently, though
    local subtree = tree:add(aurp_zone_info_rsp, buffer)
    subtree:add(aurp_zone_info_subcode, buffer(0, 2))
    subtree:add(aurp_zone_info_rsp_num_tuples, buffer(2, 2))
    c = c + 2

    while c < buffer:len() do
      c = c + parse_zone_name_list(buffer, subtree, c)
    end
  elseif subcode == 3 then
    -- subcode 3 is a Get Zones Net Response Packet
    local subtree = tree:add(aurp_get_zones_net_rsp, buffer)
    subtree:add(aurp_zone_info_subcode, buffer(0, 2))
    local name_len = buffer(2, 1):uint()
    subtree:add(aurp_get_zones_net_req_name_len, buffer(2, 1))
    c = c + 1
    subtree:add(aurp_get_zones_net_req_name, buffer(3, name_len))
    c = c + name_len
    subtree:add(aurp_get_zones_net_rsp_num_tuples, buffer(c, 2))
    c = c + 2
    while c < buffer:len() do
      c = c + parse_network_tuple(buffer(c), subtree)
    end
  elseif subcode == 4 then
    local subtree = tree:add(aurp_get_zones_net_rsp, buffer)
    subtree:add(aurp_zone_info_subcode, buffer(0, 2))
    subtree:add(aurp_get_domain_zone_list_rsp_start_index, buffer(2, 2))
    c = c + 2
    while c < buffer:len() do
      -- I am making an assumption here that the "zone list" is the same format as Zone Info
      -- Response. The documentation isn't clear, but it makes sense in context.
      c = c + parse_zone_name_list(buffer, subtree, c)
    end
  else
    tree:add_expert_info(PI_UNDECODED, PI_ERROR, "unknown zone response type")
  end
end

function parse_command_open_req(buffer, tree)
  local subtree = tree:add(aurp_open_req, buffer)
  subtree:add(aurp_open_req_version, buffer(0, 2))
  subtree:add(aurp_open_req_option_count, buffer(2, 1))
  local option_count = buffer(2, 1):uint()
  for i = 1, option_count do
    subtree:add(aurp_open_req_option, buffer(i + 2, 1))
  end
end

function parse_command_open_rsp(buffer, tree)
  local subtree = tree:add(aurp_open_rsp, buffer)
  local rate_or_error = buffer(0, 2):int()
  if rate_or_error >= 0 then
    subtree:add(aurp_open_rsp_update_rate, buffer(0, 2))
      :append_text(" (" .. (rate_or_error * 10) .. " seconds)")
  else
    subtree:add(aurp_open_rsp_error_code, buffer(0, 2))
      :append_text(" (" .. error_code(rate_or_error) .. ")")
  end

  subtree:add(aurp_open_rsp_option_count, buffer(2, 1))
  local option_count = buffer(2, 1):uint()
  for i = 1, option_count do
    subtree:add(aurp_open_rsp_option, buffer(i + 2, 1))
  end
end

function aurp_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = aurp_protocol.name

  local subtree = tree:add(aurp_protocol, buffer())

  local c = 0
  len = parse_di(buffer(c), subtree, true)
  c = c + len
  len = parse_di(buffer(c), subtree, false)
  c = c + len

  subtree:add(aurp_version, buffer(c, 2))
  c  = c + 2
  subtree:add(aurp_reserved, buffer(c, 2))
  c  = c + 2

  local atype = buffer(c, 2):uint()
  local stype
  if atype == 2 then
    stype = "AppleTalk"
  elseif atype == 3 then
    stype = "AURP"
  else
    stype = "Unknown"
  end
  subtree:add(aurp_type, buffer(c, 2)):append_text(" (" .. stype .. ")")
  c = c + 2

  if atype == 2 then
    subtree:set_len(c)
    local ddp = Dissector.get("ddp")
    ddp:call(buffer(c):tvb(), pinfo, tree)
    return
  elseif atype ~= 3 then
    subtree:set_len(c)
    subtree:add_expert_info(PI_UNDECODED, PI_NOTE, "Unknown packet type")
    return
  end

  local connection_id = buffer(c, 2):uint()
  subtree:add(aurp_connection_id, buffer(c, 2))
  c = c + 2

  local sequence_no = buffer(c, 2):uint()
  subtree:add(aurp_sequence_no, buffer(c, 2))
  c = c + 2

  local command = buffer(c, 2):uint()
  local command_tree = subtree:add(aurp_command, buffer(c, 2))
  c = c + 2

  parse_flags(buffer(c, 2), command, subtree)
  c = c + 2

  local subcommand
  -- command 1 is RI-Req (no subfields)
  if command == 2 then
    parse_command_ri_rsp(buffer(c), subtree)
  -- command 3 is RI-Ack (no subfields)
  elseif command == 4 then
    parse_command_ri_upd(buffer(c), subtree)
  elseif command == 5 then
    parse_command_router_down(buffer(c), subtree)
  elseif command == 6 then
    subcommand = buffer(c, 2):uint()
    parse_command_zone_req(buffer(c), subtree)
  elseif command == 7 then
    subcommand = buffer(c, 2):uint()
    parse_command_zone_rsp(buffer(c), subtree)
  elseif command == 8 then
    parse_command_open_req(buffer(c), subtree)
  elseif command == 9 then
    parse_command_open_rsp(buffer(c), subtree)
  -- command 14 is Tickle (no subfields)
  -- command 15 is Tickle Acknowledgement (no subfields)
  end
  local command_name = command_name(command, subcommand)
  command_tree:append_text(" (" .. command_name .. ")")
  pinfo.columns["info"] = string.format("[%04x seq %d] %s", connection_id, sequence_no, command_name)
end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(387, aurp_protocol)
