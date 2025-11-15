
local InventoryServer = require(script.InventoryServer)
local BackpackDropSystem = require(script.Parent.BackpackDropSystem)
local BoatStorageServer = require(script.Parent.BoatStorageServer)
local BoatSpawnServer = require(script.Parent.BoatSpawnServer)

InventoryServer.Start()
BackpackDropSystem.Start()
-- BoatStorageServer and BoatSpawnServer are event-driven and initialize on require
