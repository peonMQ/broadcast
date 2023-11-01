--- @type Mq
local mq = require 'mq'
local broadcast = require 'broadcast/broadcast'
local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'
local bci = broadCastInterfaceFactory()

local function tests()
  broadcast.broadcastlevels.custom = {
    level = 8,
    color = 'Maroon',
    abbreviation = '[CUSTOM]'
  }

  local message = "Sending %s to self and channel <test>"
  broadcast.Info({mq.TLO.Me.Name(), "tests"}, message, bci:ColorWrap( "Info", 'Blue'))
  broadcast.Warn({mq.TLO.Me.Name(), "tests"}, message, bci:ColorWrap( "Warn", 'Yellow'))
  broadcast.Success({mq.TLO.Me.Name(), "tests"}, message, bci:ColorWrap( "Success", 'Green'))
  broadcast.Error({mq.TLO.Me.Name(), "tests"}, message, bci:ColorWrap( "Error", 'Orange'))
  broadcast.Fail({mq.TLO.Me.Name(), "tests"}, message, bci:ColorWrap( "Fail", 'Red'))
  broadcast.Custom({mq.TLO.Me.Name(), "tests"}, message, bci:ColorWrap( "Custom", 'Maroon'))

  message = "Sending %s to all"
  broadcast.InfoAll(message, bci:ColorWrap( "Info", 'Blue'))
  broadcast.WarnAll(message, bci:ColorWrap( "Warn", 'Yellow'))
  broadcast.SuccessAll(message, bci:ColorWrap( "Success", 'Green'))
  broadcast.ErrorAll(message, bci:ColorWrap( "Error", 'Orange'))
  broadcast.FailAll(message, bci:ColorWrap( "Fail", 'Red'))
  broadcast.CustomAll(message, bci:ColorWrap( "Custom", 'Maroon'))
end

return tests