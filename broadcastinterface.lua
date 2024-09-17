local mq = require 'mq'
local actors = require('actors')

---@alias BroadCastMode 'EQBC'|'DANNET'|'ACTOR'|'AUTO'
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

---@type ConsoleWidget|nil
local console = nil

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

local function printText(text)
  if console then
    console:AppendText(text)
  else
    print(text)
  end
end

local function log(text)
  local logtext = string.format("[%s] %s", os.date('%H:%M:%S'), text)
  printText(log)
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
      mq.cmdf('/bc %s', message)
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
      printText("\ao[ERROR]\ax ExecuteZoneCommand for EQBC requires netbots to be loaded.")
    end
  end,
  ExecuteZoneWithSelfCommand = function(executeCommand)
    if netbotsLoaded then
      mq.cmdf('/noparse /bcza /%s', executeCommand)
    else
      printText("\ao[ERROR]\ax ExecuteZoneCommand for EQBC requires netbots to be loaded.")
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

---@alias MessageType 'ExecuteCommand'|'Echo'|'Registrer'|'Announce'
local connectedClients = {}
---@param message Message
local function handler(message)
  if message.content.type == 'Announce' then
    -- log("Announce "..message.sender.character)
    connectedClients[message.sender.character] = mq.gettime()
    message:send({ type= 'Registrer', from=mq.TLO.Me.Name() })
  elseif message.content.type == 'Registrer' then
    -- log("Registrer "..message.content.from)
    connectedClients[message.content.from] = mq.gettime()
  elseif message.content.type == 'Echo' then
    if not message.content.zoneId or message.content.zoneId == mq.TLO.Zone.ID() then
      printText(message.content.content)
    end
  elseif message.content.type == 'ExecuteCommand' then
      if not message.content.zoneId or message.content.zoneId == mq.TLO.Zone.ID() then
        mq.cmd(message.content.command)
      end
  end
end

local function checkRemovePeer(peer)
  return function(status, content) if status < 0 then connectedClients[peer] = nil end end
end

-- create an actor with a mailbox name -- the actor is addressed using script and mailbox
local actor = actors.register('rpcbroadcast', handler)

---@type BroadCastInterface
local actorBroadcaster = {
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
  Broadcast= function(message, recievers)
    if recievers and next(recievers) then
      for _, client in ipairs(recievers) do
        if connectedClients[client] then
          actor:send({ character=client }, { type= 'Echo', content = message }, checkRemovePeer(client))
        end
      end
    else
      for client, _ in pairs(connectedClients) do
        actor:send({ character=client }, { type= 'Echo', content = message }, checkRemovePeer(client))
      end
    end
  end,
  ExecuteCommand= function(executeCommand, recievers)
    if recievers and next(recievers) then
      for _, client in ipairs(recievers) do
        actor:send({ character=client }, { type= 'ExecuteCommand', command = executeCommand }, checkRemovePeer(client))
      end
    end
  end,
  ExecuteAllCommand= function(executeCommand)
    for client, _ in pairs(connectedClients) do
      if client ~= mq.TLO.Me.Name() then
        actor:send({ character=client }, { type= 'ExecuteCommand', command = executeCommand }, checkRemovePeer(client))
      end
    end
  end,
  ExecuteAllWithSelfCommand= function(executeCommand)
    -- mq.cmd(executeCommand)
    actor:send({ type= 'ExecuteCommand', command = executeCommand })
  end,
  ExecuteZoneCommand= function(executeCommand)
    for client, _ in pairs(connectedClients) do
      if client ~= mq.TLO.Me.Name() then
        actor:send({ character=client }, { type= 'ExecuteCommand', command = executeCommand, zoneId = mq.TLO.Zone.ID() }, checkRemovePeer(client))
      end
    end
  end,
  ExecuteZoneWithSelfCommand= function(executeCommand)
    -- mq.cmd(executeCommand)
    actor:send({ type= 'ExecuteCommand', command = executeCommand, zoneId = mq.TLO.Zone.ID() })
  end,
  ExecuteGroupCommand= function(executeCommand)
    local group = mq.TLO.Group
    for i=1,group.Members() do
      if group.Member(i).ID() ~= mq.TLO.Me.ID() then
        actor:send({ character=group.Member(i).Name() }, { type= 'ExecuteCommand', command = executeCommand })
      end
    end
  end,
  ExecuteGroupWithSelfCommand= function(executeCommand)
    -- mq.cmd(executeCommand)
      actor:send({ character=mq.TLO.Me.Name() }, { type= 'ExecuteCommand', command = executeCommand })
    local group = mq.TLO.Group
    for i=1,group.Members() do
      actor:send({ character=group.Member(i).Name() }, { type= 'ExecuteCommand', command = executeCommand })
    end
  end,
  ConnectedClients= function()
    local clients={}
    for client, _ in pairs(connectedClients) do
      table.insert(clients, client:lower())
    end

    return clients
  end,
  ColorWrap = function (self, text, color)
    return string.format('%s%s%s', self.ColorCodes[color], text, self.ColorCodes.Previous)
  end
}


actor:send({ type= 'Announce' })

---@type BroadCastInterface
local noBroadcaster = {
  ColorCodes= {},
  Broadcast= function(message, recievers)
    printText("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> or <ACTOR> connection.")
  end,
  ExecuteCommand= function(executeCommand, recievers)
    printText("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> or <ACTOR> connection.")
  end,
  ExecuteAllCommand= function(executeCommand) 
    printText("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> or <ACTOR> connection.")
  end,
  ExecuteAllWithSelfCommand= function(executeCommand) 
    printText("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> or <ACTOR> connection.")
  end,
  ExecuteZoneCommand= function(executeCommand)
    printText("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> or <ACTOR> connection.")
  end,
  ExecuteZoneWithSelfCommand= function(executeCommand)
    printText("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> or <ACTOR> connection.")
  end,
  ExecuteGroupCommand= function(executeCommand)
    printText("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> or <ACTOR> connection.")
  end,
  ExecuteGroupWithSelfCommand= function(executeCommand)
    printText("Not been able to load <BroadCastInterface>. Requires <DanNet> or <EQBC> or <ACTOR> connection.")
  end,
  ConnectedClients= function()
    return {}
  end,
  ColorWrap = function(self, text, color)
    return text
  end,
}

---@param mode BroadCastMode
---@param consoleWidget ConsoleWidget|nil
---@return BroadCastInterface
local function factory(mode, consoleWidget)
  if consoleWidget then
    console = consoleWidget
  end

  if (mode == 'DANNET' or mode == 'AUTO') and mq.TLO.Plugin("mq2dannet").IsLoaded() then
    return dannetBroadCaster
  elseif (mode == 'EQBC' or mode == 'AUTO') and mq.TLO.Plugin("mq2eqbc").IsLoaded() then
    return eqbcBroadCaster
  elseif (mode == 'ACTOR' or mode == 'AUTO') then
    return actorBroadcaster
  end

  return noBroadcaster
end

return factory
