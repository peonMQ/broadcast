local mq = require 'mq'
local interfaceTests = require 'broadcastinterfaceTests'
local broadcastTests = require 'broadcastTests'
local broadCastInterfaceFactory = require 'broadcast/broadcastinterface'

local receiver = ...

local function log(_string)
  local logstring = string.format("[%s] %s", os.date('%H:%M:%S'), _string)
  print(logstring)
end

if not mq.TLO.Plugin("mq2eqbc").IsLoaded() or not mq.TLO.EQBC.Connected() then
  log("EQBC required to run tests")
  mq.exit()
end

if not mq.TLO.Plugin("mq2dannet").IsLoaded() then
  mq.cmd("/bcga //plugin mq2dannet load")
  mq.delay(5000)
end

local function runEQBCTests()
  if mq.TLO.Plugin("mq2eqbc").IsLoaded() and mq.TLO.EQBC.Connected() then
    log("EQBC tests")
    mq.cmd("/bcga //bccmd channels tests")
    mq.delay(2000)
    interfaceTests('EQBC')
    mq.delay(2000)
    broadcastTests('EQBC')
    mq.delay(2000)
    log("EQBC tests complete")
  end
end

local function runDannetTests()
  if mq.TLO.Plugin("mq2dannet").IsLoaded() then
    log("DanNet tests")
    mq.cmd("/dgga /djoin tests")
    mq.delay(2000)
    interfaceTests('DANNET')
    mq.delay(2000)
    broadcastTests('DANNET')
    mq.delay(2000)
    log("DanNet tests complete")
  end
end

local function runActorTests()
  log("Actor tests")
  mq.cmd('/bca //lua run broadcast/tests receiver')
  mq.delay(500)

  for i = 1, 500, 1 do
    mq.delay(10)
  end
  interfaceTests('ACTOR')
  for i = 1, 10, 1 do
    mq.delay(500)
  end

  broadcastTests('ACTOR')
  for i = 1, 10, 1 do
    mq.delay(500)
  end
  log("Actor tests completed")
end

if not receiver then
  runDannetTests()
  runEQBCTests()
  runActorTests()
else
  local bci = broadCastInterfaceFactory('ACTOR')
  for i = 1, 30, 1 do
    mq.delay(500)
  end
end


log("Cleanup")
if mq.TLO.Plugin("mq2dannet").IsLoaded() then
  mq.cmd("/bcga //plugin mq2dannet unload")
end