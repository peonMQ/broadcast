local mq = require 'mq'
local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'
-- This module provides a set of logging utilities with support for different log levels and colored output.
local BroadCast = { _version = '2.0', _author = 'projecteon' }

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

BroadCast.usetimestamp = false
BroadCast.broadcastLevel = 'info'
BroadCast.prefix = ''
BroadCast.separator = '::'

local broadCastInterface = broadCastInterfaceFactory()

---@param bci BroadCastInterface
---@param level BroadCastLevelDetail
---@return string
local function GetAbbreviation(bci, level)
  local abbreviation
  if BroadCast.usetimestamp then
    abbreviation = string.format(level.abbreviation, BroadCast.separator..os.date("%X"))
  else
    abbreviation = string.format(level.abbreviation, "")
  end

  return bci:ColorWrap(abbreviation, level.color)
end

---@param paramLogLevel BroadCastLevels
---@param recievers string|string[]
---@param message string
---@param ... string
local function Output(paramLogLevel, recievers, message, ...)
  local broadcastLevel = broadcastLevels[paramLogLevel]
  if broadcastLevels[BroadCast.broadcastLevel:lower()].level <= broadcastLevel.level then
    recievers = (type(recievers) == 'string') and {recievers} or recievers    
    local logMessage = string.format(message, ...)
    broadCastInterface.Broadcast(string.format('%s%s %s %s', BroadCast.prefix, GetAbbreviation(broadCastInterface, broadcastLevel), BroadCast.separator, logMessage), recievers)
    mq.delay(BroadCast.delay)
  end
end

---@param text string
---@param color ColorName
---@return string
function BroadCast.ColorWrap(text, color)
  return broadCastInterface:ColorWrap(text, color)
end

---@param recievers string|string[]
---@param message string
---@param ... string
function BroadCast.Info(recievers, message, ...)
  Output('info', recievers, message, ...)
end

---@param recievers string|string[]
---@param message string
---@param ... string
function BroadCast.Success(recievers, message, ...)
  Output('success', recievers, message, ...)
end

---@param recievers string|string[]
---@param message string
---@param ... string
function BroadCast.Fail(recievers, message, ...)
  Output('fail', recievers, message, ...)
end

---@param recievers string|string[]
---@param message string
---@param ... string
function BroadCast.Warn(recievers, message, ...)
  Output('warn', recievers, message, ...)
end

---@param recievers string|string[]
---@param message string
---@param ... string
function BroadCast.Error(recievers, message, ...)
  Output('error', recievers, message, ...)
end

return BroadCast
