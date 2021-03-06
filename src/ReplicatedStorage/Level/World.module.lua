--[[
  World
  =====

  A World allows you to easily move Players between the Cells in your game.

  Conceptually, a World can be thought of as the game itself, and the Cells it
  has access to are all the areas the Player can travel to.

  You should limit yourself to a single World instance, they're intended to be
  used to group all of the locations in your game, and as such there should be
  no case where you would need to work with more than one at a time.

  Constructors
  ------------

  World.new(table cells={})
    Creates a new World instance

    `cells` is a list of any Cell instances you want to immediately pass in. If
    you create all your Cells after defining the World instance, you can use
    AddCells instead.

  Methods
  -------

  Cell GetCellByName(string cellName)
    When you don't have a reference to a Cell, this method allows you to look
    one up by its Name.

  void AddCell(Cell cell)
    Adds `cell` to the list of Cells managed by this class.

  void RemoveCellByName(string cellName)
    Removes a Cell managed by this class by its name.

  Cell GetCurrentCell(Player player)
    Returns the Cell a Player is currently inside of.

    Returns nil if the Player is not in a Cell.

  void LeaveCurrentCell(Player player)
    Removes a Player from the Cell they're currently in.

    We don't have a method to explicitly leave one Cell, as each Player is only
    intended to be in one Cell at a time. This method is run automatically when
    calling EnterCell to ensure this.

    Because this method is run automatically, you typically won't need to use it
    unless you want to clear a Player out of all Cells indefinitely.

    Fires CellLeft.

  void EnterCell(string cellName, Player player)
    Add a Player to the specified Cell.

    This method also removes the player from Cell they're currently in. This
    ensures the player is only in one Cell at a time.

    Fires CellEntered.

  Events
  ------

  CellEntered (Cell, Player)
    Fired when entering a Cell.

    Returns the Cell and the Player that entered the Cell.

  CellLeft (Cell, Player)
    Fired when a Player leaves a Cell.

    Returns the Cell and the Player that left the Cell.
--]]

local replicatedStorage = game:GetService("ReplicatedStorage")

local Array = require(replicatedStorage.Helpers.Array)
local expect = require(replicatedStorage.Helpers.Expect)
local Signal = require(replicatedStorage.Events.Signal)

--------------------------------------------------------------------------------

local World = {}
World.__index = World

function World.new(cells)
  local self = {}
  setmetatable(self, World)

  self._Cells = (cells and Array.new(cells)) or Array.new()

  self.CellEntered = Signal.new()
  self.CellLeft = Signal.new()

  return self
end

function World:GetCellByName(cellName)
  return self._Cells:Find(function(cell)
    return cell.Name == cellName
  end)
end

function World:AddCell(cell)
  expect(cell, "Cell", 1, "AddCell")

  self._Cells:Add(cell)
end

function World:RemoveCellByName(cellName)
  expect(cellName, "string", 1, "RemoveCellByName")

  local cell = self:GetCellByName(cellName)

  if self._Cells:Has(cell) then
    self._Cells:Remove(cell)
  end
end

function World:GetCurrentCell(player)
  return self._Cells:Find(function(cell)
    if cell:IsInCell(player) then
      return cell
    end
  end)
end

function World:LeaveCurrentCell(player)
  local cell = self:GetCurrentCell(player)
  if cell then
    cell:Leave(player)
    self.CellLeft:fire(cell, player)
  end
end

function World:EnterCell(cellName, player)
  expect(cellName, "string", 1, "EnterCell")

  local cell = self:GetCellByName(cellName)
  self:LeaveCurrentCell(player)
  cell:Enter(player)
  self.CellEntered:fire(cell, player)
end

return World
