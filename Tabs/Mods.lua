local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
print("Loaded updated layout script")

-- UI Layout Initialization (Using Tabboxes to prevent vertical overflow)
local WeaponTabbox = ModsTab:AddLeftTabbox('Weapons')
local WeaponGroup = WeaponTabbox:AddTab('Weapon Mods')

local RightTabbox = ModsTab:AddRightTabbox('Utilities & Mods')
local LaptopMainGroup = RightTabbox:AddTab('Laptop Mods')
local SoundModGroup = RightTabbox:AddTab('Sound Modder')
local SniperGroup = RightTabbox:AddTab('Sway Mods')

local originalSettingsCache = {}

local function GetOriginalSettings(tool)
	if originalSettingsCache[tool] then
		return originalSettingsCache[tool]
	end

	local settingsModule = tool:FindFirstChild('Settings')
	if settingsModule and settingsModule:IsA('ModuleScript') then
		local success, settingsTable = pcall(require, settingsModule)
		if success and type(settingsTable) == 'table' then
			local copy = {}
			for k, v in pairs(settingsTable) do
				copy[k] = v
			end
			originalSettingsCache[tool] = copy
			return copy
		end
	end
	return {}
end

local function ApplySingleMod(key, optionName)
	local character = LocalPlayer.Character
	if not character then return end

	local tool = character:FindFirstChildOfClass("Tool")
	if not tool then return end

	local settingsModule = tool:FindFirstChild('Settings')
	if not settingsModule or not settingsModule:IsA('ModuleScript') then return end

	local success, mod = pcall(require, settingsModule)
	if not success or type(mod) ~= 'table' then return end

	GetOriginalSettings(tool)

	local option = Options[optionName]
	if not option then return end

	local val = option.Value
	mod[key] = val

	if key == "ReloadSpeed" and mod["ReloadSpeed2"] ~= nil then
		mod["ReloadSpeed2"] = val
	end
end

local function ApplyWeaponMod()
	local character = LocalPlayer.Character
	if not character then error("Character not found") end

	local tool = character:FindFirstChildOfClass("Tool")
	if not tool then error("You need to hold a tool") end

	local settingsModule = tool:FindFirstChild('Settings')
	if not settingsModule or not settingsModule:IsA('ModuleScript') then error("Tool has no Settings module") end

	local success, mod = pcall(require, settingsModule)
	if not success or type(mod) ~= 'table' then error("Failed to require Settings module") end

	local old = GetOriginalSettings(tool)

	local cfg = {
		ReloadSpeed = Options.ModReloadSpeed and Options.ModReloadSpeed.Value or mod.ReloadSpeed,
		ReloadSpeed2 = Options.ModReloadSpeed and Options.ModReloadSpeed.Value or mod.ReloadSpeed2,
		waittime = Options.ModFireRate and Options.ModFireRate.Value or mod.waittime,
		GunRecoil = Options.ModRecoil and Options.ModRecoil.Value or mod.GunRecoil,
		GunRecoilX = Options.ModRecoilX and Options.ModRecoilX.Value or mod.GunRecoilX,
		AimSpeed = Options.ModAimSpeed and Options.ModAimSpeed.Value or mod.AimSpeed,
		cooldown = Options.ModCooldown and Options.ModCooldown.Value or mod.cooldown,
		guardTime = Options.ModGuardTime and Options.ModGuardTime.Value or mod.guardTime,
		BoltAction = Toggles.ModBoltAction and not Toggles.ModBoltAction.Value or mod.BoltAction,
		auto = Toggles.MakeGunAutoAction and Toggles.MakeGunAutoAction.Value or mod.auto,
		scatter = (Toggles.SilentAimEnabled and Toggles.SilentAimEnabled.Value) and nil or mod.scatter,
		AimScatterMultiplyer = nil,
		accMult = (Toggles.SilentAimEnabled and Toggles.SilentAimEnabled.Value) and 0 or mod.accMult,
	}

	for index, v in pairs(cfg) do
		if v ~= old[index] then
			mod[index] = v
		end
	end

	Library:Notify('Applied weapon modifications!', 2)
end

-- UI Labels
local ReloadLabel, FireRateLabel, RecoilLabel, RecoilXLabel, AimSpeedLabel, CooldownLabel, GuardTimeLabel

