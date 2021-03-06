local lighting = game:GetService("Lighting")
local players = game:GetService("Players")
local replicatedStorage = game:GetService("ReplicatedStorage")

local components = require(replicatedStorage.Services.ComponentService)
local transmit = require(replicatedStorage.Events.Transmit)
local Cell = require(replicatedStorage.Level.Cell)
local World = require(replicatedStorage.Level.World)

local client = players.LocalPlayer

local function getNewCell(cellModel)
  local cell = Cell.new(cellModel.Name)

  -- HACK This isn't a very clean way of setting the TimeOfDay of the Cell. For
  -- right now we really just need a TimeOfDay changing implementation, but this
  -- should be cleaned up as soon as possible.
  --
  -- See CellEntered connection in setupWorld() for related code.
  local timeOfDay = cellModel:FindFirstChild("TimeOfDay")
  if timeOfDay then
    cell.TimeOfDay = timeOfDay.Value
  end

  return cell
end

local function getCellsFromModels(cellModels)
  local cells = {}
  for _, cellModel in ipairs(cellModels) do
    table.insert(cells, getNewCell(cellModel))
  end
  return cells
end

local function setupWorld()
  local cellModels = components:GetByType("Cell")
  local cells = getCellsFromModels(cellModels)
  local world = World.new(cells)

  -- Fired by StarterCharacterScripts.WarpListening. This lets us know when the
  -- client has been Warped to one of the Cell Models. From here we can perform
  -- the action to actually move them into the Cell.
  local warpedToCell = transmit.getLocalEvent("WarpedToCell")

  world.CellEntered:connect(function(player, cell)
    if client == player and cell.TimeOfDay then
      lighting.TimeOfDay = cell.TimeOfDay
    end
  end)

  -- Start off in Geo's Room.
  world:EnterCell("GeosRoom", client)

  warpedToCell.Event:connect(function(cellModel)
    world:EnterCell(cellModel.Name, client)
  end)
end

setupWorld()
