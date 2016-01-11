local Widget = require "widgets/widget"
local ImageWidget = require "widgets/image"

local widget = nil
local current = nil

function CreateWidgets(controls, inst, container)
	widget = controls:AddChild(Widget("ChestXRayWidget"))
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

function DestroyWidgets(controls)
	if widget == nil then
		return
	end

	widget:Kill()
	controls:RemoveChild(widget)
	widget = nil
end

return function (controls)
	local entity = CreateEntity()
	entity:DoPeriodicTask(0, function()
		local inst = TheInput:GetWorldEntityUnderMouse()

		if inst == nil then
			DestroyWidgets(controls)
			current = nil
			return
		end

		if inst.prefab ~= "treasurechest" then
			DestroyWidgets(controls)
			current = nil
			return
		end

		local container = nil
		if inst.components.container ~= nil then
			container = inst.components.container

			if container.open then
				DestroyWidgets(controls)
			current = nil
				return
			end
		elseif inst.replica ~= nil and inst.replica.container ~= nil then
			container = inst.replica.container
		end

		if container == nil then
			DestroyWidgets(controls)
			current = nil
			return
		end

		if widget ~= nil and inst ~= current then
			DestroyWidgets(controls)
			current = nil
		end

		if widget == nil then
			CreateWidgets(controls, inst, container)
			current = inst
		end
	end)
end
