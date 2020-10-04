------------------------------------------------------------
--                        COMMANDS                        --
------------------------------------------------------------

TriggerEvent('chat:addSuggestion', '/XPM', 'Display your XP stats') 
TriggerEvent('chat:addSuggestion', '/XPM_AddFakePlayer', 'Adds a fake player to the leaderboard') 
TriggerEvent('chat:addSuggestion', '/XPM_SetInitial', 'Sets player initial XP', {
    { name="XP", help="The XP to set" },
}) 
TriggerEvent('chat:addSuggestion', '/XPM_Add', 'Add XP', {
    { name="XP", help="The XP to add" },
}) 
TriggerEvent('chat:addSuggestion', '/XPM_Remove', 'Remove XP', {
    { name="XP", help="The XP to remove" },
}) 

RegisterCommand('XPM', function(source, args)
    Citizen.CreateThread(function()
        local xpToNext = XPM_GetXPToNextRank()

        -- SHOW THE XP BAR
        SendNUIMessage({ xpm_display = true })        

        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", trans('cmd_current_xp', CurrentXP)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", trans('cmd_current_lvl', CurrentRank)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", trans('cmd_next_lvl', xpToNext, CurrentRank + 1)}
        })                
    end)
end)

-- !!!!!! THESE ARE FOR TESTING PURPOSES AND WILL NOT SAVE THE CHANGES IN THE DB !!!!!! --
RegisterCommand('XPM_SetInitial', function(source, args)
    if IsInt(args[1]) then
        CurrentXP = LimitXP(tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = CurrentXP
        })   
    else
        print("XpM: Invalid XP") 
    end       
end)

RegisterCommand('XPM_Add', function(source, args)
    if IsInt(args[1]) then
        CurrentXP = LimitXP(CurrentXP + tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = CurrentXP
        }) 
    else
        print("XpM: Invalid XP") 
    end  
end)

RegisterCommand('XPM_Remove', function(source, args)
    if IsInt(args[1]) then    
        CurrentXP = LimitXP(CurrentXP - tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = CurrentXP
        }) 
    else
        print("XpM: Invalid XP") 
    end     
end)

RegisterCommand('XPM_AddFakePlayer', function(source, args)
    local names = { "Abe", "MasterChief", "Mario", "Sonic", "Knuckles", "MaxPayne", "Mobius1", "Micheal", "Trevor" }
    local name  = names[ math.random( #names ) ] .. math.random(10, 100)
    local rank  = math.random(1, 500)
    local id    = math.random(100, 200)
    local ping  = false

    if Config.Leaderboard.ShowPing then
        ping  = math.random(0, 100)
    end

    Players[id] = {
        name = name,
        id = id,
        ping = ping,
        rank = rank,
        fake = true
    }

    XPM_ShowUI()
end)