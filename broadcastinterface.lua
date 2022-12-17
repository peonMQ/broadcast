--- @type Mq
local mq = require('mq')
local debugutil = require('utils/debug')

---@alias ColorName 'Previous'|'Black'|'Blue'|'Cyan'|'Green'|'Maroon'|'Orange'|'Red'|'White'|'Yellow'

---@class BroadCastInterface
---@field Broadcast fun(message: string, recievers?: string[])
---@field ExecuteCommand fun(executeCommand: string, recievers?: string[])
---@field ColorWrap fun(self: BroadCastInterface, text: string, color: ColorName): string
---@field ColorCodes table<ColorName, string>

---@param table table
---@param value string
---@return boolean
local function containsValue(table, value)
  for _, tableValue in pairs(table) do
    if tableValue:lower() == value:lower() then
      return true
    end
  end

  return false
end

---@type BroadCastInterface
local dannetBroadCaster = {
  ColorCodes = {
    Previous = '\ax',
    Black = '\ab',
    Blue = '\au',
    Cyan = '\at',
    Green = '\ag',
    Maroon = '\am',
    Orange = '\ao',
    Purple = '\ap',
    Red = '\ar',
    White = '\aw',
    Yellow = '\ay',
  },
  Broadcast = function(message, recievers)
    if recievers and next(recievers) then
      local clients={}
      for client in string.gmatch(mq.TLO.DanNet.Peers(), "([^|]+)") do
        table.insert(clients, client:lower())
      end

      for i, client in ipairs(clients) do
        if containsValue(recievers, client:gsub('^([a-zA-Z0-9]+_)', '')) then
          mq.cmdf("/dt %s %s", client, message)
        end
      end
    else
      mq.cmdf('/dgt all %s', message)
    end
  end,
  ExecuteCommand = function(executeCommand, recievers)
    if recievers and next(recievers) then
      local clients={}
      for client in string.gmatch(mq.TLO.DanNet.Peers(), "([^|]+)") do
        table.insert(clients, client:lower())
      end

      for i, client in ipairs(clients) do
        if containsValue(recievers, client:gsub('^([a-zA-Z0-9]+_)', '')) then
          mq.cmdf("/dex %s %s", client, executeCommand)
        end
      end
    else
      mq.cmdf('/dgae %s', executeCommand)
    end
  end,
  ColorWrap = function (self, text, color)
    return string.format('%s%s%s', self.ColorCodes[color], text, self.ColorCodes.Previous)
  end
}

---@type BroadCastInterface
local eqbcBroadCaster = {
  ColorCodes = {
    Previous = '[+x+]',
    Black = '[+b+]',
    Blue = '[+u+]',
    Cyan = '[+t+]',
    Green = '[+g+]',
    Maroon = '[+m+]',
    Orange = '[+o+]',
    Purple = '[+p+]',
    Red = '[+r+]',
    White = '[+w+]',
    Yellow = '[+y+]',
  },
  Broadcast = function(message, recievers)
    if recievers and next(recievers) then
      local clients={}
      for client in string.gmatch(mq.TLO.EQBC.Names(), "([^%s]+)") do
        table.insert(clients, client:lower())
      end

      for i, client in ipairs(clients) do
        if containsValue(recievers, client) then
          mq.cmdf("/bct %s %s", client, message)
        end
      end
    else
      mq.cmdf('/bcaa %s', message)
    end
  end,
  ExecuteCommand = function(executeCommand, recievers)
    if recievers and next(recievers) then
      local clients={}
      for client in string.gmatch(mq.TLO.EQBC.Names(), "([^%s]+)") do
        table.insert(clients, client:lower())
      end

      for i, client in ipairs(clients) do
        if containsValue(recievers, client) then
          mq.cmdf("/bct %s /%s", client, executeCommand)
        end
      end
    else
      mq.cmdf('/bcaa /%s', executeCommand)
    end
  end,
  ColorWrap = function (self, text, color)
    return string.format('%s%s%s', self.ColorCodes[color], text, self.ColorCodes.Previous)
  end
}

---@return BroadCastInterface|nil
local function factory()
  if mq.TLO.Plugin("mq2dannet").IsLoaded() then
    return dannetBroadCaster
  elseif mq.TLO.Plugin("mq2eqbc").IsLoaded() and mq.TLO.EQBC.Connected() then
    return eqbcBroadCaster
  else
    return nil
  end
end

return factory