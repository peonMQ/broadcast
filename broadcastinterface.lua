local mq = require 'mq'

---@alias ColorName 'Previous'|'Black'|'Blue'|'Cyan'|'Green'|'Maroon'|'Orange'|'Red'|'White'|'Yellow'

---@class BroadCastInterface
---@field Broadcast fun(message: string, recievers?: string[])
---@field ExecuteCommand fun(executeCommand: string, recievers: string[])
---@field ExecuteAllCommand fun(executeCommand: string)
---@field ExecuteAllWithSelfCommand fun(executeCommand: string)
---@field ExecuteGroupCommand fun(executeCommand: string)
---@field ExecuteGroupWithSelfCommand fun(executeCommand: string)
---@field ExecuteZoneCommand fun(executeCommand: string)
---@field ExecuteZoneWithSelfCommand fun(executeCommand: string)
---@field ConnectedClients fun(): string[]
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
        local name, _ = client:lower():gsub('^([a-zA-Z0-9]+_)', '')
        table.insert(clients, name)
      end

      for _, reciever in ipairs(recievers) do
        if containsValue(clients, reciever) then
          mq.cmdf("/dt %s %s", reciever, message)
        else
          mq.cmdf("/dgt %s %s", reciever, message)
        end
      end
    else
      mq.cmdf('/dgt %s', message)
    end
  end,
  ExecuteCommand = function(executeCommand, recievers)
    if next(recievers) then
      local clients={}
      for client in string.gmatch(mq.TLO.DanNet.Peers(), "([^|]+)") do
        table.insert(clients, client:lower())
      end

      for i, client in ipairs(clients) do
        if containsValue(recievers, client:gsub('^([a-zA-Z0-9]+_)', '')) then
          mq.cmdf("/noparse /dex %s %s", client, executeCommand)
        end
      end
    end
  end,
  ExecuteAllCommand = function(executeCommand)
    mq.cmdf('/noparse /dge %s', executeCommand)
  end,
  ExecuteAllWithSelfCommand = function(executeCommand)
    mq.cmdf('/noparse /dgae %s', executeCommand)
  end,
  ExecuteZoneCommand = function(executeCommand)
    mq.cmdf('/noparse /dgze %s', executeCommand)
  end,
  ExecuteGroupWithSelfCommand = function(executeCommand)
    mq.cmdf('/noparse /dgzae %s', executeCommand)
  end,
  ExecuteGroupCommand= function(executeCommand)
    mq.cmdf('/noparse /dgga %s', executeCommand)
  end,
  ExecuteZoneWithSelfCommand= function(executeCommand)
    mq.cmdf('/noparse /dgge %s', executeCommand)
  end,
  ConnectedClients = function ()
    local clients={}
    for client in string.gmatch(mq.TLO.DanNet.Peers(), "([^|]+)") do
      table.insert(clients, client:lower())
    end

    return clients
  end,
  ColorWrap = function (self, text, color)
    return string.format('%s%s%s', self.ColorCodes[color], text, self.ColorCodes.Previous)
  end
}

local netbotsLoaded = mq.TLO.Plugin("mq2netbots").IsLoaded()

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
      for _, client in ipairs(recievers) do
        mq.cmdf("/bct %s %s", client, message)
      end
    else
      mq.cmdf('/bca %s', message)
    end
  end,
  ExecuteCommand = function(executeCommand, recievers)
    if next(recievers) then
      local clients={}
      for client in string.gmatch(mq.TLO.EQBC.Names(), "([^%s]+)") do
        table.insert(clients, client:lower())
      end

      for i, client in ipairs(clients) do
        if containsValue(recievers, client) then
          mq.cmdf("/noparse /bct %s /%s", client, executeCommand)
        end
      end
    end
  end,
  ExecuteAllCommand = function(executeCommand)
    mq.cmdf('/noparse /bca /%s', executeCommand)
  end,
  ExecuteAllWithSelfCommand = function(executeCommand)
    mq.cmdf('/noparse /bcaa /%s', executeCommand)
  end,
  ExecuteZoneCommand = function(executeCommand)
    if netbotsLoaded then
      mq.cmdf('/noparse /bcz /%s', executeCommand)
    else
      print("\ao[ERROR]\ax ExecuteZoneCommand for EQBC requires netbots to be loaded.")
    end
  end,
  ExecuteZoneWithSelfCommand = function(executeCommand)
    if netbotsLoaded then
      mq.cmdf('/noparse /bcza /%s', executeCommand)
    else
      print("\ao[ERROR]\ax ExecuteZoneCommand for EQBC requires netbots to be loaded.")
    end
  end,
  ExecuteGroupCommand= function(executeCommand)
    mq.cmdf('/noparse /bcg /%s', executeCommand)
  end,
  ExecuteGroupWithSelfCommand= function(executeCommand)
    mq.cmdf('/noparse /bcga /%s', executeCommand)
  end,
  ConnectedClients = function ()
    local clients={}
    for client in string.gmatch(mq.TLO.EQBC.Names(), "([^%s]+)") do
      table.insert(clients, client:lower())
    end

    return clients
  end,
  ColorWrap = function (self, text, color)
    return string.format('%s%s%s', self.ColorCodes[color], text, self.ColorCodes.Previous)
  end
}

---@type BroadCastInterface
local noBroadcaster = {
  ColorCodes= {},
  Broadcast= function(message, recievers)
    print("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> connection.")
  end,
  ExecuteCommand= function(executeCommand, recievers)
    print("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> connection.")
  end,
  ExecuteAllCommand= function(executeCommand) 
    print("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> connection.")
  end,
  ExecuteAllWithSelfCommand= function(executeCommand) 
    print("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> connection.")
  end,
  ExecuteZoneCommand= function(executeCommand)
    print("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> connection.")
  end,
  ExecuteZoneWithSelfCommand= function(executeCommand)
    print("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> connection.")
  end,
  ExecuteGroupCommand= function(executeCommand)
    print("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> connection.")
  end,
  ExecuteGroupWithSelfCommand= function(executeCommand)
    print("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> connection.")
  end,
  ConnectedClients= function() 
    return {}
  end,
  ColorWrap = function(self, text, color)
    return text
  end,
}

---@return BroadCastInterface
local function factory()
  if mq.TLO.Plugin("mq2dannet").IsLoaded() then
    return dannetBroadCaster
  elseif mq.TLO.Plugin("mq2eqbc").IsLoaded() then
    return eqbcBroadCaster
  else
    return noBroadcaster
  end
end

return factory
