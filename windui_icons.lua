-- Módulo de ícones da WindUI ENXUTO pro Ln HUB (2026-11-08).
-- O original (github.com/Footagesus/Icons Main-v2.lua) baixa 6 pacotes de ícones do GitHub TODA vez que a
-- WindUI carrega (lucide, solar, craft, geist, sfsymbols, gravity) = 7 downloads por partida no celular.
-- Aqui só o lucide, lido da cópia local que o script passa em getgenv().LN_WIND_LUCIDE (aot_windui_lucide.lua).
-- Mesma interface do original (Icons, SetIconsType, Init, Icon, GetIcon, Icon2, Image, AddIcons).

local function emptyPack() return { Icons = {}, Spritesheets = {} } end
local lucide = {}
pcall(function()
	local src = getgenv().LN_WIND_LUCIDE
	local fn = src and loadstring(src)
	local t = fn and fn()
	if type(t) == "table" then lucide = t end
end)

local IconModule = {
	IconsType = "lucide",
	New = nil,
	IconThemeTag = nil,
	Icons = {
		lucide = lucide,
		solar = emptyPack(),
		craft = emptyPack(),
		geist = emptyPack(),
		sfsymbols = emptyPack(),
		gravity = emptyPack(),
	},
}

local function parseIconString(iconString)
	if type(iconString) == "string" then
		local splitIndex = iconString:find(":")
		if splitIndex and not iconString:find("^rbxassetid") then
			return iconString:sub(1, splitIndex - 1), iconString:sub(splitIndex + 1)
		end
	end
	return nil, iconString
end

function IconModule.AddIcons(packName, iconsData)
	if type(packName) ~= "string" or type(iconsData) ~= "table" then return end
	if not IconModule.Icons[packName] then IconModule.Icons[packName] = emptyPack() end
	local pack = IconModule.Icons[packName]
	pack.Icons = pack.Icons or {}
	pack.Spritesheets = pack.Spritesheets or {}
	for iconName, iconValue in pairs(iconsData) do
		if type(iconValue) == "number" or (type(iconValue) == "string" and iconValue:match("^rbxassetid://")) then
			local imageId = type(iconValue) == "number" and ("rbxassetid://" .. tostring(iconValue)) or iconValue
			pack.Icons[iconName] = { Image = imageId, ImageRectSize = Vector2.new(0, 0), ImageRectPosition = Vector2.new(0, 0) }
			pack.Spritesheets[imageId] = imageId
		elseif type(iconValue) == "table" and iconValue.Image and iconValue.ImageRectSize and iconValue.ImageRectPosition then
			local imageId = type(iconValue.Image) == "number" and ("rbxassetid://" .. tostring(iconValue.Image)) or iconValue.Image
			pack.Icons[iconName] = { Image = imageId, ImageRectSize = iconValue.ImageRectSize, ImageRectPosition = iconValue.ImageRectPosition, Parts = iconValue.Parts }
			pack.Spritesheets[imageId] = pack.Spritesheets[imageId] or imageId
		end
	end
end

function IconModule.SetIconsType(iconType) IconModule.IconsType = iconType end

function IconModule.Init(New, IconThemeTag)
	IconModule.New = New
	IconModule.IconThemeTag = IconThemeTag
	return IconModule
end

function IconModule.Icon(Icon, Type, DefaultFormat)
	DefaultFormat = DefaultFormat ~= false
	local iconType, iconName = parseIconString(Icon)
	local iconSet = IconModule.Icons[iconType or Type or IconModule.IconsType]
	if iconSet and iconSet.Icons and iconSet.Icons[iconName] then
		return { iconSet.Spritesheets[tostring(iconSet.Icons[iconName].Image)], iconSet.Icons[iconName] }
	elseif iconSet and type(iconSet[iconName]) == "string" and string.find(iconSet[iconName], "rbxassetid://") then
		return DefaultFormat and { iconSet[iconName], { ImageRectSize = Vector2.new(0, 0), ImageRectPosition = Vector2.new(0, 0) } } or iconSet[iconName]
	end
	return nil
end
function IconModule.GetIcon(Icon, Type) return IconModule.Icon(Icon, Type, false) end
function IconModule.Icon2(Icon, Type) return IconModule.Icon(Icon, Type, true) end

function IconModule.Image(IconConfig)
	local Icon = {
		Icon = IconConfig.Icon or nil,
		Type = IconConfig.Type,
		Colors = IconConfig.Colors or { (IconModule.IconThemeTag or Color3.new(1, 1, 1)), Color3.new(1, 1, 1) },
		Size = IconConfig.Size or UDim2.new(0, 24, 0, 24),
		IconFrame = nil,
	}
	local Colors = {}
	for i, color in next, Icon.Colors do
		Colors[i] = { ThemeTag = typeof(color) == "string" and color, Color = typeof(color) == "Color3" and color }
	end
	-- ícone que não existe (pacote não incluído): imagem vazia em vez de erro
	local IconLabel = IconModule.Icon2(Icon.Icon, Icon.Type) or { "", { ImageRectSize = Vector2.new(0, 0), ImageRectPosition = Vector2.new(0, 0) } }
	local isrbx = typeof(IconLabel) == "string" and string.find(IconLabel, "rbxassetid://")
	local frame
	if IconModule.New then
		frame = IconModule.New("ImageLabel", {
			Size = Icon.Size,
			BackgroundTransparency = 1,
			ImageColor3 = Colors[1].Color or nil,
			ThemeTag = Colors[1].ThemeTag and { ImageColor3 = Colors[1].ThemeTag },
			Image = isrbx and IconLabel or IconLabel[1],
			ImageRectSize = isrbx and nil or IconLabel[2].ImageRectSize,
			ImageRectOffset = isrbx and nil or IconLabel[2].ImageRectPosition,
		})
	else
		frame = Instance.new("ImageLabel")
		frame.Size = Icon.Size
		frame.BackgroundTransparency = 1
		frame.ImageColor3 = Colors[1].Color or Color3.new(1, 1, 1)
		frame.Image = isrbx and IconLabel or IconLabel[1]
	end
	Icon.IconFrame = frame
	return Icon
end

return IconModule