-- Sync weapon & laptop stats to sliders & labels on tool equip
local function SyncWeaponStats(tool)
	if not tool or not tool:IsA("Tool") then return end

	local settingsModule = tool:WaitForChild('Settings', 1) or tool:FindFirstChild('Settings')
	if not settingsModule or not settingsModule:IsA('ModuleScript') then return end

	local old = GetOriginalSettings(tool)
	if not old or next(old) == nil then return end

	-- Weapon Stats Sync
	if old.ReloadSpeed ~= nil and Options.ModReloadSpeed then
		Options.ModReloadSpeed:SetValue(old.ReloadSpeed)
		if ReloadLabel then ReloadLabel:SetText('Default Reload: ' .. tostring(old.ReloadSpeed)) end
	end
	if old.waittime ~= nil and Options.ModFireRate then
		Options.ModFireRate:SetValue(old.waittime)
		if FireRateLabel then FireRateLabel:SetText('Default Fire Rate: ' .. tostring(old.waittime)) end
	end
	if old.GunRecoil ~= nil and Options.ModRecoil then
		Options.ModRecoil:SetValue(old.GunRecoil)
		if RecoilLabel then RecoilLabel:SetText('Default Recoil Y: ' .. tostring(old.GunRecoil)) end
	end
	if old.GunRecoilX ~= nil and Options.ModRecoilX then
		Options.ModRecoilX:SetValue(old.GunRecoilX)
		if RecoilXLabel then RecoilXLabel:SetText('Default Recoil X: ' .. tostring(old.GunRecoilX)) end
	end
	if old.AimSpeed ~= nil and Options.ModAimSpeed then
		Options.ModAimSpeed:SetValue(old.AimSpeed)
		if AimSpeedLabel then AimSpeedLabel:SetText('Default Aim Speed: ' .. tostring(old.AimSpeed)) end
	end
	if old.cooldown ~= nil and Options.ModCooldown then
		Options.ModCooldown:SetValue(old.cooldown)
		if CooldownLabel then CooldownLabel:SetText('Default Cooldown: ' .. tostring(old.cooldown)) end
	end
	if old.guardTime ~= nil and Options.ModGuardTime then
		Options.ModGuardTime:SetValue(old.guardTime)
		if GuardTimeLabel then GuardTimeLabel:SetText('Default Guard Time: ' .. tostring(old.guardTime)) end
	end

	-- Laptop Stats Sync
	if old.flightSpeed ~= nil and Options.LaptopFlightSpeed then Options.LaptopFlightSpeed:SetValue(old.flightSpeed) end
	if old.turnSpeed ~= nil and Options.LaptopTurnSpeed then Options.LaptopTurnSpeed:SetValue(old.turnSpeed) end
	if old.droneCloakDuration ~= nil and Options.LaptopCloakDuration then Options.LaptopCloakDuration:SetValue(old.droneCloakDuration) end
	if old.droneCloakCooldown ~= nil and Options.LaptopCloakCooldown then Options.LaptopCloakCooldown:SetValue(old.droneCloakCooldown) end
	if old.droneDefibCooldown ~= nil and Options.LaptopDefibCooldown then Options.LaptopDefibCooldown:SetValue(old.droneDefibCooldown) end
	if old.droneGunRecharge ~= nil and Options.LaptopGunRecharge then Options.LaptopGunRecharge:SetValue(old.droneGunRecharge) end
	if old.droneGunDamage ~= nil and Options.LaptopGunDamage then Options.LaptopGunDamage:SetValue(old.droneGunDamage) end
	if old.droneHealth ~= nil and Options.LaptopDroneHealth then Options.LaptopDroneHealth:SetValue(old.droneHealth) end
end

-- -------------------------------------------------------------
-- Weapon Group Setup
-- -------------------------------------------------------------

WeaponGroup:AddButton({
	Text = 'Fetch & Sync Gun Stats',
	Func = function()
		local character = LocalPlayer.Character
		if not character then return Library:Notify("Character not found", 3) end

		local tool = character:FindFirstChildOfClass("Tool")
		if not tool then return Library:Notify("You need to hold a tool", 3) end

		SyncWeaponStats(tool)
		Library:Notify('Synced sliders with ' .. tool.Name .. ' defaults!', 3)
	end
})

WeaponGroup:AddButton({
	Text = 'Apply All Mods',
	Func = function()
		xpcall(ApplyWeaponMod, function(err)
			Library:Notify('Error: ' .. tostring(err), 3)
		end)
	end
})

