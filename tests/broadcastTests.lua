--- @type Mq
local mq = require 'mq'
local broadcast = require 'broadcast/broadcast'
local function log(_string)
  local logstring = string.format("[%s] %s", os.date('%H:%M:%S'), _string)
  print(logstring)
end

---@param mode BroadCastMode
local function tests(mode)
  log("Mode set too: "..mode)
  broadcast.SetMode(mode)
  broadcast.broadcastlevels.custom = {
    level = 8,
    color = 'Maroon',
    abbreviation = '[CUSTOM]'
  }

  local message = "Sending %s to self and channel <test> from " .. mq.TLO.Me().." with mode "..mode
  broadcast.Info({mq.TLO.Me.Name(), "tests"}, message, broadcast.ColorWrap( "Info", 'Blue'))
  broadcast.Warn({mq.TLO.Me.Name(), "tests"}, message, broadcast.ColorWrap( "Warn", 'Yellow'))
  broadcast.Success({mq.TLO.Me.Name(), "tests"}, message, broadcast.ColorWrap( "Success", 'Green'))
  broadcast.Error({mq.TLO.Me.Name(), "tests"}, message, broadcast.ColorWrap( "Error", 'Orange'))
  broadcast.Fail({mq.TLO.Me.Name(), "tests"}, message, broadcast.ColorWrap( "Fail", 'Red'))
  broadcast.Custom({mq.TLO.Me.Name(), "tests"}, message, broadcast.ColorWrap( "Custom", 'Maroon'))

  message = "Sending %s to all from " .. mq.TLO.Me().." with mode "..mode
  broadcast.InfoAll(message, broadcast.ColorWrap( "Info", 'Blue'))
  broadcast.WarnAll(message, broadcast.ColorWrap( "Warn", 'Yellow'))
  broadcast.SuccessAll(message, broadcast.ColorWrap( "Success", 'Green'))
  broadcast.ErrorAll(message, broadcast.ColorWrap( "Error", 'Orange'))
  broadcast.FailAll(message, broadcast.ColorWrap( "Fail", 'Red'))
  broadcast.CustomAll(message, broadcast.ColorWrap( "Custom", 'Maroon'))
end

return tests