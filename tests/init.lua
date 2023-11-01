--- @type Mq
local mq = require 'mq'
local interfaceTests = require 'broadcastinterfaceTests'
local broadcastTests = require 'broadcastTests'

if not mq.TLO.Plugin("mq2eqbc").IsLoaded() or not mq.TLO.EQBC.Connected() then
  print("EQBC required to run tests")
  mq.exit()
end

if not mq.TLO.Plugin("mq2dannet").IsLoaded() then
  mq.cmd("/bcga //plugin mq2dannet load")
end

if mq.TLO.Plugin("mq2dannet").IsLoaded() then
  print("DanNet tests")
  mq.cmd("/dgga /djoin tests")
  mq.delay(1000)
  interfaceTests()
  mq.delay(1000)
  broadcastTests()
  mq.delay(1000)
  mq.cmd("/bcga //plugin mq2dannet unload")
  mq.delay(1000)
end

if mq.TLO.Plugin("mq2eqbc").IsLoaded() and mq.TLO.EQBC.Connected() then
  print("EQBC tests")
  mq.cmd("/bcga //bccmd channels tests")
  mq.delay(1000)
  interfaceTests()
  mq.delay(1000)
  broadcastTests()
end

-- /plugin mq2dannet load
-- /plugin mq2dannet unload