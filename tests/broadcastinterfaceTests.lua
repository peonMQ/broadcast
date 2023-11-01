--- @type Mq
local mq = require 'mq'
local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'
local bci = broadCastInterfaceFactory()

local function tests()
  print("Connected peers: "..table.concat(bci.ConnectedClients(), ","))
  bci.ExecuteCommand("/echo Hello World!", {mq.TLO.Me.Name()})
  bci.ExecuteAllCommand("/echo Hello World not me!")
  bci.ExecuteAllWithSelfCommand("/echo Hello World and me!")
  bci.ExecuteZoneCommand("/echo Hello Zone not me!")
  bci.ExecuteZoneWithSelfCommand("/echo Hello Zone and me!")
  bci.ExecuteGroupCommand("/echo Hello Group not me!")
  bci.ExecuteGroupWithSelfCommand("/echo Hello Group and me!")
end

return tests