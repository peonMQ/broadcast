--- @type Mq
local mq = require 'mq'
local interfaceTests = require 'broadcastinterfaceTests'
local broadcastTests = require 'broadcastTests'

if mq.TLO.Plugin("mq2dannet").IsLoaded() then
  print("DanNet tests")
  mq.cmd("/dgga /djoin tests")
  interfaceTests()
  mq.delay(1000)
  broadcastTests()
end

if not mq.TLO.Plugin("mq2dannet").IsLoaded() and mq.TLO.Plugin("mq2eqbc").IsLoaded() and mq.TLO.EQBC.Connected() then
  print("EQBC tests")
  -- mq.cmd("/bcga //bccmd channels tests")
  interfaceTests()
  mq.delay(1000)
  broadcastTests()
end

-- /plugin mq2dannet load
-- /plugin mq2dannet unload