WeaponGroup:AddDivider()

WeaponGroup:AddToggle('ModBoltAction', {
	Text = 'Disable Bolt Action',
	Default = false,
	Callback = function() pcall(ApplyWeaponMod) end
})

WeaponGroup:AddToggle('MakeGunAutoAction', {
	Text = 'Make Gun Auto',
	Default = false,
	Callback = function() pcall(ApplyWeaponMod) end
})

WeaponGroup:AddDivider()

ReloadLabel = WeaponGroup:AddLabel('Default Reload: N/A')
WeaponGroup:AddSlider('ModReloadSpeed', { Text = 'Reload Speed (s)', Default = 0.5, Min = 0.05, Max = 3.0, Rounding = 2, Callback = function() ApplySingleMod('ReloadSpeed', 'ModReloadSpeed') end })

FireRateLabel = WeaponGroup:AddLabel('Default Fire Rate: N/A')
WeaponGroup:AddSlider('ModFireRate', { Text = 'Fire Delay / Wait Time (s)', Default = 0.04, Min = 0.01, Max = 0.20, Rounding = 3, Callback = function() ApplySingleMod('waittime', 'ModFireRate') end })

RecoilLabel = WeaponGroup:AddLabel('Default Recoil Y: N/A')
WeaponGroup:AddSlider('ModRecoil', { Text = 'Gun Recoil (Vertical)', Default = 0.3, Min = 0, Max = 2.0, Rounding = 2, Callback = function() ApplySingleMod('GunRecoil', 'ModRecoil') end })

RecoilXLabel = WeaponGroup:AddLabel('Default Recoil X: N/A')
WeaponGroup:AddSlider('ModRecoilX', { Text = 'Gun Recoil X (Horizontal)', Default = 0.3, Min = 0, Max = 2.0, Rounding = 2, Callback = function() ApplySingleMod('GunRecoilX', 'ModRecoilX') end })

AimSpeedLabel = WeaponGroup:AddLabel('Default Aim Speed: N/A')
WeaponGroup:AddSlider('ModAimSpeed', { Text = 'Aim Speed (ADS Duration)', Default = 0.25, Min = 0.01, Max = 1.0, Rounding = 2, Callback = function() ApplySingleMod('AimSpeed', 'ModAimSpeed') end })

CooldownLabel = WeaponGroup:AddLabel('Default Cooldown: N/A')
WeaponGroup:AddSlider('ModCooldown', { Text = 'Attack Cooldown (s)', Default = 0.54, Min = 0.01, Max = 3.0, Rounding = 2, Callback = function() ApplySingleMod('cooldown', 'ModCooldown') end })

GuardTimeLabel = WeaponGroup:AddLabel('Default Guard Time: N/A')
WeaponGroup:AddSlider('ModGuardTime', { Text = 'Guard Time (s)', Default = 1.5, Min = 0.1, Max = 5.0, Rounding = 2, Callback = function() ApplySingleMod('guardTime', 'ModGuardTime') end })

-- -------------------------------------------------------------
-- Sound Modder Setup
-- -------------------------------------------------------------

SoundModGroup:AddInput('SoundIdInput', {
	Default = 'rbxassetid://0',
	Numeric = false,
	Finished = false,
	Text = 'New Sound ID Input',
	Placeholder = 'rbxassetid://...'
})

local function UpdateToolSounds()
	local inputVal = Options.SoundIdInput and Options.SoundIdInput.Value
	if not inputVal or inputVal == '' or inputVal == 'rbxassetid://0' then return end

	local formattedInput = inputVal
	if not string.match(inputVal, "rbxassetid://") then
		local numericId = string.match(inputVal, "%d+")
		if numericId then formattedInput = "rbxassetid://" .. numericId end
	end

	local character = LocalPlayer.Character
	if not character then return end

	for _, child in ipairs(character:GetChildren()) do
		if child:IsA('Tool') then
			for _, obj in ipairs(child:GetDescendants()) do
				if obj:IsA('Sound') and obj.SoundId ~= formattedInput then
					obj.SoundId = formattedInput
				end
			end
		end
	end
end

