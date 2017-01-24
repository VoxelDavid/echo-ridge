-- ClassName: ModuleScript

--[[
  ComponentService
  ==================

  Handles everything to do with Components.

  A Component is what we call an Instance (or group of Instances) in the game
  that are used in conjunction with other classes.

  Components are currently only used client-side, but in the future this will be
  changed to allow the server more control. (See "For the Future" below)

  Defining a Component
  --------------------

  A Component is any Instance that has a StringValue named "ComponentType". The
  Value determines the name of the Component.

  Components with the same ComponentType will be grouped together for easy
  accessibility.

  Usage
  -----

  Say you're building an apartment and you want to light switches to turn the
  lights on and off.

  Instead of putting Scripts in each light switch to control them, you can add a
  ComponentType to each one. The Value could be "LightSwitch".

  From there you use the GetComponents RemoteFunction to collect the Components:

    local replicatedStorage = game:GetService("ReplicatedStorage")
    local components = require(replicatedStorage.Services.Shared.ComponentSevices)

    local lightSwitches = components:GetByType("LightSwitches")

    for _, lightSwitch in ipairs(lightSwitches) do
      -- What happens next is up to you.
    end

  For the Future
  --------------

  This Script handles the gathering of all the Components for the client, but
  right now the client has the freedom to turn anything in the game into any of
  the available classes in ReplicatedStorage.

  Eventually we'll be counteracting this by making the server the authority
  figure, where all of the Components it gathers are the only Instances that the
  client can work with.

  When these countermeasures are implemented, if the client (for example)
  attempts to turn a TriggerPart into a Warp, the server will check the
  TriggerPart against the list of Warp Components. If it's not in the list,
  we'll repremand the client. This will come in the form of either rolling back
  the changes they made, kicking them from the server, or something similar.
--]]

local run = game:GetService("RunService")

if run:IsServer() then
  local replicatedStorage = game:GetService("ReplicatedStorage")
  local serverStorage = game:GetService("ServerStorage")

  local ComponentLookup = require(serverStorage.Components.ComponentLookup)
  local expect = require(replicatedStorage.Helpers.Expect)

  local COMPONENT_LOCATION = workspace

  local function getLookup()
    local lookup = ComponentLookup.new()
    lookup:Propagate(COMPONENT_LOCATION)

    return lookup
  end

  local components = {
    lookup = getLookup()
  }

  function components:GetByType(componentType)
    assert(type(componentType) == "string", string.format("bad argument #1 to "..
      "GetByType (string expected, got %s)", expect.getType(componentType)))

    return self.lookup:GetComponents(componentType)
  end

  return components
else
  local route = require(script.Parent.Modules.Route)
  return route(script)
end