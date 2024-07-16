--- @type Mq
local mq = require 'mq'
local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'

local function log(_string)
  local logstring = string.format("[%s] %s", os.date('%H:%M:%S'), _string)
  print(logstring)
end

---@param mode BroadCastMode
local function tests(mode)
  local bci = broadCastInterfaceFactory(mode)
  log("Connected peers: "..table.concat(bci.ConnectedClients(), ","))
  bci.ExecuteCommand("/echo Hello World! "..mode, {mq.TLO.Me.Name()})
  bci.ExecuteAllCommand("/echo Hello World not me! "..mode)
  bci.ExecuteAllWithSelfCommand("/echo Hello World and me! "..mode)
  bci.ExecuteZoneCommand("/echo Hello Zone not me! "..mode)
  bci.ExecuteZoneWithSelfCommand("/echo Hello Zone and me! "..mode)
  bci.ExecuteGroupCommand("/echo Hello Group not me! "..mode)
  bci.ExecuteGroupWithSelfCommand("/echo Hello Group and me! "..mode)
end

return tests