local ToolSoundConnection = nil
SoundModGroup:AddToggle('AutoUpdateSounds', {
	Text = 'Auto-Update Equipped Sound Loop',
	Default = false,
	Callback = function(Value)
		if Value then
			UpdateToolSounds()
			if LocalPlayer.Character and not ToolSoundConnection then
				ToolSoundConnection = LocalPlayer.Character.ChildAdded:Connect(function(child)
					if child:IsA("Tool") then
						task.wait(0.1)
						UpdateToolSounds()
					end
				end)
			end
			Library:Notify('Sound auto-updater activated!', 3)
		else
			if ToolSoundConnection then ToolSoundConnection:Disconnect() ToolSoundConnection = nil end
			Library:Notify('Sound auto-updater deactivated.', 3)
		end
	end
})

SoundModGroup:AddButton({
	Text = 'Apply Once to Tool Sounds',
	Func = function()
		UpdateToolSounds()
		Library:Notify('Updated sounds in current tool!', 3)
	end
})

-- -------------------------------------------------------------
-- Laptop Modder Setup
-- -------------------------------------------------------------

local function ApplyLaptopMod()
	local character = LocalPlayer.Character
	if not character then error("Character not found") end

	local tool = character:FindFirstChildOfClass("Tool")
	if not tool or not tool:FindFirstChild('Settings') then
		tool = character:FindFirstChild("Laptop") or LocalPlayer.Backpack:FindFirstChild("Laptop")
	end

	if not tool then error("You need to hold or own the Laptop tool") end

	local settingsModule = tool:FindFirstChild('Settings')
	if not settingsModule or not settingsModule:IsA('ModuleScript') then error("Tool has no Settings module") end

	local success, mod = pcall(require, settingsModule)
	if not success or type(mod) ~= 'table' then error("Failed to require Settings module") end

	local old = GetOriginalSettings(tool)

	local cfg = {
		droneCloakDuration = Options.LaptopCloakDuration and Options.LaptopCloakDuration.Value or mod.droneCloakDuration,
		droneCloakCooldown = Options.LaptopCloakCooldown and Options.LaptopCloakCooldown.Value or mod.droneCloakCooldown,
		droneDefibCooldown = Options.LaptopDefibCooldown and Options.LaptopDefibCooldown.Value or mod.droneDefibCooldown,
		droneGunRecharge = Options.LaptopGunRecharge and Options.LaptopGunRecharge.Value or mod.droneGunRecharge,
		droneGunDamage = Options.LaptopGunDamage and Options.LaptopGunDamage.Value or mod.droneGunDamage,
		flightSpeed = Options.LaptopFlightSpeed and Options.LaptopFlightSpeed.Value or mod.flightSpeed,
		turnSpeed = Options.LaptopTurnSpeed and Options.LaptopTurnSpeed.Value or mod.turnSpeed,
		droneHealth = Options.LaptopDroneHealth and Options.LaptopDroneHealth.Value or mod.droneHealth,
		canOpenDoors = Toggles.LaptopCanOpenDoors and Toggles.LaptopCanOpenDoors.Value or mod.canOpenDoors,
	}

	for index, v in pairs(cfg) do
		if v ~= old[index] then
			mod[index] = v
		end
	end

	Library:Notify('Applied Laptop modifications!', 3)
end

LaptopMainGroup:AddButton({
	Text = 'Apply Laptop Mods',
	Func = function()
		xpcall(ApplyLaptopMod, function(err)
			Library:Notify('Error: ' .. tostring(err), 3)
		end)
	end
})

LaptopMainGroup:AddDivider()
LaptopMainGroup:AddSlider('LaptopFlightSpeed', { Text = 'Flight Speed', Default = 32, Min = 10, Max = 500, Rounding = 0, Callback = function() pcall(ApplyLaptopMod) end })
LaptopMainGroup:AddSlider('LaptopTurnSpeed', { Text = 'Turn Speed', Default = 90, Min = 10, Max = 500, Rounding = 0, Callback = function() pcall(ApplyLaptopMod) end })
LaptopMainGroup:AddSlider('LaptopCloakDuration', { Text = 'Cloak Duration', Default = 10, Min = 1, Max = 60, Rounding = 1, Callback = function() pcall(ApplyLaptopMod) end })
LaptopMainGroup:AddSlider('LaptopCloakCooldown', { Text = 'Cloak Cooldown', Default = 5, Min = 0, Max = 30, Rounding = 1, Callback = function() pcall(ApplyLaptopMod) end })
LaptopMainGroup:AddSlider('LaptopDefibCooldown', { Text = 'Defib Cooldown', Default = 5, Min = 0, Max = 30, Rounding = 1, Callback = function() pcall(ApplyLaptopMod) end })
LaptopMainGroup:AddSlider('LaptopGunRecharge', { Text = 'Gun Recharge Rate', Default = 1, Min = 0, Max = 10, Rounding = 1, Callback = function() pcall(ApplyLaptopMod) end })
LaptopMainGroup:AddSlider('LaptopGunDamage', { Text = 'Gun Damage', Default = 20, Min = 1, Max = 500, Rounding = 0, Callback = function() pcall(ApplyLaptopMod) end })
LaptopMainGroup:AddSlider('LaptopDroneHealth', { Text = 'Drone Health', Default = 100, Min = 10, Max = 1000, Rounding = 0, Callback = function() pcall(ApplyLaptopMod) end })
LaptopMainGroup:AddToggle('LaptopCanOpenDoors', { Text = 'Can Open Doors', Default = true, Callback = function() pcall(ApplyLaptopMod) end })

