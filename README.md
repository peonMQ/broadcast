# broadcast

Library to help broadcast important information to all EQBC connected toons, or a single defined toon (driver).

Heavily inspired by Knightly's 'Write' lua script'

## Requirements

- MQ
- MQ2Lua
- Either or both of:
  - MQ2DanNet (Preferred communication method if both are loaded)
  - MQ2EQBC

## Installation
Add `broadcast.lua` and `broadcastinterface.lua` to the `lua` folder of your MQ directory.

## Usage

```lua
local broadcast = require('broadcast')

broadcast.Info("Information for all")
broadcast.Success("We succeded")
broadcast.Fail("I failed")
broadcast.Warn("Im in trouble")
broadcast.Error("Something went horribly wrong")

-- Handle string formatting too
broadcast.Success("%s successully cast %s", mq.TLO.Me.Name, 'Complete Heal')
```

Setting reciever in config will attempt to send broadcast only to this character:

```lua
local defaultConfig = {
  usecolors = true,
  usetimestamp = false,
  broadcastLevel = 'success',
  separator = '::',
  reciever = nil
}
```
