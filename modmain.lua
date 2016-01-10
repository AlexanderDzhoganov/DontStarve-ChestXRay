local require = GLOBAL.require
local Input = GLOBAL.TheInput
local TheSim = GLOBAL.TheSim
local Vector3 = GLOBAL.Vector3
local CreateEntity = GLOBAL.CreateEntity

local Widget = require "widgets/widget"
local ImageWidget = require "widgets/image"

local widget = nil
local current = nil

function CreateWidgets(hud, inst, container)
	widget = hud.controls:AddChild(Widget("ChestXRayWidget"))
	widget:FollowMouse()
	widget:SetClickable(false)

	local items = {}
	for i = 0, container:GetNumSlots() do
		local item = container:GetItemInSlot(i)
		if item ~= nil then
			items[item.prefab] = item
		end
	end

	local currentX = 38
	for k, v in pairs(items) do
		local item = v
		if item ~= nil then
			local image = widget:AddChild(ImageWidget("images/inventoryimages.xml", item.prefab .. ".tex"))
			image:SetPosition(currentX, 0, 0)
			image:SetScale(0.6, 0.6, 0.6)
			currentX = currentX + 38
		end
	end
end

function DestroyWidgets(hud)
	if widget == nil then
		return
	end

	widget:Kill()
	hud.controls:RemoveChild(widget)
	widget = nil
end

local run = AddSimPostInit
if GLOBAL.TheSim:GetGameID() == "DST" then
	run = AddPlayerPostInit
end

run(function(player)
	player:DoPeriodicTask(0, function()
		local inst = Input:GetWorldEntityUnderMouse()
		if inst ~= nil and inst.components.container ~= nil then
			if widget ~= nil then
				if current ~= inst then
					DestroyWidgets(player.HUD)
				else
					return
				end
			end

			if inst.prefab == "treasurechest" and not inst.components.container.open then
				current = inst
				CreateWidgets(player.HUD, inst, inst.components.container)
			end
		else
			if inst == nil or inst.components.container == nil then
				DestroyWidgets(player.HUD)
				current = nil
			end
		end
	end)
end)
