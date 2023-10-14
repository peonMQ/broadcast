--- @type Mq
local mq = require 'mq'
local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'
local bci = broadCastInterfaceFactory()

local function tests()
  print("Connected peers: "..table.concat(bci.ConnectedClients(), ","))
  local command = string.format("/echo Hello %s!", bci:ColorWrap( "World", 'Green'))
  bci.ExecuteCommand(command, {mq.TLO.Me.Name()})
  command = string.format("/echo Hello %s not me!", bci:ColorWrap( "World", 'Green'))
  bci.ExecuteAllCommand(command)
  command = string.format("/echo Hello %s and me!", bci:ColorWrap( "World", 'Green'))
  bci.ExecuteAllWithSelfCommand(command)
  command = string.format("/echo Hello %s not me!", bci:ColorWrap( "Zone", 'Green'))
  bci.ExecuteZoneCommand(command)
  command = string.format("/echo Hello %s and me!", bci:ColorWrap( "Zone", 'Green'))
  bci.ExecuteZoneWithSelfCommand(command)
  command = string.format("/echo Hello %s not me!", bci:ColorWrap( "Group", 'Green'))
  bci.ExecuteGroupCommand(command)
  command = string.format("/echo Hello %s and me!", bci:ColorWrap( "Group", 'Green'))
  bci.ExecuteGroupWithSelfCommand(command)
end

return tests