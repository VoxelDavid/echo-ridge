--[[
  Warp
  ====

  Used for teleporting a player to a new location.

  Typically this is used client-side, as moving the player via the server can
  take a little bit if the client has high latency.

  Handling this via the client makes everything feel very snappy and instant,
  but this can always be used from the server if it's ever needed.

  Constructors
  ------------

  Warp.new(Part pad)
    `pad` is where the player being teleported will end up on top of, facing the
    Front direction of the pad.

  Properties
  ----------

  Pad
    A reference to `pad`.

  Methods
  -------

  TeleporttoPad(Model model)
    Moves `model` on top of `pad`. This is usually the client's Character.

  Events
  ------

  Model Warped
    Fired when teleportation has successfully completed.

    Returns the Model that was warped.
--]]
local replicatedStorage = game:GetService("ReplicatedStorage")

local expect = require(replicatedStorage.Helpers.Expect)
local Signal = require(replicatedStorage.Events.Signal)

--[[
  Moves `model` on top of `locationPart`.

  `model's` rotation is changed to `locationPart's`, so if you're moving a
  Character, make sure locationPart's Front face goes in the desired direction.
--]]
local function teleportOnTop(model, locationPart)
  assert(model.PrimaryPart, string.format("PrimaryPart must be set for %s",
    model:GetFullName()))

  local boundingBox = model:GetExtentsSize()
  local offset = CFrame.new(0, boundingBox.y, 0)

  model:SetPrimaryPartCFrame(locationPart.CFrame * offset)
end

--------------------------------------------------------------------------------

local Warp = {}
Warp.__index = Warp

function Warp.new(pad)
  local self = {}
  setmetatable(self, Warp)

  assert(expect(pad, "BasePart", 1, "new"))

  self.Pad = pad
  self.Warped = Signal.new()

  return self
end

function Warp:TeleportToPad(model)
  assert(expect(model, "Model", 1, "TeleportToPad"))

  teleportOnTop(model, self.Pad)
  self.Warped:fire(model)
end

return Warp
