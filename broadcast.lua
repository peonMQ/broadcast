--- @type Mq
local mq = require('mq')

--[[
  Bright colors
  [+y+] = yellow
  [+o+] = orange
  [+g+] = green
  [+u+] = blue
  [+r+] = red
  [+t+] = teal
  [+m+] = magenta
  [+p+] = purple
  [+w+] = white
  [+x+] = reset 

  Dark colors
  Same as above but with capitol letters
]]

local broadcastLevels = {
  ['info']    = { level = 1, color = '[+u+]', abbreviation = '[INFO%s]'    },
  ['success'] = { level = 2, color = '[+g+]', abbreviation = '[SUCCESS%s]' },
  ['fail']    = { level = 3, color = '[+r+]', abbreviation = '[FAIL%s]'    },
  ['warn']    = { level = 4, color = '[+y+]', abbreviation = '[WARN%s]'    },
  ['error']   = { level = 5, color = '[+o+]', abbreviation = '[ERROR%s]'   },
}

local defaultConfig = {
  usecolors = true,
  usetimestamp = false,
  broadcastLevel = 'success',
  separator = '::',
  reciever = nil
}

local state = {
  config = defaultConfig,
}

local BroadCast = {}

local function GetColorStart(logLevel)
  if state.config.usecolors then
      return logLevel.color
  end
  return ''
end

local function GetColorEnd()
    if state.config.usecolors then
      return '[+x+]'
    end
    return ''
end

local function GetAbbreviation(logLevel)
    if state.config.usetimestamp then
      return string.format(logLevel.abbreviation, state.config.separator..os.date("%X"))
    end
    return string.format(logLevel.abbreviation, "")
end

local function recieverIsConnected(reciever)
  local clients={}
  for _, client in string.gmatch(mq.TLO.EQBC.Names(), "([^%s]+)") do
    table.insert(clients, client)
  end

  for _, client in ipairs(clients) do
   if client == reciever then
    return true
   end
  end

  return false
end

local function GetBroadcastCommand()
    if state.config.reciever and recieverIsConnected(state.config.reciever) then
      return string.format("/bct %s", state.config.reciever)
    end
    return '/bca'
end

local function Output(paramLogLevel, message, ...)
  local broadcastLevel = broadcastLevels[paramLogLevel]
  if broadcastLevels[state.config.broadcastLevel:lower()].level <= broadcastLevel.level then
    local logMessage = string.format(message, ...)
    mq.cmd(string.format('%s %s%s%s %s %s ', GetBroadcastCommand(), GetColorStart(broadcastLevel), GetAbbreviation(broadcastLevel), GetColorEnd(), state.config.separator, logMessage))
    mq.delay(50)
  end
end

function BroadCast.Info(message, ...)
  Output('info', message, ...)
end

function BroadCast.Success(message, ...)
  Output('success', message, ...)
end

function BroadCast.Fail(message, ...)
  Output('fail', message, ...)
end

function BroadCast.Warn(message, ...)
  Output('warn', message, ...)
end

function BroadCast.Error(message, ...)
  Output('error', message, ...)
end

return BroadCast
