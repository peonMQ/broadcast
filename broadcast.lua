local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'
-- This module provides a set of logging utilities with support for different log levels and colored output.
local BroadCast = { _version = '2.0', _author = 'projecteon' }

---@class BroadCastLevelDetail
---@field level integer
---@field color ColorName
---@field abbreviation string

---@type table<string, BroadCastLevelDetail>
local initial_broadcastLevels = {
  ['info']    = { level = 1, color = 'Blue',   abbreviation = '[INFO%s]'    },
  ['success'] = { level = 2, color = 'Green',  abbreviation = '[SUCCESS%s]' },
  ['fail']    = { level = 3, color = 'Red',    abbreviation = '[FAIL%s]'    },
  ['warn']    = { level = 4, color = 'Yellow', abbreviation = '[WARN%s]'    },
  ['error']   = { level = 5, color = 'Orange', abbreviation = '[ERROR%s]'   },
}

BroadCast.usetimestamp = false
-- Specifies the current log level.  Log levels lower than this will not be shown.
BroadCast.broadcastLevel = 'info'
-- Sets a prefix for log messages.  This appears at the very beginning of the line and can be a string or a function that returns a string
BroadCast.prefix = ''
-- Sets a postfix for log messages.  This appears at the end of the write string, prior to the separator
BroadCast.postfix = ''
-- Sets a separator that is placed between the write string and the log entry to be printed
BroadCast.separator = '::'

local broadCastInterface = broadCastInterfaceFactory('AUTO')


-- Handle add/remove for log levels
local loglevels_mt = {
  __newindex = function(t, key, value)
      rawset(t, key, value)
      BroadCast.GenerateShortcuts()
  end,
  __call = function(t, key)
      rawset(t, key, nil)
      BroadCast.GenerateShortcuts()
  end,
}

BroadCast.broadcastlevels = setmetatable(initial_broadcastLevels, loglevels_mt)

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

---@param broadcastLevel string
---@param recievers string|string[]
---@param message string
---@param ... string
local function Output(broadcastLevel, recievers, message, ...)
  if rawget(BroadCast.broadcastlevels, broadcastLevel) == nil then
    broadCastInterface.Broadcast(string.format('%s%s %s %s', BroadCast.prefix, "[FATAL]", BroadCast.separator, string.format("Log level '%s' does not exist.", broadcastLevel)), {})
  elseif BroadCast.broadcastlevels[BroadCast.broadcastLevel:lower()].level <= BroadCast.broadcastlevels[broadcastLevel].level then
    recievers = (type(recievers) == 'string') and {recievers} or recievers    
    local logMessage = string.format(message, ...)
    local prefix = (type(BroadCast.prefix) == 'function' and BroadCast.prefix() or BroadCast.prefix) or ''
    local postfix = (type(BroadCast.postfix) == 'function' and BroadCast.postfix() or BroadCast.postfix) or ''
    broadCastInterface.Broadcast(string.format('%s%s %s%s %s', prefix, GetAbbreviation(broadCastInterface, BroadCast.broadcastlevels[broadcastLevel]), postfix, BroadCast.separator, logMessage), recievers)
  end
end

--- Converts a string to sentence case.
--- @param str string The string to convert
--- @return string # The converted string in sentence case
local function GetSentenceCase(str)
    local firstLetter = str:sub(1, 1):upper()
    local remainingLetters = str:sub(2):lower()
    return firstLetter..remainingLetters
end

--- Generates shortcut functions for each log level defined in Write.loglevels.
--- The generated functions have the same name as the log level with the first letter capitalized.
--- For example, if there is a log level 'info', a function Write.Info() will be generated.
--- The functions output messages at their respective log levels, and a fatal log level message will terminate the program.
function BroadCast.GenerateShortcuts()
    for level, level_params in pairs(BroadCast.broadcastlevels) do
        --- @diagnostic disable-next-line
        BroadCast[GetSentenceCase(level)] = function(recievers, message, ...)
            Output(level, recievers, string.format(message, ...))
        end
        --- @diagnostic disable-next-line
        BroadCast[GetSentenceCase(level).."All"] = function(message, ...)
            Output(level, {}, string.format(message, ...))
        end
    end
end

BroadCast.GenerateShortcuts()

---@param text string
---@param color ColorName
---@return string
function BroadCast.ColorWrap(text, color)
  return broadCastInterface:ColorWrap(text, color)
end

---@param mode BroadCastMode
---@param consoleWidget ConsoleWidget|nil
function BroadCast.SetMode(mode, consoleWidget)
  broadCastInterface = broadCastInterfaceFactory(mode, consoleWidget)
end

return BroadCast
