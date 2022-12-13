--- @type Mq
local mq = require('mq')
local luahelper = require('utils/lua-table')

---@alias ColorName 'Previous'|'Black'|'Blue'|'Cyan'|'Green'|'Maroon'|'Orange'|'Red'|'White'|'Yellow'

---@class BroadCastInterface
---@field GetBroadcastCommand fun(reciever?: string): string
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
  GetBroadcastCommand = function(reciever)
    local recieverTable = luahelper.Split(reciever, ",")
    if next(recieverTable) then
      local clients={}
      for client in string.gmatch(mq.TLO.DanNet.Peers(), "([^|]+)") do
        table.insert(clients, client:lower())
      end

      for i, client in ipairs(clients) do
        if containsValue(recieverTable, client:gsub('^([a-zA-Z0-9]+_)', '')) then
          return string.format("/dt %s", client)
        end
      end
    end

    return '/dgt all'
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
  GetBroadcastCommand = function(reciever)
    local recieverTable = luahelper.Split(reciever, ",")
    if next(recieverTable) then
      local clients={}
      for client in string.gmatch(mq.TLO.EQBC.Names(), "([^%s]+)") do
        table.insert(clients, client:lower())
      end

      for i, client in ipairs(clients) do
        if containsValue(recieverTable, client) then
          return string.format("/bct %s", client)
        end
      end
    end

    return '/bca'
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