local Creator = require("../modules/Creator")
local New = Creator.New
local Tween = Creator.Tween

local NotificationModule = {
	Size = UDim2.new(0, 320, 1, -100 - 56),
	SizeLower = UDim2.new(0, 320, 1, -56),
	UICorner = 16,
	UIPadding = 14,
	Holder = nil,
	NotificationIndex = 0,
	Notifications = {},
}

-- Цвета и иконки для каждого типа уведомлений
local TypeConfig = {
	default = {
		Color = Color3.fromHex("#6366f1"),
		Icon = "bell",
	},
	success = {
		Color = Color3.fromHex("#22c55e"),
		Icon = "check-circle",
	},
	error = {
		Color = Color3.fromHex("#ef4444"),
		Icon = "x-circle",
	},
	warning = {
		Color = Color3.fromHex("#f59e0b"),
		Icon = "alert-triangle",
	},
	info = {
		Color = Color3.fromHex("#0ea5e9"),
		Icon = "info",
	},
}

function NotificationModule.Init(Parent)
	local NotModule = {
		Lower = false,
	}

	function NotModule.SetLower(val)
		NotModule.Lower = val
		NotModule.Frame.Size = val and NotificationModule.SizeLower or NotificationModule.Size
	end

	NotModule.Frame = New("Frame", {
		Position = UDim2.new(1, -116 / 4, 0, 56),
		AnchorPoint = Vector2.new(1, 0),
		Size = NotificationModule.Size,
		Parent = Parent,
		BackgroundTransparency = 1,
	}, {
		New("UIListLayout", {
			HorizontalAlignment = "Center",
			SortOrder = "LayoutOrder",
			VerticalAlignment = "Bottom",
			Padding = UDim.new(0, 8),
		}),
		New("UIPadding", {
			PaddingBottom = UDim.new(0, 116 / 4),
			PaddingRight = UDim.new(0, 4),
		}),
	})
	return NotModule
end

