--- @type Mq
local mq = require 'mq'
local broadcast = require 'broadcast/broadcast'
local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'
local bci = broadCastInterfaceFactory()

local function tests()
  local message = string.format("Sending %s to self", bci:ColorWrap( "Info", 'Blue'))
  broadcast.Info({mq.TLO.Me.Name(), "tests"}, message)
  message = string.format("Sending %s to self", bci:ColorWrap( "Warn", 'Yellow'))
  broadcast.Warn({mq.TLO.Me.Name(), "tests"}, message)
  message = string.format("Sending %s to self", bci:ColorWrap( "Success", 'Green'))
  broadcast.Success({mq.TLO.Me.Name(), "tests"}, message)
  message = string.format("Sending %s to self", bci:ColorWrap( "Error", 'Orange'))
  broadcast.Error({mq.TLO.Me.Name(), "tests"}, message)
  message = string.format("Sending %s to self", bci:ColorWrap( "Fail", 'Red'))
  broadcast.Fail({mq.TLO.Me.Name(), "tests"}, message)
end

return tests