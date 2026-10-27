local OpenButton = {}

local Creator = require("../../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local cloneref = (cloneref or clonereference or function(instance) return instance end)
local UserInputService = cloneref(game:GetService("UserInputService"))
local RunService = cloneref(game:GetService("RunService"))

-- Определяем мобильное устройство
local function IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

function OpenButton.New(Window)
	local OpenButtonMain = {
		Button = nil,
	}

	local Icon
	local PulseConnection

	-- Определяем позицию по умолчанию (снизу по центру для мобильных, снизу справа для ПК)
	local defaultPos = IsMobile()
		and UDim2.new(0.5, 0, 1, -(44 / 2 + 16))
		or UDim2.new(0.5, 0, 1, -(44 / 2 + 16))

	local Title = New("TextLabel", {
		Text = Window.Title,
		TextSize = 14,
		FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		BackgroundTransparency = 1,
		AutomaticSize = "XY",
		ThemeTag = { TextColor3 = "Text" },
	})

	local DragIconData = Creator.Icon("move")
	local Drag = New("Frame", {
		Size = UDim2.new(0, 36, 0, 36),
		BackgroundTransparency = 1,
		Name = "Drag",
	}, {
		New("ImageLabel", {
			Image = DragIconData and DragIconData[1],
			ImageRectOffset = DragIconData and DragIconData[2] and DragIconData[2].ImageRectPosition,
			ImageRectSize = DragIconData and DragIconData[2] and DragIconData[2].ImageRectSize,
			Size = UDim2.new(0, 16, 0, 16),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ThemeTag = { ImageColor3 = "Icon" },
			ImageTransparency = 0.4,
		}),
	})

	local Divider = New("Frame", {
		Size = UDim2.new(0, 1, 0.6, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.85,
		BorderSizePixel = 0,
	})

	-- Пульс-круг (анимированный)
	local PulseRing = New("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		ZIndex = -1,
	}, {
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		New("UIStroke", {
			Thickness = 2,
			Transparency = 1,
		}, {
			New("UIGradient", {
				Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
			}),
		}),
	})

	local UIScale = New("UIScale", { Scale = 0.85 })

	local Container = New("Frame", {
		Size = UDim2.new(0, 0, 0, 0),
		Position = defaultPos,
		AnchorPoint = Vector2.new(0.5, 1),
		Parent = Window.Parent,
		BackgroundTransparency = 1,
		Active = true,
		Visible = false,
		ZIndex = 100,
	})

	local Button = New("Frame", {
		Size = UDim2.new(0, 0, 0, 44),
		AutomaticSize = "X",
		Parent = Container,
		Active = false,
		BackgroundTransparency = 0.2,
		ZIndex = 99,
		BackgroundColor3 = Color3.new(0, 0, 0),
	}, {
		UIScale,
		PulseRing,
		New("UICorner", { CornerRadius = UDim.new(1, 0) }),
		New("UIStroke", {
			Thickness = 1.5,
			ApplyStrokeMode = "Border",
			Transparency = 0,
		}, {
			New("UIGradient", {
				Color = ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
			}),
		}),
		Drag,
		Divider,
		New("UIListLayout", {
			Padding = UDim.new(0, 4),
			FillDirection = "Horizontal",
			VerticalAlignment = "Center",
		}),
		New("TextButton", {
			AutomaticSize = "XY",
			Active = true,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 44 - 8),
			BackgroundColor3 = Color3.new(1, 1, 1),
			Name = "TextButton",
		}, {
			New("UICorner", { CornerRadius = UDim.new(1, -4) }),
			Icon,
			New("UIListLayout", {
				Padding = UDim.new(0, Window.UIPadding),
				FillDirection = "Horizontal",
				VerticalAlignment = "Center",
			}),
			Title,
			New("UIPadding", {
				PaddingLeft = UDim.new(0, 11),
				PaddingRight = UDim.new(0, 11),
			}),
		}),
		New("UIPadding", {
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4),
		}),
	})

	OpenButtonMain.Button = Button

	-- Обновляем размер контейнера под кнопку
	Creator.AddSignal(Button:GetPropertyChangedSignal("AbsoluteSize"), function()
		Container.Size = UDim2.new(0, Button.AbsoluteSize.X, 0, Button.AbsoluteSize.Y)
	end)

	-- Hover эффекты
	Creator.AddSignal(Button.TextButton.MouseEnter, function()
		Tween(Button.TextButton, 0.12, { BackgroundTransparency = 0.9 }):Play()
		Tween(UIScale, 0.12, { Scale = 1.05 }):Play()
	end)
	Creator.AddSignal(Button.TextButton.MouseLeave, function()
		Tween(Button.TextButton, 0.12, { BackgroundTransparency = 1 }):Play()
		Tween(UIScale, 0.12, { Scale = 1 }):Play()
	end)

	-- Пульс-анимация (только когда кнопка видима)
	local function StartPulse()
		if PulseConnection then return end
		local pulseRingStroke = PulseRing:FindFirstChildOfClass("UIStroke")
		PulseConnection = task.spawn(function()
			while Container.Visible do
				if pulseRingStroke then
					Tween(PulseRing, 0, { Size = UDim2.new(1, 0, 1, 0) }):Play()
					Tween(pulseRingStroke, 0, { Transparency = 0.3 }):Play()
					Tween(PulseRing, 1.2, { Size = UDim2.new(1, 20, 1, 20) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
					Tween(pulseRingStroke, 1.2, { Transparency = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
				end
				task.wait(2.5)
			end
			PulseConnection = nil
		end)
	end

	local function StopPulse()
		if PulseConnection then
			task.cancel(PulseConnection)
			PulseConnection = nil
		end
	end

	-- Перетаскивание
	local DragModule = Creator.Drag(Container)

	-- Показать / скрыть кнопку
	function OpenButtonMain:Visible(v)
		if v then
			Container.Visible = true
			-- Bounce-анимация появления
			UIScale.Scale = 0.6
			Tween(UIScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
			StartPulse()
		else
			StopPulse()
			Tween(UIScale, 0.2, { Scale = 0.6 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In):Play()
			task.delay(0.2, function()
				Container.Visible = false
				UIScale.Scale = 1
			end)
		end
	end

	function OpenButtonMain:SetScale(scale)
		UIScale.Scale = scale
	end

	function OpenButtonMain:SetIcon(newIcon)
		if Icon then
			Icon:Destroy()
		end
		if newIcon then
			Icon = Creator.Image(
				newIcon,
				Window.Title,
				0,
				Window.Folder,
				"OpenButton",
				true,
				Window.IconThemed
			)
			if Icon then
				Icon.Size = UDim2.new(0, 20, 0, 20)
				Icon.LayoutOrder = -1
				Icon.Parent = OpenButtonMain.Button.TextButton
			end
		end
	end

	if Window.Icon then
		OpenButtonMain:SetIcon(Window.Icon)
	end

	function OpenButtonMain:Edit(OpenButtonConfig)
		local cfg = {
			Title = OpenButtonConfig.Title,
			Icon = OpenButtonConfig.Icon,
			Enabled = OpenButtonConfig.Enabled,
			Position = OpenButtonConfig.Position,
			OnlyIcon = OpenButtonConfig.OnlyIcon or false,
			Draggable = OpenButtonConfig.Draggable,
			OnlyMobile = OpenButtonConfig.OnlyMobile,
			CornerRadius = OpenButtonConfig.CornerRadius or UDim.new(1, 0),
			StrokeThickness = OpenButtonConfig.StrokeThickness or 1.5,
			Scale = OpenButtonConfig.Scale or 1,
			Color = OpenButtonConfig.Color
				or ColorSequence.new(Color3.fromHex("40c9ff"), Color3.fromHex("e81cff")),
		}

		if cfg.Enabled == false then
			Window.IsOpenButtonEnabled = false
		end

		if cfg.OnlyMobile ~= false then
			cfg.OnlyMobile = true
		else
			Window.IsPC = false
		end

		if cfg.Draggable == false and Drag and Divider then
			Drag.Visible = false
			Divider.Visible = false
			if DragModule then
				DragModule:Set(false)
			end
		elseif cfg.Draggable == true and Drag and Divider then
			Drag.Visible = true
			Divider.Visible = true
			if DragModule then
				DragModule:Set(true)
			end
		end

		if cfg.Position and Container then
			Container.Position = cfg.Position
		end

		if cfg.OnlyIcon == true and Title then
			Title.Visible = false
			Button.TextButton.UIPadding.PaddingLeft = UDim.new(0, 7)
			Button.TextButton.UIPadding.PaddingRight = UDim.new(0, 7)
		else
			Title.Visible = true
			Button.TextButton.UIPadding.PaddingLeft = UDim.new(0, 11)
			Button.TextButton.UIPadding.PaddingRight = UDim.new(0, 11)
		end

		if Title and cfg.Title then
			Title.Text = cfg.Title
			Creator:ChangeTranslationKey(Title, cfg.Title)
		end

		if cfg.Icon then
			OpenButtonMain:SetIcon(cfg.Icon)
		end

		local stroke = Button:FindFirstChildOfClass("UIStroke")
		if stroke then
			local grad = stroke:FindFirstChildOfClass("UIGradient")
			if grad then grad.Color = cfg.Color end
			stroke.Thickness = cfg.StrokeThickness
		end

		local pulseStroke = PulseRing:FindFirstChildOfClass("UIStroke")
		if pulseStroke then
			local grad = pulseStroke:FindFirstChildOfClass("UIGradient")
			if grad then grad.Color = cfg.Color end
		end

		local corner = Button:FindFirstChildOfClass("UICorner")
		if corner then corner.CornerRadius = cfg.CornerRadius end

		OpenButtonMain:SetScale(cfg.Scale)
	end

	return OpenButtonMain
end

return OpenButton
