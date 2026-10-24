local PainKillersUI = {
	Window = nil,
	Theme = nil,
	Creator = require("./modules/Creator"),
	LocalizationModule = require("./modules/Localization"),
	NotificationModule = require("./components/Notification"),
	Themes = nil,
	Transparent = false,

	TransparencyValue = 0.15,

	UIScale = 1,

	ConfigManager = nil,
	Version = "0.0.0",

	Services = require("./utils/services/Init"),

	OnThemeChangeFunction = nil,

	cloneref = nil,
	UIScaleObj = nil,

	CreateWindow = nil,

	CurrentInput = nil,
}

local cloneref = (cloneref or clonereference or function(instance)
	return instance
end)

PainKillersUI.cloneref = cloneref

local HttpService = cloneref(game:GetService("HttpService"))
local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

function PainKillersUI.GenerateGUID()
	return HttpService:GenerateGUID(false)
end

local CurInput = PainKillersUI.GenerateGUID()

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
	--[[if GameProcessed then
		return
	end]]

	task.defer(function()
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			if PainKillersUI.CurrentInput and PainKillersUI.CurrentInput ~= CurInput then
				return
			end

			PainKillersUI.CurrentInput = CurInput
			--print(CurInput)
			--PainKillersUI.InputStartedOnUI = false
		end
	end)
end)
UserInputService.InputEnded:Connect(function(Input, GameProcessed)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		if PainKillersUI.CurrentInput and PainKillersUI.CurrentInput ~= CurInput then
			return
		end

		PainKillersUI.CurrentInput = nil
	end
end)

local LocalPlayer = Players.LocalPlayer or nil

local Package = HttpService:JSONDecode(require("../build/package"))
if Package then
	PainKillersUI.Version = Package.version
end

local KeySystem = require("./components/KeySystem")

local Creator = PainKillersUI.Creator

local New = Creator.New

--local Tween = Creator.Tween
--local ServicesModule = PainKillersUI.Services

local Acrylic = require("./utils/Acrylic/Init")

local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end

local GUIParent = gethui and gethui() or (CoreGui or LocalPlayer:WaitForChild("PlayerGui"))

local UIScaleObj = New("UIScale", {
	Scale = PainKillersUI.UIScale,
})

PainKillersUI.UIScaleObj = UIScaleObj

PainKillersUI.ScreenGui = New("ScreenGui", {
	Name = "PainKillersUI",
	Parent = GUIParent,
	IgnoreGuiInset = true,
	ScreenInsets = "None",
	DisplayOrder = -99999,
}, {

	New("Folder", {
		Name = "Window",
	}),
	-- New("Folder", {
	--     Name = "Notifications"
	-- }),
	-- New("Folder", {
	--     Name = "Dropdowns"
	-- }),
	New("Folder", {
		Name = "KeySystem",
	}),
	New("Folder", {
		Name = "Popups",
	}),
	New("Folder", {
		Name = "ToolTips",
	}),
})

