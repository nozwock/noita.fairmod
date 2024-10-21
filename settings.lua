dofile_once("data/scripts/lib/mod_settings.lua")

local mod_id = "noita.fairmod"
local prfx = mod_id .. "."

local function PatchGamesInitlua()
	local file = "data/scripts/init.lua"
	local patch = "mods/noita.fairmod/files/content/biome_mods/biome_modifiers_patch.lua"
	local file_appends = ModLuaFileGetAppends(file)

	for _, append in ipairs(file_appends) do
		if append == patch then return end
	end

	ModLuaFileAppend(file, patch)
end

local function PrintHamis()
	local function head(text)
		return "\27[38;2;82;49;111m" .. text .. "\27[0m"
	end
	local function eye(text)
		return "\27[38;2;199;239;99m" .. text .. "\27[0m"
	end
	local function leg(text)
		return "\27[38;2;45;27;61m" .. text .. "\27[0m"
	end
	local function toe(text)
		return "\27[38;2;102;78;129m" .. text .. "\27[0m"
	end

	print(head("         ######"))
	print(head("         ######"))
	print(head("      ###" .. eye("###") .. head("######")))
	print(head("      ###" .. eye("###") .. head("######")))
	print(head("      #########" .. eye("###")))
	print(head("      #########" .. eye("###")))
	print(leg("   ###") .. head("###") .. eye("###") .. head("######"))
	print(leg("   ###") .. head("###") .. eye("###") .. head("######"))
	print(leg("   ###   ") .. head("######   ") .. leg("###"))
	print(leg("   ###   ") .. head("######   ") .. leg("###"))
	print(leg("###      ###      ###"))
	print(leg("###      ###      ###"))
	print(leg("###      ###      ###"))
	print(leg("###      ###      ###"))
	print(leg("###      ###      ") .. toe("###"))
	print(leg("###      ###      ") .. toe("###"))
	print(toe("###      ###"))
	print(toe("###      ###"))
end

--- gather keycodes from game file
local function gather_key_codes()
	local arr = {}
	arr["0"] = GameTextGetTranslatedOrNot("$menuoptions_configurecontrols_action_unbound")
	local keycodes_all = ModTextFileGetContent("data/scripts/debug/keycodes.lua")
	for line in keycodes_all:gmatch("Key_.-\n") do
		local _, key, code = line:match("(Key_)(.+) = (%d+)")
		arr[code] = key:upper()
	end
	return arr
end
local keycodes = gather_key_codes()

local function pending_input()
	for code, _ in pairs(keycodes) do
		if InputIsKeyJustDown(code) then return code end
	end
end

local function ui_get_input(_, gui, _, im_id, setting)
	local setting_id = prfx .. setting.id
	local current = tostring(ModSettingGetNextValue(setting_id)) or "0"
	local current_key = "[" .. keycodes[current] .. "]"

	if setting.is_waiting_for_input then
		current_key = GameTextGetTranslatedOrNot("$menuoptions_configurecontrols_pressakey")
		local new_key = pending_input()
		if new_key then
			ModSettingSetNextValue(setting_id, new_key, false)
			setting.is_waiting_for_input = false
		end
	end

	GuiOptionsAddForNextWidget(gui, GUI_OPTION.Layout_NextSameLine)
	GuiText(gui, mod_setting_group_x_offset, 0, setting.ui_name)

	GuiLayoutBeginHorizontal(gui, 50, 0, true, 0, 0)
	GuiText(gui, 8, 0, "")
	local _, _, _, x, y = GuiGetPreviousWidgetInfo(gui)
	local w, h = GuiGetTextDimensions(gui, current_key)
	GuiOptionsAddForNextWidget(gui, GUI_OPTION.ForceFocusable)
	GuiImageNinePiece(gui, im_id, x, y, w, h, 0)
	local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
	if hovered then
		GuiTooltip(gui, setting.ui_description, GameTextGetTranslatedOrNot("$menuoptions_reset_keyboard"))
		GuiColorSetForNextWidget(gui, 1, 1, 0.7, 1)
		if InputIsMouseButtonJustDown(1) then setting.is_waiting_for_input = true end
		if InputIsMouseButtonJustDown(2) then
			GamePlaySound("ui", "ui/button_click", 0, 0)
			ModSettingSetNextValue(setting_id, setting.value_default, false)
			setting.is_waiting_for_input = false
		end
	end
	GuiText(gui, 0, 0, current_key)

	GuiLayoutEnd(gui)
end

local function build_settings()
	local settings = {
		{
			category_id = "default_settings",
			ui_name = "",
			ui_description = "",
			settings = {
				{
					id = "colorblind_mode",
					ui_name = "Colorblindness Mode",
					ui_description = "Makes you color blind.",
					value_default = false,
					scope = MOD_SETTING_SCOPE_RUNTIME,
				},
				{
					id = "rebind_pee",
					ui_name = "Piss Button",
					ui_description = "The keybind used to take a piss.",
					value_default = "19",
					ui_fn = ui_get_input,
					is_waiting_for_input = false,
					scope = MOD_SETTING_SCOPE_RUNTIME,
				},
				{
					id = "rebind_poo",
					ui_name = "Shit Button",
					ui_description = "The keybind used to take a shit.",
					value_default = "5",
					ui_fn = ui_get_input,
					is_waiting_for_input = false,
					scope = MOD_SETTING_SCOPE_RUNTIME,
				},
			},
		},
	}
	return settings
end
mod_settings = build_settings()

-- This function is called to ensure the correct setting values are visible to the game. your mod's settings don't work if you don't have a function like this defined in settings.lua.
function ModSettingsUpdate(init_scope)
	mod_settings = build_settings()
	mod_settings_update(mod_id, mod_settings, init_scope)
	if init_scope == 0 or init_scope == 1 then
		PatchGamesInitlua()
		PrintHamis()
	end
end

-- This function should return the number of visible setting UI elements.
-- Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
-- If your mod changes the displayed settings dynamically, you might need to implement custom logic for this function.
function ModSettingsGuiCount()
	return mod_settings_gui_count(mod_id, mod_settings)
end

-- This function is called to display the settings UI for this mod. your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
function ModSettingsGui(gui, in_main_menu)
	mod_settings_gui(mod_id, mod_settings, gui, in_main_menu)
end
