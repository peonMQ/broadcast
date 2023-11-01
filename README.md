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

-- receviers is either a single string reciever or a table of recievers/channels ie {"Toon1", "Toon2", "Wizards"}
broadcast.Info(receviers, "Information for all")
broadcast.Success(receviers, "We succeded")
broadcast.Fail(receviers, "I failed")
broadcast.Warn(receviers, "Im in trouble")
broadcast.Error(receviers, "Something went horribly wrong")

-- or send to all connected peers
broadcast.InfoAll("Information for all")
broadcast.SuccessAll("We succeded")
broadcast.FailAll("I failed")
broadcast.WarnAll("Im in trouble")
broadcast.ErrorAll("Something went horribly wrong")

```

Broadcast also handles string formatting for you, so you can use it just like you would string.format:
```lua
local broadcast = require 'broadcast'
-- Handles string formatting too
broadcast.Success(receviers, "%s successully cast %s", mq.TLO.Me.Name, 'Complete Heal')
broadcast.SuccessAll("%s successully cast %s", mq.TLO.Me.Name, 'Complete Heal')
```

### Default broadcast levels

`broadcast.Info` - Standard level of messages.  Normal output.

`broadcast.Success` - Success messages. All went well.

`broadcast.Fail` - Fail messages.  Something didnt complete correctly.

`broadcast.Warn` - Warn messages. Exectuion completed but something is not right.

`broadcast.Error` - Error messages.  Something went wrong.

### Broadcast Configuration Options

`broadcast.usetimestamp` - `boolean` - Add timestamp to the output.  Default is false.

`broadcast.broadcastLevel` - `string` - The broadcast level at or above which messages start being printed to the console.  Default is 'info'.

`broadcast.prefix` - `string` or `function` that returns `string` - This will appear at the very beginning of the line.  The function portion is useful for inserting something like a timestamp.  However, the script's name as a string will also suffice and is how it is most often used.  Default is empty.

`broadcast.separator` - `string` - This is the notation that appears in between the write string and the log entry to be printed.  Default is `' :: '`

#### Broadcast level Configuration Options

Broadcastlevels themselves can be configured as well.  The properties for these are `broadcast.broadcastlevels['broadcastlevel'].<property>`  For example, to set the MQ color of trace, you can do: `broadcast.broadcastlevels['error'].color = 'Marroon'`

Properties are:

`level` - `number` - Used for ordering which broadcast levels are "above" or "below" others.

`color` - `table` - The color, valid values are `'Black'|'Blue'|'Cyan'|'Green'|'Maroon'|'Orange'|'Red'|'White'|'Yellow'`

`abbreviation` - `string` - How a particular broadcast level will be abbreviated



#### Adding or removing broadcast levels

An example of adding and removing a custom broadcast level is below.  Note that the broadcastlevels only support lower case and handle changing to sentence case for calls on their own.

Example:

```lua
    -- Add the log level (note custom vs Custom)
    broadcast.broadcastlevels.custom = {
        level = 6,
        color = 'Maroon',
        abbreviation = '[CUSTOM]'
    }

    -- Broadcasts at the broadcast level (note Custom vs custom)
    broadcast.CustomAll('Test')
    -- Remove the broadcast level
    logger.broadcastlevels.custom = nil
    -- This should show an error message
    broadcast.CustomAll('Test2')
```

Setting one of the default broadcast levels to nil will also remove it.

## BroadcastInterface Usage
```lua
local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'

---@alias ColorName 'Previous'|'Black'|'Blue'|'Cyan'|'Green'|'Maroon'|'Orange'|'Red'|'White'|'Yellow'

---@class BroadCastInterface
---@field Broadcast fun(message: string, recievers?: string[])
---@field ExecuteCommand fun(executeCommand: string, recievers: string[])
---@field ExecuteAllCommand fun(executeCommand: string, includeSelf?: boolean)
---@field ConnectedClients fun(): string[]
---@field ColorWrap fun(self: BroadCastInterface, text: string, color: ColorName): string
---@field ColorCodes table<ColorName, string>
local bci = broadCastInterfaceFactory()


local command = string.format('/say %s', "This is triggered remotly")
bci.ExecuteAllCommand(command, true) -- 2nd parameter is to include self and is optional (default false)
bci.ExecuteCommand(command, {"Toon1", "Toon2"}) -- 2nd parameter is a list of toons that should execute the command
```