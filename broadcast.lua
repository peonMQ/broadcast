local mq = require('mq')
local broadCastInterfaceFactory = require('broadcast/broadcastinterface')
local configLoader = require('utils/configloader')
local luahelper = require('utils/lua-table')

---@class BroadCastLevelDetail
---@field level integer
---@field color ColorName
---@field abbreviation string

---@alias BroadCastLevels 'info'|'success'|'fail'|'warn'|'error'

---@type table<BroadCastLevels, BroadCastLevelDetail>
local broadcastLevels = {
  ['info']    = { level = 1, color = 'Blue',   abbreviation = '[INFO%s]'    },
  ['success'] = { level = 2, color = 'Green',  abbreviation = '[SUCCESS%s]' },
  ['fail']    = { level = 3, color = 'Red',    abbreviation = '[FAIL%s]'    },
  ['warn']    = { level = 4, color = 'Yellow', abbreviation = '[WARN%s]'    },
  ['error']   = { level = 5, color = 'Orange', abbreviation = '[ERROR%s]'   },
}

local defaultConfig = {
  delay = 50,
  usecolors = true,
  usetimestamp = false,
  broadcastLevel = 'info',
  separator = '::',
  reciever = ''
}

local config = configLoader("logging", defaultConfig)
local broadCastInterface = broadCastInterfaceFactory()

---@param bci BroadCastInterface
---@param level BroadCastLevelDetail
---@return string
local function GetAbbreviation(bci, level)
  local abbreviation
  if config.usetimestamp then
    abbreviation = string.format(level.abbreviation, config.separator..os.date("%X"))
  else
    abbreviation = string.format(level.abbreviation, "")
  end

  if config.usecolors then
    return bci:ColorWrap(abbreviation, level.color)
  end

  return abbreviation
end

---@param paramLogLevel BroadCastLevels
---@param message string
---@param ... string
local function Output(paramLogLevel, message, ...)
  if not broadCastInterface then
    print("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> connection.")
    mq.delay(config.delay)
    return
  end

  local broadcastLevel = broadcastLevels[paramLogLevel]
  if broadcastLevels[config.broadcastLevel:lower()].level <= broadcastLevel.level then
    local recievers = luahelper.Split(config.reciever, ",")
    local logMessage = string.format(message, ...)
    broadCastInterface.Broadcast(string.format('%s %s %s', GetAbbreviation(broadCastInterface, broadcastLevel), config.separator, logMessage), recievers)
    mq.delay(config.delay)
  end
end

local BroadCast = {}

---@param message string
---@param ... string
function BroadCast.Info(message, ...)
  Output('info', message, ...)
end

---@param message string
---@param ... string
function BroadCast.Success(message, ...)
  Output('success', message, ...)
end

---@param message string
---@param ... string
function BroadCast.Fail(message, ...)
  Output('fail', message, ...)
end

---@param message string
---@param ... string
function BroadCast.Warn(message, ...)
  Output('warn', message, ...)
end

---@param message string
---@param ... string
function BroadCast.Error(message, ...)
  Output('error', message, ...)
end

return BroadCast
