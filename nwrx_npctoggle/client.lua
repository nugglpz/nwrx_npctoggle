-- client.lua

local npcEnabled = true
local clearNeeded = false

RegisterCommand('npc', function(source, args, rawCommand)
    local action = args[1] and string.lower(args[1]) or 'toggle'
    
    if action == 'on' then
        npcEnabled = true
        TriggerEvent('chat:addMessage', { args = {'NPCs enabled.'} })
    elseif action == 'off' then
        npcEnabled = false
        clearNeeded = true  -- Flag to clear existing NPCs once
        TriggerEvent('chat:addMessage', { args = {'NPCs disabled.'} })
    else
        npcEnabled = not npcEnabled
        if not npcEnabled then
            clearNeeded = true
        end
        TriggerEvent('chat:addMessage', { args = {'NPCs ' .. (npcEnabled and 'enabled' or 'disabled') .. '.'} })
    end
end, false)

Citizen.CreateThread(function()
    while true do
        if not npcEnabled then
            SetPedDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
            SetVehicleDensityMultiplierThisFrame(0.0)
            
            if clearNeeded then
                clearNeeded = false
                -- Clear existing peds
                local peds = GetGamePool('CPed')
                for _, ped in ipairs(peds) do
                    if not IsPedAPlayer(ped) then
                        DeleteEntity(ped)
                    end
                end
                -- Clear vehicles not occupied by players
                local vehicles = GetGamePool('CVehicle')
                for _, vehicle in ipairs(vehicles) do
                    local delete = true
                    for seat = -1, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
                        local ped = GetPedInVehicleSeat(vehicle, seat)
                        if ped ~= 0 and IsPedAPlayer(ped) then
                            delete = false
                            break
                        end
                    end
                    if delete then
                        DeleteEntity(vehicle)
                    end
                end
            end
        end
        
        Citizen.Wait(0)
    end
end)