local RemoveLaptopEffectsLoop = nil
LaptopMainGroup:AddToggle('RemoveLaptopEffects', {
	Text = 'Remove Overlay',
	Default = false,
	Callback = function(Value)
		if Value then
			RemoveLaptopEffectsLoop = RunService.RenderStepped:Connect(function()
				local charWorld = workspace:FindFirstChild(LocalPlayer.Name)
				if charWorld then
					local laptop = charWorld:FindFirstChild("Laptop")
					if laptop then
						local droneClient = laptop:FindFirstChild("DroneClient")
						if droneClient then
							local droneBlur = droneClient:FindFirstChild("DroneBlur")
							if droneBlur then droneBlur:Destroy() end

							local droneColor = droneClient:FindFirstChild("DroneColor")
							if droneColor then droneColor:Destroy() end
						end
					end
				end

				local vhs = PlayerGui:FindFirstChild("VHS")
				if vhs then vhs:Destroy() end
			end)
		else
			if RemoveLaptopEffectsLoop then
				RemoveLaptopEffectsLoop:Disconnect()
				RemoveLaptopEffectsLoop = nil
			end
		end
	end
})

-- -------------------------------------------------------------
-- Sway Modder Setup
-- -------------------------------------------------------------

local swayConnection = nil
local characterConnection = nil
local propertyConnections = {}

local function toggleAimSwayRemoval(enabled)
	if enabled then
		local function checkValue(item)
			if item.Name == "AimSway" or item.Name == "SwayTime" then
				if item:IsA("NumberValue") then
					item.Value = 0
					local conn = item:GetPropertyChangedSignal("Value"):Connect(function()
						if item.Value ~= 0 then
							item.Value = 0
						end
					end)
					table.insert(propertyConnections, conn)
				end
			end
		end

		local function setupCharacter(char)
			if swayConnection then swayConnection:Disconnect() end

			for _, descendant in ipairs(char:GetDescendants()) do
				checkValue(descendant)
			end

			swayConnection = char.DescendantAdded:Connect(checkValue)
		end

		if LocalPlayer.Character then
			setupCharacter(LocalPlayer.Character)
		end

		characterConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
			setupCharacter(newChar)
		end)

		Library:Notify('Aim Sway removal enabled!', 3)
	else
		if swayConnection then swayConnection:Disconnect() swayConnection = nil end
		if characterConnection then characterConnection:Disconnect() characterConnection = nil end

		for _, conn in ipairs(propertyConnections) do
			conn:Disconnect()
		end
		table.clear(propertyConnections)

		Library:Notify('Aim Sway removal disabled.', 3)
	end
end

SniperGroup:AddToggle('RemoveAimSwayToggle', {
	Text = 'Remove Scope Sway',
	Default = false,
	Callback = function(Value)
		pcall(function()
			toggleAimSwayRemoval(Value)
		end)
	end
})

-- -------------------------------------------------------------
-- Auto-Equip Hook Initialization
-- -------------------------------------------------------------

local function HookCharacter(char)
	if not char then return end

	local currentTool = char:FindFirstChildOfClass("Tool")
	if currentTool then
		task.spawn(function()
			SyncWeaponStats(currentTool)
		end)
	end

	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			task.wait(0.1)
			SyncWeaponStats(child)
		end
	end)
end

if LocalPlayer.Character then
	HookCharacter(LocalPlayer.Character)
end

LocalPlayer.CharacterAdded:Connect(HookCharacter)

return true