PainKillersUI.NotificationGui = New("ScreenGui", {
	Name = "PainKillersUI/Notifications",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
PainKillersUI.DropdownGui = New("ScreenGui", {
	Name = "PainKillersUI/Dropdowns",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
PainKillersUI.TooltipGui = New("ScreenGui", {
	Name = "PainKillersUI/Tooltips",
	Parent = GUIParent,
	IgnoreGuiInset = true,
})
ProtectGui(PainKillersUI.ScreenGui)
ProtectGui(PainKillersUI.NotificationGui)
ProtectGui(PainKillersUI.DropdownGui)
ProtectGui(PainKillersUI.TooltipGui)

Creator.Init(PainKillersUI)

function PainKillersUI:SetParent(parent)
	if PainKillersUI.ScreenGui then
		PainKillersUI.ScreenGui.Parent = parent
	end
	if PainKillersUI.NotificationGui then
		PainKillersUI.NotificationGui.Parent = parent
	end
	if PainKillersUI.DropdownGui then
		PainKillersUI.DropdownGui.Parent = parent
	end
	if PainKillersUI.TooltipGui then
		PainKillersUI.TooltipGui.Parent = parent
	end
end
math.clamp(PainKillersUI.TransparencyValue, 0, 1)

local Holder = PainKillersUI.NotificationModule.Init(PainKillersUI.NotificationGui)

function PainKillersUI:Notify(Config)
	Config.Holder = Holder.Frame
	Config.Window = PainKillersUI.Window
	--Config.PainKillersUI = PainKillersUI
	return PainKillersUI.NotificationModule.New(Config)
end

function PainKillersUI:SetNotificationLower(Val)
	Holder.SetLower(Val)
end

function PainKillersUI:SetFont(FontId)
	Creator.UpdateFont(FontId)
end

function PainKillersUI:OnThemeChange(func)
	PainKillersUI.OnThemeChangeFunction = func
end

function PainKillersUI:AddTheme(LTheme)
	PainKillersUI.Themes[LTheme.Name] = LTheme
	return LTheme
end

function PainKillersUI:SetTheme(Value)
	if PainKillersUI.Themes[Value] then
		PainKillersUI.Theme = PainKillersUI.Themes[Value]
		Creator.SetTheme(PainKillersUI.Themes[Value])

		if PainKillersUI.OnThemeChangeFunction then
			PainKillersUI.OnThemeChangeFunction(Value)
		end

		return PainKillersUI.Themes[Value]
	end
	return nil
end

function PainKillersUI:GetThemes()
	return PainKillersUI.Themes
end
function PainKillersUI:GetCurrentTheme()
	return PainKillersUI.Theme.Name
end
function PainKillersUI:GetTransparency()
	return PainKillersUI.Transparent or false
end
function PainKillersUI:GetWindowSize()
	return PainKillersUI.Window.UIElements.Main.Size
end
function PainKillersUI:Localization(LocalizationConfig)
	return PainKillersUI.LocalizationModule:New(LocalizationConfig, Creator)
end

function PainKillersUI:SetLanguage(Value)
	if Creator.Localization then
		return Creator.SetLanguage(Value)
	end
	return false
end

function PainKillersUI:ToggleAcrylic(Value)
	if PainKillersUI.Window and PainKillersUI.Window.AcrylicPaint and PainKillersUI.Window.AcrylicPaint.Model then
		PainKillersUI.Window.Acrylic = Value
		PainKillersUI.Window.AcrylicPaint.Model.Transparency = Value and 0.98 or 1
		if Value then
			Acrylic.Enable()
		else
			Acrylic.Disable()
		end
	end
end

function PainKillersUI:Gradient(stops, props)
	local colorSequence = {}
	local transparencySequence = {}

	for posStr, stop in next, stops do
		local position = tonumber(posStr)
		if position then
			position = math.clamp(position / 100, 0, 1)

			local color = stop.Color
			if typeof(color) == "string" and string.sub(color, 1, 1) == "#" then
				color = Color3.fromHex(color)
			end

			local transparency = stop.Transparency or 0

			table.insert(colorSequence, ColorSequenceKeypoint.new(position, color))
			table.insert(transparencySequence, NumberSequenceKeypoint.new(position, transparency))
		end
	end

	table.sort(colorSequence, function(a, b)
		return a.Time < b.Time
	end)
	table.sort(transparencySequence, function(a, b)
		return a.Time < b.Time
	end)

	if #colorSequence < 2 then
		table.insert(colorSequence, ColorSequenceKeypoint.new(1, colorSequence[1].Value))
		table.insert(transparencySequence, NumberSequenceKeypoint.new(1, transparencySequence[1].Value))
	end

	local gradientData = {
		Color = ColorSequence.new(colorSequence),
		Transparency = NumberSequence.new(transparencySequence),
	}

	if props then
		for k, v in pairs(props) do
			gradientData[k] = v
		end
	end

	return gradientData
end

function PainKillersUI:Popup(PopupConfig)
	PopupConfig.PainKillersUI = PainKillersUI
	return require("./components/popup/Init").new(PopupConfig, PainKillersUI.ScreenGui.Popups)
end

PainKillersUI.Themes = require("./themes/Init")(PainKillersUI, Creator)

Creator.Themes = PainKillersUI.Themes

PainKillersUI:SetTheme("Dark")
PainKillersUI:SetLanguage(Creator.Language)

function PainKillersUI:CreateWindow(Config)
	local CreateWindow = require("./components/window/Init")

	if not RunService:IsStudio() and writefile then
		if not isfolder("PainKillersUI") then
			makefolder("PainKillersUI")
		end
		if Config.Folder then
			makefolder(Config.Folder)
		else
			makefolder(Config.Title)
		end
	end

	Config.PainKillersUI = PainKillersUI
	Config.Window = PainKillersUI.Window
	Config.Parent = PainKillersUI.ScreenGui.Window

	if PainKillersUI.Window then
		warn("You cannot create more than one window")
		return
	end

	local CanLoadWindow = true

	local Theme = PainKillersUI.Themes[Config.Theme or "Dark"]

	--PainKillersUI.Theme = Theme
	Creator.SetTheme(Theme)

	local hwid = gethwid or function()
		return Players.LocalPlayer.UserId
	end

	local Filename = hwid()

	if Config.KeySystem then
		CanLoadWindow = false

		local function loadKeysystem()
			KeySystem.new(Config, Filename, function(c)
				CanLoadWindow = c
			end)
		end

		local keyPath = (Config.Folder or "Temp") .. "/" .. Filename .. ".key"

		if Config.KeySystem.KeyValidator then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isValid = Config.KeySystem.KeyValidator(savedKey)

				if isValid then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		elseif not Config.KeySystem.API then
			if Config.KeySystem.SaveKey and isfile(keyPath) then
				local savedKey = readfile(keyPath)
				local isKey = (type(Config.KeySystem.Key) == "table") and table.find(Config.KeySystem.Key, savedKey)
					or tostring(Config.KeySystem.Key) == tostring(savedKey)

				if isKey then
					CanLoadWindow = true
				else
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		else
			if isfile(keyPath) then
				local fileKey = readfile(keyPath)
				local isSuccess = false

				for _, i in next, Config.KeySystem.API do
					local serviceData = PainKillersUI.Services[i.Type]
					if serviceData then
						local args = {}
						for _, argName in next, serviceData.Args do
							table.insert(args, i[argName])
						end

						local service = serviceData.New(table.unpack(args))
						local success = service.Verify(fileKey)
						if success then
							isSuccess = true
							break
						end
					end
				end

				CanLoadWindow = isSuccess
				if not isSuccess then
					loadKeysystem()
				end
			else
				loadKeysystem()
			end
		end

		repeat
			task.wait()
		until CanLoadWindow
	end

	local Window = CreateWindow(Config)

	PainKillersUI.Transparent = Config.Transparent
	PainKillersUI.Window = Window

	if Config.Acrylic then
		Acrylic.init()
	end

	-- function Window:ToggleTransparency(Value)
	--     PainKillersUI.Transparent = Value
	--     PainKillersUI.Window.Transparent = Value

	--     Window.UIElements.Main.Background.BackgroundTransparency = Value and PainKillersUI.TransparencyValue or 0
	--     Window.UIElements.Main.Background.ImageLabel.ImageTransparency = Value and PainKillersUI.TransparencyValue or 0
	--     Window.UIElements.Main.Gradient.UIGradient.Transparency = NumberSequence.new{
	--         NumberSequenceKeypoint.new(0, 1),
	--         NumberSequenceKeypoint.new(1, Value and 0.85 or 0.7),
	--     }
	-- end

	return Window
end

return PainKillersUI
