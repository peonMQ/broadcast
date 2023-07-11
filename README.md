# broadcast

Library to help broadcast important information to all EQBC connected toons, or a single defined toon (driver).

Using the base interface it can also be used to trigger remote commands on remote characaters. See instructions on how to do this [here](#broadcastInterface-usage)

Heavily inspired by [Knightly's 'Write' lua script](https://www.redguides.com/community/resources/knightlinc-write-lua-and-other-utilities.2193/)

## Requirements

- MQ
- MQ2Lua
- Either or both of:
  - MQ2DanNet (Preferred communication method if both are loaded)
  - MQ2EQBC

## Installation
Add `broadcast.lua` and `broadcastinterface.lua` to the `lua` folder of your MQ directory.

## Broadcast Usage

```lua
local broadcast = require 'broadcast'

broadcast.Info("Information for all")
broadcast.Success("We succeded")
broadcast.Fail("I failed")
broadcast.Warn("Im in trouble")
broadcast.Error("Something went horribly wrong")

-- Handles string formatting too
broadcast.Success("%s successully cast %s", mq.TLO.Me.Name, 'Complete Heal')
```

Setting reciever in config will attempt to send broadcast only to this character:

```lua
local defaultConfig = {
  usecolors = true,
  usetimestamp = false,
  broadcastLevel = 'success',
  separator = '::',
  reciever = nil -- Used to specify a list of recievers (not broadcast to all), comma separated
}
```

## BroadcastInterface Usage
```lua
local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'

---@alias ColorName 'Previous'|'Black'|'Blue'|'Cyan'|'Green'|'Maroon'|'Orange'|'Red'|'White'|'Yellow'

---@class BroadCastInterface
---@field Broadcast fun(message: string, recievers?: string[])
---@field ExecuteCommand fun(executeCommand: string, recievers: string[])
---@field ExecuteAllCommand fun(executeCommand: string, includeSelf?: boolean)
---@field ConnecteClients fun(): string[]
---@field ColorWrap fun(self: BroadCastInterface, text: string, color: ColorName): string
---@field ColorCodes table<ColorName, string>
local bci = broadCastInterfaceFactory()


local command = string.format('/say %s', "This is triggered remotly")
bci.ExecuteAllCommand(command, true) -- 2nd parameter is to include self and is optional (default false)
bci.ExecuteCommand(command, {"Toon1", "Toon2"}) -- 2nd parameter is a list of toons that should execute the command
```