function NotificationModule.New(Config)
	local notifType = Config.Type or "default"
	local typeData = TypeConfig[notifType] or TypeConfig.default
	local accentColor = Config.AccentColor or typeData.Color

	local Notification = {
		Title = Config.Title or "Notification",
		Content = Config.Content or nil,
		Icon = Config.Icon or typeData.Icon,
		IconThemed = Config.IconThemed,
		Background = Config.Background,
		BackgroundImageTransparency = Config.BackgroundImageTransparency,
		Duration = Config.Duration or 5,
		Buttons = Config.Buttons or {},
		CanClose = Config.CanClose ~= false,
		UIElements = {},
		Closed = false,
		Type = notifType,
	}

	NotificationModule.NotificationIndex = NotificationModule.NotificationIndex + 1
	NotificationModule.Notifications[NotificationModule.NotificationIndex] = Notification

	-- Иконка уведомления
	local Icon
	local iconKey = Notification.Icon
	if iconKey then
		Icon = Creator.Image(
			iconKey,
			(Notification.Title or "") .. ":" .. tostring(iconKey),
			0,
			Config.Window,
			"Notification",
			Notification.IconThemed
		)
		if Icon then
			Icon.Size = UDim2.new(0, 22, 0, 22)
			Icon.Position = UDim2.new(
				0,
				NotificationModule.UIPadding + 4,
				0,
				NotificationModule.UIPadding + 2
			)
			if not Notification.IconThemed then
				Icon.ImageColor3 = accentColor
			end
		end
	end

	-- Кнопка закрытия
	local CloseButton
	if Notification.CanClose then
		local CloseIconData = Creator.Icon("x")
		CloseButton = New("ImageButton", {
			Image = CloseIconData and CloseIconData[1],
			ImageRectSize = CloseIconData and CloseIconData[2] and CloseIconData[2].ImageRectSize,
			ImageRectOffset = CloseIconData and CloseIconData[2] and CloseIconData[2].ImageRectPosition,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(1, -NotificationModule.UIPadding, 0, NotificationModule.UIPadding),
			AnchorPoint = Vector2.new(1, 0),
			ThemeTag = {
				ImageColor3 = "Text",
			},
			ImageTransparency = 0.5,
		}, {
			New("TextButton", {
				Size = UDim2.new(1, 16, 1, 16),
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Text = "",
			}),
		})
	end

	-- Полоса прогресса (таймер)
	local DurationBar = New("Frame", {
		Size = UDim2.new(1, 0, 0, 2),
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = accentColor,
		BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})

	-- Акцентная полоса слева
	local AccentBar = New("Frame", {
		Size = UDim2.new(0, 3, 1, -8),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = accentColor,
		BorderSizePixel = 0,
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(1, 0),
		}),
	})

	-- Блок с текстом
	local iconOffset = iconKey and (22 + NotificationModule.UIPadding) or 0
	local TextContainer = New("Frame", {
		Size = UDim2.new(1, -(NotificationModule.UIPadding * 2 + 20 + iconOffset), 1, 0),
		Position = UDim2.new(0, NotificationModule.UIPadding + 6 + iconOffset, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = "Y",
	}, {
		New("UIPadding", {
			PaddingTop = UDim.new(0, NotificationModule.UIPadding - 1),
			PaddingBottom = UDim.new(0, NotificationModule.UIPadding - 1),
		}),
		New("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, 0, 0, 0),
			TextWrapped = true,
			TextXAlignment = "Left",
			RichText = true,
			BackgroundTransparency = 1,
			TextSize = 14,
			ThemeTag = {
				TextColor3 = "NotificationTitle",
				TextTransparency = "NotificationTitleTransparency",
			},
			Text = Notification.Title,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
		}),
		New("UIListLayout", {
			Padding = UDim.new(0, 4),
		}),
	})

	if Notification.Content then
		New("TextLabel", {
			AutomaticSize = "Y",
			Size = UDim2.new(1, 0, 0, 0),
			TextWrapped = true,
			TextXAlignment = "Left",
			RichText = true,
			BackgroundTransparency = 1,
			TextSize = 13,
			ThemeTag = {
				TextColor3 = "NotificationContent",
				TextTransparency = "NotificationContentTransparency",
			},
			Text = Notification.Content,
			FontFace = Font.new(Creator.Font, Enum.FontWeight.Medium),
			Parent = TextContainer,
		})
	end

	-- Кнопки действий
	if Notification.Buttons and #Notification.Buttons > 0 then
		local ButtonsFrame = New("Frame", {
			AutomaticSize = "XY",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			Parent = TextContainer,
		}, {
			New("UIListLayout", {
				FillDirection = "Horizontal",
				Padding = UDim.new(0, 6),
			}),
		})

		for _, btnConfig in ipairs(Notification.Buttons) do
			New("TextButton", {
				AutomaticSize = "XY",
				BackgroundColor3 = btnConfig.Primary and accentColor or Color3.fromHex("#2a2a2a"),
				BackgroundTransparency = btnConfig.Primary and 0 or 0.5,
				Text = btnConfig.Title or "Button",
				TextSize = 12,
				FontFace = Font.new(Creator.Font, Enum.FontWeight.SemiBold),
				TextColor3 = Color3.fromHex("#ffffff"),
				BorderSizePixel = 0,
				Parent = ButtonsFrame,
			}, {
				New("UICorner", { CornerRadius = UDim.new(0, 8) }),
				New("UIPadding", {
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 5),
					PaddingBottom = UDim.new(0, 5),
				}),
			}).MouseButton1Click:Connect(function()
				if btnConfig.Callback then
					btnConfig.Callback()
				end
				if btnConfig.CloseOnClick ~= false then
					Notification:Close()
				end
			end)
		end
	end

	-- Фоновое изображение (если есть)
	local BGFrame
	if Notification.Background then
		BGFrame = New("ImageLabel", {
			Name = "Background",
			Image = Notification.Background,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ScaleType = "Crop",
			ImageTransparency = Notification.BackgroundImageTransparency or 0.3,
		}, {
			New("UICorner", {
				CornerRadius = UDim.new(0, NotificationModule.UICorner),
			}),
		})
	end

	-- Главный фрейм уведомления
	local Main = Creator.NewRoundFrame(NotificationModule.UICorner, "Squircle", {
		Size = UDim2.new(1, 0, 0, 0),
		Position = UDim2.new(1, 20, 1, 0), -- начинает справа (за экраном)
		AnchorPoint = Vector2.new(0, 1),
		AutomaticSize = "Y",
		ImageTransparency = 0.04,
		ThemeTag = {
			ImageColor3 = "Notification",
		},
	}, {
		Creator.NewRoundFrame(NotificationModule.UICorner, "Squircle", {
			Size = UDim2.new(1, 0, 1, 0),
			ThemeTag = {
				ImageColor3 = "Notification2",
				ImageTransparency = "Notification2Transparency",
			},
		}),
		-- Полоска снизу (таймер)
		New("Frame", {
			Size = UDim2.new(1, 0, 0, 2),
			Position = UDim2.new(0, 0, 1, -2),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Name = "DurationFrame",
		}, {
			DurationBar,
		}),
		BGFrame,
		AccentBar,
		TextContainer,
		Icon,
		CloseButton,
	})

	local MainContainer = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = Config.Holder,
	}, {
		Main,
	})

	-- Закрытие уведомления
	function Notification:Close()
		if not Notification.Closed then
			Notification.Closed = true
			Tween(MainContainer, 0.35, { Size = UDim2.new(1, 0, 0, -6) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
			Tween(Main, 0.4, { Position = UDim2.new(1, 20, 1, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
			task.wait(0.35)
			MainContainer:Destroy()
		end
	end

	-- Анимация появления
	task.spawn(function()
		task.wait()
		local targetHeight = Main.AbsoluteSize.Y
		Tween(MainContainer, 0.4, { Size = UDim2.new(1, 0, 0, targetHeight) }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
		-- Слайд слева (красиво выезжает)
		Tween(Main, 0.45, { Position = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()

		if Notification.Duration then
			task.wait(0.45)
			-- Анимация таймера
			Tween(DurationBar, Notification.Duration - 0.45, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear):Play()
			task.wait(Notification.Duration - 0.45)
			Notification:Close()
		end
	end)

	-- Hover эффект на кнопке закрытия
	if CloseButton then
		CloseButton.MouseEnter:Connect(function()
			Tween(CloseButton, 0.1, { ImageTransparency = 0 }):Play()
		end)
		CloseButton.MouseLeave:Connect(function()
			Tween(CloseButton, 0.1, { ImageTransparency = 0.5 }):Play()
		end)
		Creator.AddSignal(CloseButton.TextButton.MouseButton1Click, function()
			Notification:Close()
		end)
	end

	return Notification
end

return NotificationModule
