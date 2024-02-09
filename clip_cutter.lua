function descriptor()
    return {
        title = "Clip Cutter",
        version = "1.1",
        author = "dreamcatcher45",
        capabilities = {"menu", "input-listener"}
    }
end

function activate()
    vlc.osd.message("Clip Cutter extension activated", vlc.osd.channel_register(), "center", 2000 * 1000)
end

function deactivate()
    vlc.osd.message("Clip Cutter extension deactivated", vlc.osd.channel_register(), "center", 2000 * 1000)
end

function close()
    deactivate()
end

clip_start=nil
clip_end=nil

function menu()
    return {"Start Point", "End Point", "Save"}
end

function trigger_menu(id)
    if id == 1 then
        start_point()
    elseif id == 2 then
        end_point()
    elseif id == 3 then
        save_clip()

    end
end

function millisecondsToTimestamp(milliseconds)
    local seconds = milliseconds / 1000000
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local seconds = math.floor(seconds % 60)
    local timestamp = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    return timestamp
end

function start_point()
    local input_item = vlc.input.item()
    if input_item then
        local current_time = vlc.var.get(vlc.object.input(), "time")
        local timestamp = millisecondsToTimestamp(current_time)
        clip_start = timestamp
        vlc.osd.message("Start point set", vlc.osd.channel_register(), "center", 2000 * 1000)
    else
        vlc.osd.message("No media found", vlc.osd.channel_register(), "center", 2000 * 1000)
    end
end

function end_point()
    local input_item = vlc.input.item()
    if input_item then
        local current_time = vlc.var.get(vlc.object.input(), "time")
        local timestamp = millisecondsToTimestamp(current_time)
        clip_end = timestamp
        vlc.osd.message("End point set", vlc.osd.channel_register(), "center", 2000 * 1000)
    else
        vlc.osd.message("No media found", vlc.osd.channel_register(), "center", 2000 * 1000)
    end
end

function save_clip()
    local input_item = vlc.input.item()
    if input_item then
        local input_uri = input_item:uri()
        local input_filename = vlc.strings.decode_uri(string.gsub(input_uri, "file:///", ""))
        if clip_start and clip_end and clip_start < clip_end then
            local output_filename = "output_" .. os.time() .. ".mkv"
            local command = 'ffmpeg -i "' .. input_filename .. '" -ss ' .. clip_start .. ' -to ' .. clip_end .. ' -c copy "' .. output_filename .. '"'
            os.execute(command)
            vlc.osd.hide(ret)
            vlc.osd.message("Video saved in current directory", vlc.osd.channel_register(), "center", 2000 * 1000)
        else
            vlc.osd.message("Please set valid start and end points", vlc.osd.channel_register(), "center", 2000 * 1000)
        end
    else
        vlc.osd.message("No media found", vlc.osd.channel_register(), "center", 2000 * 1000)
    end
end
