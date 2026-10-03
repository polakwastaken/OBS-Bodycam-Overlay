obs = obslua

local source_name = ""
local player = "David Laker | [12-200]"

local function update_text()
    local source = obs.obs_get_source_by_name(source_name)
    if source == nil then return end
    local settings = obs.obs_data_create()
    obs.obs_data_set_string(settings, "text", player .. "\n" .. os.date("%d.%m.%Y | %H:%M:%S"))
    obs.obs_source_update(source, settings)
    obs.obs_data_release(settings)
    obs.obs_source_release(source)
end

function script_description()
    return "Bodycam Overlay: schreibt Name, Datum und Uhrzeit in eine Textquelle."
end

function script_properties()
    local props = obs.obs_properties_create()
    local list = obs.obs_properties_add_list(props, "source", "Textquelle", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    local sources = obs.obs_enum_sources()
    if sources ~= nil then
        for _, s in ipairs(sources) do
            local id = obs.obs_source_get_unversioned_id(s)
            if id == "text_gdiplus" or id == "text_ft2_source" then
                local name = obs.obs_source_get_name(s)
                obs.obs_property_list_add_string(list, name, name)
            end
        end
    end
    obs.source_list_release(sources)
    obs.obs_properties_add_text(props, "player", "Name", obs.OBS_TEXT_DEFAULT)
    return props
end

function script_defaults(settings)
    obs.obs_data_set_default_string(settings, "player", player)
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source")
    player = obs.obs_data_get_string(settings, "player")
    obs.timer_remove(update_text)
    if source_name ~= "" then
        update_text()
        obs.timer_add(update_text, 1000)
    end
end

function script_unload()
    obs.timer_remove(update_text)
end
