local txd = GetCurrentResourceName() .. "dui_testing"
local dui
local drawing = false
RegisterCommand("opendui", function(src, args)
    if drawing then return print("^1You must first close the current dui window with /closedui") end

    drawing = true
    if args and args[1] then
        local url = args[1]

        local duiWidth, duiHeight = GetActiveScreenResolution()
        if args[2] and args[3] and tonumber(args[2]) and tonumber(args[3]) then
            duiWidth = tonumber(args[2])
            duiHeight = tonumber(args[3])
        end

        local screenWidth, screenHeight = GetActiveScreenResolution()

        dui = CreateDui(url, duiWidth, duiHeight)
        local duiHandle = GetDuiHandle(dui)
        CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(txd), txd, duiHandle)

        local xPixel, yPixel = 1/screenWidth, 1/screenHeight
        while drawing do
            Wait(0)

            DisableAllControlActions(0)
            DisableAllControlActions(1)
            DisableAllControlActions(2)
            
            DrawSprite(txd, txd, 0.5, 0.5, 1.0, 1.0, 0.0, 255, 255, 255, 255)

            -- CURSOR
            local cursorX, cursorY = GetDisabledControlNormal(0, 239), GetDisabledControlNormal(0, 240)
            -- black outline
            DrawRect(cursorX, cursorY, xPixel * 3, yPixel * 17, 0, 0, 0, 255)
            DrawRect(cursorX, cursorY, xPixel * 17, yPixel * 3, 0, 0, 0, 255)
            -- white inside
            DrawRect(cursorX, cursorY, xPixel, yPixel * 15, 255, 255, 255, 255)
            DrawRect(cursorX, cursorY, xPixel * 15, yPixel, 255, 255, 255, 255)
            -- get dui cursor position
            local duiX, duiY = math.floor(cursorX * duiWidth + 0.5), math.floor(cursorY * duiHeight + 0.5)
            
            BeginTextCommandDisplayText("STRING")
            AddTextComponentSubstringPlayerName(string.format("(%s, %s)", duiX, duiY))
            SetTextFont(4)
            SetTextOutline()
            SetTextScale(0.3, 0.3)
            if cursorX > 0.5 then
                SetTextWrap(0.0, cursorX)
                SetTextJustification(2)
            end
            if cursorY > 0.5 then
                EndTextCommandDisplayText(cursorX, cursorY - (GetRenderedCharacterHeight(0.3, 4) + yPixel * 8))
            else
                EndTextCommandDisplayText(cursorX, cursorY)
            end
            EndTextCommandDisplayText(cursorX, cursorY)

            -- UPDATE DUI
            SendDuiMouseMove(dui, duiX, duiY)
            if IsDisabledControlJustPressed(0, 24) then
                print("LMB Down")
                SendDuiMouseDown(dui, "left")
            end
            if IsDisabledControlJustReleased(0, 24) then
                print("LMB Up")
                SendDuiMouseUp(dui, "left")
            end
        end

        DestroyDui(dui)
        dui = nil
    end
end)

RegisterCommand("closedui", function()
    drawing = false
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        if dui then
            DestroyDui(dui)
        end
    end
end)