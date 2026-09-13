-- =========================================================
-- 🔒 PARTIE OBFUSQUÉE — ne pas modifier manuellement
-- =========================================================
local akkiwi    = game:GetService("Players")
local akkiwiUIS = game:GetService("UserInputService")
local akkiwiRun = game:GetService("RunService")
local akkiwi3   = akkiwi.LocalPlayer
local akkiwi4   = getgenv()
local akkiwiCfg = akkiwi4.AKKIWI_CONFIG

if not akkiwi4.akkiwi7 then
	akkiwi4.akkiwi7 = true

	akkiwi4.akkiwi9 = {
		enabled  = akkiwiCfg.AIMBOT,
		fov      = akkiwiCfg.FOV,
		wallhack = akkiwiCfg.WALLHACK,
		getNearestEnemy = nil,
	}

	-- RaycastParams réutilisable
	local akkiwiRayParams = RaycastParams.new()
	akkiwiRayParams.FilterType = Enum.RaycastFilterType.Exclude
	akkiwiRayParams.IgnoreWater = true

	-- ---------- Ennemi le plus proche DU CROSSHAIR (souris) + LOS ----------
	local function akkiwi10()
		local akkiwi11 = akkiwi3.Character
		if not akkiwi11 then return nil end
		local akkiwi12 = akkiwi11:FindFirstChild("HumanoidRootPart")
		if not akkiwi12 then return nil end
		local akkiwi13 = akkiwi3:GetAttribute("Game")
		if typeof(akkiwi13) ~= "string" then return nil end
		local akkiwi14 = akkiwi3:GetAttribute("Team")

		local akkiwiCam    = workspace.CurrentCamera
		local akkiwiCenter = akkiwiUIS:GetMouseLocation()
		local akkiwiEye    = akkiwiCam.CFrame.Position

		local akkiwi16, akkiwi17 = nil, math.huge
		for _, akkiwi18 in ipairs(akkiwi:GetPlayers()) do
			if akkiwi18 ~= akkiwi3
				and akkiwi18:GetAttribute("Game") == akkiwi13
				and akkiwi18:GetAttribute("Team") ~= akkiwi14 then
				local akkiwi19 = akkiwi18.Character
				if akkiwi19 then
					local akkiwi20 = akkiwi19:FindFirstChildOfClass("Humanoid")
					if akkiwi20 and akkiwi20.Health > 0 then
						local akkiwi21 = akkiwi19:FindFirstChild("Head")
						local akkiwi22 = akkiwi21 or akkiwi19:FindFirstChild("HumanoidRootPart")
						if akkiwi22 then
							local akkiwiScreen, akkiwiOnScreen =
								akkiwiCam:WorldToViewportPoint(akkiwi22.Position)
							if akkiwiOnScreen and akkiwiScreen.Z > 0 then
								local akkiwiDist = (Vector2.new(akkiwiScreen.X, akkiwiScreen.Y)
									- akkiwiCenter).Magnitude
								if akkiwiDist < akkiwi17 and akkiwiDist <= akkiwi4.akkiwi9.fov then
									akkiwiRayParams.FilterDescendantsInstances = {
										akkiwi3.Character,
										akkiwi19,
									}
									local akkiwiDir = akkiwi22.Position - akkiwiEye
									local akkiwiHit = workspace:Raycast(akkiwiEye, akkiwiDir, akkiwiRayParams)
									if not akkiwiHit then
										akkiwi17 = akkiwiDist
										akkiwi16 = akkiwi22
									end
								end
							end
						end
					end
				end
			end
		end
		return akkiwi16
	end

	-- ---------- Arme compatible ----------
	local function akkiwi24()
		local akkiwi25 = akkiwi3.Character
		if not akkiwi25 then return false end
		local akkiwi26 = akkiwi25:FindFirstChildOfClass("Tool")
		if not akkiwi26 then return false end
		return akkiwi26:FindFirstChild("fire") ~= nil
			and akkiwi26:FindFirstChild("showBeam") ~= nil
	end

	-- ---------- Hook souris ----------
	local akkiwi27 = akkiwi3:GetMouse()
	local akkiwi28
	akkiwi28 = hookmetamethod(game, "__index", newcclosure(function(akkiwi29, akkiwi30)
		if akkiwi29 == akkiwi27
			and akkiwi4.akkiwi9.enabled
			and akkiwi24()
			and (akkiwi30 == "Hit" or akkiwi30 == "Target") then
			local akkiwi31 = akkiwi10()
			if akkiwi31 then
				if akkiwi30 == "Hit" then
					local akkiwi32 = akkiwi3.Character
						and akkiwi3.Character:FindFirstChild("HumanoidRootPart")
					local akkiwi33 = akkiwi32 and akkiwi32.Position or akkiwi31.Position
					local akkiwi34 = (akkiwi31.Position - akkiwi33).Unit
					return CFrame.lookAt(akkiwi31.Position, akkiwi31.Position + akkiwi34)
				end
				return akkiwi31
			end
		end
		return akkiwi28(akkiwi29, akkiwi30)
	end))

	akkiwi4.akkiwi9.getNearestEnemy = akkiwi10

	-- =========================================================
	-- VISUEL DU FOV (cercle par segments de Line, centré sur la souris)
	-- =========================================================
	local akkiwiDrawOK = (typeof(Drawing) == "table" and Drawing.new ~= nil)
	if akkiwiDrawOK and akkiwiCfg.SHOW_FOV then
		if akkiwi4.akkiwiFovCleanup then
			pcall(akkiwi4.akkiwiFovCleanup)
		end

		local akkiwiSegs   = akkiwiCfg.FOV_SEGMENTS
		local akkiwiLines  = {}
		for i = 1, akkiwiSegs do
			local l = Drawing.new("Line")
			l.Thickness    = akkiwiCfg.FOV_THICK
			l.Color        = akkiwiCfg.FOV_COLOR
			l.Transparency = 1
			l.Visible      = true
			akkiwiLines[i] = l
		end
		local akkiwiStep = (math.pi * 2) / akkiwiSegs

		local akkiwiConn = akkiwiRun.RenderStepped:Connect(function()
			local visible = akkiwiCfg.SHOW_FOV and akkiwi4.akkiwi9.enabled
			local mouse   = akkiwiUIS:GetMouseLocation()
			local r       = akkiwi4.akkiwi9.fov
			for i = 1, akkiwiSegs do
				local a1 = (i - 1) * akkiwiStep
				local a2 = i * akkiwiStep
				akkiwiLines[i].From    = mouse + Vector2.new(math.cos(a1), math.sin(a1)) * r
				akkiwiLines[i].To      = mouse + Vector2.new(math.cos(a2), math.sin(a2)) * r
				akkiwiLines[i].Visible = visible
			end
		end)

		akkiwi4.akkiwiFovCleanup = function()
			pcall(function() akkiwiConn:Disconnect() end)
			for _, l in ipairs(akkiwiLines) do
				pcall(function() l:Remove() end)
			end
			akkiwi4.akkiwiFovCleanup = nil
		end
	end

	-- =========================================================
	-- WALLHACK / ESP
	-- =========================================================
	local akkiwiCam  = workspace.CurrentCamera
	local akkiwi101  = {}
	local akkiwi102  = akkiwiCfg.ESP_FILL
	local akkiwi103  = akkiwiCfg.ESP_OUTLINE

	local function akkiwi104(akkiwi105)
		if akkiwi105 == akkiwi3 then return false end
		local akkiwi107 = akkiwi3:GetAttribute("Game")
		local akkiwi108 = akkiwi3:GetAttribute("Team")
		if typeof(akkiwi107) ~= "string" then return false end
		return akkiwi105:GetAttribute("Game") == akkiwi107
			and akkiwi105:GetAttribute("Team") ~= akkiwi108
	end

	local function akkiwi109(akkiwi110)
		local akkiwi111 = akkiwi101[akkiwi110]
		if not akkiwi111 then return end
		for _, obj in pairs(akkiwi111) do
			pcall(function() obj:Remove() end)
			pcall(function() obj:Destroy() end)
		end
		akkiwi101[akkiwi110] = nil
	end

	local function akkiwiDrawUpdate(akkiwi113)
		if not akkiwi4.akkiwi9.wallhack or not akkiwi104(akkiwi113) then
			return akkiwi109(akkiwi113)
		end
		local akkiwi114 = akkiwi113.Character
		if not akkiwi114 then return akkiwi109(akkiwi113) end
		local akkiwi115 = akkiwi114:FindFirstChildOfClass("Humanoid")
		local akkiwiHead = akkiwi114:FindFirstChild("Head")
		local akkiwiHRP  = akkiwi114:FindFirstChild("HumanoidRootPart")
		if not akkiwi115 or akkiwi115.Health <= 0 or not akkiwiHead or not akkiwiHRP then
			return akkiwi109(akkiwi113)
		end

		local d = akkiwi101[akkiwi113]
		if not d then
			local box = Drawing.new("Square")
			box.Thickness = 1
			box.Filled = false
			box.Color = akkiwi102
			box.Transparency = 1

			local nm = Drawing.new("Text")
			nm.Size = 14
			nm.Center = true
			nm.Outline = true
			nm.Color = akkiwi103
			nm.Font = 2

			local ds = Drawing.new("Text")
			ds.Size = 12
			ds.Center = true
			ds.Outline = true
			ds.Color = akkiwi103
			ds.Font = 2

			d = { box = box, nm = nm, ds = ds }
			akkiwi101[akkiwi113] = d
		end

		local headPos, headVis = akkiwiCam:WorldToViewportPoint(akkiwiHead.Position)
		local hrpPos, hrpVis   = akkiwiCam:WorldToViewportPoint(akkiwiHRP.Position)

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

		d.nm.Text = akkiwi113.Name
		d.nm.Position = Vector2.new(midX, top - height * 0.5 - 16)
		d.nm.Visible = true

		local dmag = (akkiwiCam.CFrame.Position - akkiwiHRP.Position).Magnitude
		d.ds.Text = "[" .. math.floor(dmag) .. "]"
		d.ds.Position = Vector2.new(midX, top - height * 0.5 + height + 2)
		d.ds.Visible = true
	end

	local akkiwiHFolder
	if not akkiwiDrawOK then
		akkiwiHFolder = Instance.new("Folder")
		akkiwiHFolder.Name = string.format("\0_%x", math.random(1e6, 9e6))
		pcall(function() akkiwiHFolder.Parent = game:GetService("CoreGui") end)
		if not akkiwiHFolder.Parent then akkiwiHFolder.Parent = akkiwi3:WaitForChild("PlayerGui") end
	end

	local function akkiwiHighlightUpdate(akkiwi113)
		if not akkiwi4.akkiwi9.wallhack or not akkiwi104(akkiwi113) then
			return akkiwi109(akkiwi113)
		end
		local akkiwi114 = akkiwi113.Character
		if not akkiwi114 then return akkiwi109(akkiwi113) end
		local akkiwi115 = akkiwi114:FindFirstChildOfClass("Humanoid")
		if not akkiwi115 or akkiwi115.Health <= 0 then
			return akkiwi109(akkiwi113)
		end
		local d = akkiwi101[akkiwi113]
		if not d or not d.hl or d.hl.Adornee ~= akkiwi114 then
			if d then akkiwi109(akkiwi113) end
			local hl = Instance.new("Highlight")
			hl.FillColor = akkiwi102
			hl.OutlineColor = akkiwi103
			hl.FillTransparency = 0.5
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Adornee = akkiwi114
			hl.Parent = akkiwiHFolder
			akkiwi101[akkiwi113] = { hl = hl }
		end
	end

	if akkiwiDrawOK then
		akkiwiRun.RenderStepped:Connect(function()
			if akkiwi4.akkiwi9.wallhack then
				for _, p in ipairs(akkiwi:GetPlayers()) do
					if p ~= akkiwi3 then akkiwiDrawUpdate(p) end
				end
				for p in pairs(akkiwi101) do
					if not p.Parent then akkiwi109(p) end
				end
			else
				for p in pairs(akkiwi101) do akkiwi109(p) end
			end
		end)
	else
		task.spawn(function()
			while akkiwi4.akkiwi9 do
				if akkiwi4.akkiwi9.wallhack then
					for _, p in ipairs(akkiwi:GetPlayers()) do
						akkiwiHighlightUpdate(p)
					end
					for p in pairs(akkiwi101) do
						if not p.Parent then akkiwi109(p) end
					end
				else
					for p in pairs(akkiwi101) do akkiwi109(p) end
				end
				task.wait(0.3)
			end
		end)
	end

	akkiwi.PlayerRemoving:Connect(akkiwi109)
end
