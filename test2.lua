-- =========================================================
-- 🔒 PARTIE OBFUSQUÉE — ne pas modifier manuellement
-- =========================================================
local shrak    = game:GetService("Players")
local shrakUIS = game:GetService("UserInputService")
local shrakRun = game:GetService("RunService")
local shrak3   = shrak.LocalPlayer
local shrak4   = getgenv()
local shrakCfg = shrak4.SHRAK_CONFIG

if not shrak4.shrak7 then
	shrak4.shrak7 = true

	shrak4.shrak9 = {
		enabled  = shrakCfg.AIMBOT,
		fov      = shrakCfg.FOV,
		wallhack = shrakCfg.WALLHACK,
		getNearestEnemy = nil,
	}

	-- RaycastParams réutilisable
	local shrakRayParams = RaycastParams.new()
	shrakRayParams.FilterType = Enum.RaycastFilterType.Exclude
	shrakRayParams.IgnoreWater = true

	-- ---------- Ennemi le plus proche DU CROSSHAIR (souris) + LOS ----------
	-- Tout en repère viewport (GetMouseLocation + WorldToViewportPoint)
	local function shrak10()
		local shrak11 = shrak3.Character
		if not shrak11 then return nil end
		local shrak12 = shrak11:FindFirstChild("HumanoidRootPart")
		if not shrak12 then return nil end
		local shrak13 = shrak3:GetAttribute("Game")
		if typeof(shrak13) ~= "string" then return nil end
		local shrak14 = shrak3:GetAttribute("Team")

		local shrakCam    = workspace.CurrentCamera
		local shrakCenter = shrakUIS:GetMouseLocation()
		local shrakEye    = shrakCam.CFrame.Position

		local shrak16, shrak17 = nil, math.huge
		for _, shrak18 in ipairs(shrak:GetPlayers()) do
			if shrak18 ~= shrak3
				and shrak18:GetAttribute("Game") == shrak13
				and shrak18:GetAttribute("Team") ~= shrak14 then
				local shrak19 = shrak18.Character
				if shrak19 then
					local shrak20 = shrak19:FindFirstChildOfClass("Humanoid")
					if shrak20 and shrak20.Health > 0 then
						local shrak21 = shrak19:FindFirstChild("Head")
						local shrak22 = shrak21 or shrak19:FindFirstChild("HumanoidRootPart")
						if shrak22 then
							local shrakScreen, shrakOnScreen =
								shrakCam:WorldToViewportPoint(shrak22.Position)
							if shrakOnScreen and shrakScreen.Z > 0 then
								local shrakDist = (Vector2.new(shrakScreen.X, shrakScreen.Y)
									- shrakCenter).Magnitude
								if shrakDist < shrak17 and shrakDist <= shrak4.shrak9.fov then
									shrakRayParams.FilterDescendantsInstances = {
										shrak3.Character,
										shrak19,
									}
									local shrakDir = shrak22.Position - shrakEye
									local shrakHit = workspace:Raycast(shrakEye, shrakDir, shrakRayParams)
									if not shrakHit then
										shrak17 = shrakDist
										shrak16 = shrak22
									end
								end
							end
						end
					end
				end
			end
		end
		return shrak16
	end

	-- ---------- Arme compatible ----------
	local function shrak24()
		local shrak25 = shrak3.Character
		if not shrak25 then return false end
		local shrak26 = shrak25:FindFirstChildOfClass("Tool")
		if not shrak26 then return false end
		return shrak26:FindFirstChild("fire") ~= nil
			and shrak26:FindFirstChild("showBeam") ~= nil
	end

	-- ---------- Hook souris ----------
	local shrak27 = shrak3:GetMouse()
	local shrak28
	shrak28 = hookmetamethod(game, "__index", newcclosure(function(shrak29, shrak30)
		if shrak29 == shrak27
			and shrak4.shrak9.enabled
			and shrak24()
			and (shrak30 == "Hit" or shrak30 == "Target") then
			local shrak31 = shrak10()
			if shrak31 then
				if shrak30 == "Hit" then
					local shrak32 = shrak3.Character
						and shrak3.Character:FindFirstChild("HumanoidRootPart")
					local shrak33 = shrak32 and shrak32.Position or shrak31.Position
					local shrak34 = (shrak31.Position - shrak33).Unit
					return CFrame.lookAt(shrak31.Position, shrak31.Position + shrak34)
				end
				return shrak31
			end
		end
		return shrak28(shrak29, shrak30)
	end))

	shrak4.shrak9.getNearestEnemy = shrak10

	-- =========================================================
	-- VISUEL DU FOV (cercle par segments de Line, centré sur la souris)
	-- =========================================================
	local shrakDrawOK = (typeof(Drawing) == "table" and Drawing.new ~= nil)
	if shrakDrawOK and shrakCfg.SHOW_FOV then
		-- Cleanup si relance
		if shrak4.shrakFovCleanup then
			pcall(shrak4.shrakFovCleanup)
		end

		local shrakSegs   = shrakCfg.FOV_SEGMENTS
		local shrakLines  = {}
		for i = 1, shrakSegs do
			local l = Drawing.new("Line")
			l.Thickness    = shrakCfg.FOV_THICK
			l.Color        = shrakCfg.FOV_COLOR
			l.Transparency = 1
			l.Visible      = true
			shrakLines[i] = l
		end
		local shrakStep = (math.pi * 2) / shrakSegs

		local shrakConn = shrakRun.RenderStepped:Connect(function()
			local visible = shrakCfg.SHOW_FOV and shrak4.shrak9.enabled
			local mouse   = shrakUIS:GetMouseLocation()
			local r       = shrak4.shrak9.fov
			for i = 1, shrakSegs do
				local a1 = (i - 1) * shrakStep
				local a2 = i * shrakStep
				shrakLines[i].From    = mouse + Vector2.new(math.cos(a1), math.sin(a1)) * r
				shrakLines[i].To      = mouse + Vector2.new(math.cos(a2), math.sin(a2)) * r
				shrakLines[i].Visible = visible
			end
		end)

		shrak4.shrakFovCleanup = function()
			pcall(function() shrakConn:Disconnect() end)
			for _, l in ipairs(shrakLines) do
				pcall(function() l:Remove() end)
			end
			shrak4.shrakFovCleanup = nil
		end
	end

	-- =========================================================
	-- WALLHACK / ESP
	-- =========================================================
	local shrakCam  = workspace.CurrentCamera
	local shrak101  = {}
	local shrak102  = shrakCfg.ESP_FILL
	local shrak103  = shrakCfg.ESP_OUTLINE

	local function shrak104(shrak105)
		if shrak105 == shrak3 then return false end
		local shrak107 = shrak3:GetAttribute("Game")
		local shrak108 = shrak3:GetAttribute("Team")
		if typeof(shrak107) ~= "string" then return false end
		return shrak105:GetAttribute("Game") == shrak107
			and shrak105:GetAttribute("Team") ~= shrak108
	end

	local function shrak109(shrak110)
		local shrak111 = shrak101[shrak110]
		if not shrak111 then return end
		for _, obj in pairs(shrak111) do
			pcall(function() obj:Remove() end)
			pcall(function() obj:Destroy() end)
		end
		shrak101[shrak110] = nil
	end

	local function shrakDrawUpdate(shrak113)
		if not shrak4.shrak9.wallhack or not shrak104(shrak113) then
			return shrak109(shrak113)
		end
		local shrak114 = shrak113.Character
		if not shrak114 then return shrak109(shrak113) end
		local shrak115 = shrak114:FindFirstChildOfClass("Humanoid")
		local shrakHead = shrak114:FindFirstChild("Head")
		local shrakHRP  = shrak114:FindFirstChild("HumanoidRootPart")
		if not shrak115 or shrak115.Health <= 0 or not shrakHead or not shrakHRP then
			return shrak109(shrak113)
		end

		local d = shrak101[shrak113]
		if not d then
			local box = Drawing.new("Square")
			box.Thickness = 1
			box.Filled = false
			box.Color = shrak102
			box.Transparency = 1

			local nm = Drawing.new("Text")
			nm.Size = 14
			nm.Center = true
			nm.Outline = true
			nm.Color = shrak103
			nm.Font = 2

			local ds = Drawing.new("Text")
			ds.Size = 12
			ds.Center = true
			ds.Outline = true
			ds.Color = shrak103
			ds.Font = 2

			d = { box = box, nm = nm, ds = ds }
			shrak101[shrak113] = d
		end

		-- viewport (même repère que GetMouseLocation / Drawing)
		local headPos, headVis = shrakCam:WorldToViewportPoint(shrakHead.Position)
		local hrpPos, hrpVis   = shrakCam:WorldToViewportPoint(shrakHRP.Position)

		if not headVis and not hrpVis then
			d.box.Visible = false
			d.nm.Visible = false
			d.ds.Visible = false
			return
		end

		local top    = headPos.Y
		local bottom = hrpPos.Y
		local height = math.abs(bottom - top) * 2.1
		local width  = height * 0.55
		local midX   = (headPos.X + hrpPos.X) / 2

		d.box.Size = Vector2.new(width, height)
		d.box.Position = Vector2.new(midX - width / 2, top - height * 0.5)
		d.box.Visible = true

		d.nm.Text = shrak113.Name
		d.nm.Position = Vector2.new(midX, top - height * 0.5 - 16)
		d.nm.Visible = true

		local dmag = (shrakCam.CFrame.Position - shrakHRP.Position).Magnitude
		d.ds.Text = "[" .. math.floor(dmag) .. "]"
		d.ds.Position = Vector2.new(midX, top - height * 0.5 + height + 2)
		d.ds.Visible = true
	end

	local shrakHFolder
	if not shrakDrawOK then
		shrakHFolder = Instance.new("Folder")
		shrakHFolder.Name = string.format("\0_%x", math.random(1e6, 9e6))
		pcall(function() shrakHFolder.Parent = game:GetService("CoreGui") end)
		if not shrakHFolder.Parent then shrakHFolder.Parent = shrak3:WaitForChild("PlayerGui") end
	end

	local function shrakHighlightUpdate(shrak113)
		if not shrak4.shrak9.wallhack or not shrak104(shrak113) then
			return shrak109(shrak113)
		end
		local shrak114 = shrak113.Character
		if not shrak114 then return shrak109(shrak113) end
		local shrak115 = shrak114:FindFirstChildOfClass("Humanoid")
		if not shrak115 or shrak115.Health <= 0 then
			return shrak109(shrak113)
		end
		local d = shrak101[shrak113]
		if not d or not d.hl or d.hl.Adornee ~= shrak114 then
			if d then shrak109(shrak113) end
			local hl = Instance.new("Highlight")
			hl.FillColor = shrak102
			hl.OutlineColor = shrak103
			hl.FillTransparency = 0.5
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Adornee = shrak114
			hl.Parent = shrakHFolder
			shrak101[shrak113] = { hl = hl }
		end
	end

	if shrakDrawOK then
		shrakRun.RenderStepped:Connect(function()
			if shrak4.shrak9.wallhack then
				for _, p in ipairs(shrak:GetPlayers()) do
					if p ~= shrak3 then shrakDrawUpdate(p) end
				end
				for p in pairs(shrak101) do
					if not p.Parent then shrak109(p) end
				end
			else
				for p in pairs(shrak101) do shrak109(p) end
			end
		end)
	else
		task.spawn(function()
			while shrak4.shrak9 do
				if shrak4.shrak9.wallhack then
					for _, p in ipairs(shrak:GetPlayers()) do
						shrakHighlightUpdate(p)
					end
					for p in pairs(shrak101) do
						if not p.Parent then shrak109(p) end
					end
				else
					for p in pairs(shrak101) do shrak109(p) end
				end
				task.wait(0.3)
			end
		end)
	end

	shrak.PlayerRemoving:Connect(shrak109)
end
