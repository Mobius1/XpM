CurrentXP = 0
CurrentRank = 0
Leaderboard = nil
Players = {}
Player = nil
UIActive = true


------------------------------------------------------------
--                         READY                          --
------------------------------------------------------------

TriggerServerEvent("XpM:ready")


------------------------------------------------------------
--                      MAIN EVENTS                       --
------------------------------------------------------------

RegisterNetEvent("XpM:init")
AddEventHandler("XpM:init", function(_xp, _rank, players)

    local Ranks = CheckRanks()

    -- All ranks are valid
    if #Ranks == 0 then
        CurrentXP = tonumber(_xp)
        CurrentRank = tonumber(_rank)

        local data = {
            xpm_init = true,
            xpm_config = Config,
            currentID = GetPlayerServerId(PlayerId()),
            xp = CurrentXP
        }
    
        if Config.Leaderboard.Enabled and players then
            data.players = players
            data.showPing = Config.Leaderboard.ShowPing

            for k, v in pairs(players) do
                if v.current then
                    Player = v
                end
            end        
    
            Players = players                       
        end
    
        -- Update UI
        SendNUIMessage(data)

        -- Native stats
        StatSetInt("MPPLY_GLOBALXP", CurrentXP, 1)
    else
        TriggerEvent("XpM:print", _('err_lvls_check', #Ranks, 'Config.Ranks'))
    end
end)

RegisterNetEvent("XpM:update")
AddEventHandler("XpM:update", function(_xp, _rank)

    local oldRank = CurrentRank
    local newRank = _rank
    local newXP = _xp

    SendNUIMessage({
        xpm_set = true,
        xp = newXP
    })

    CurrentXP = newXP
    CurrentRank = newRank
end)

if Config.Leaderboard.Enabled then
    RegisterNetEvent("XpM:setPlayerData")
    AddEventHandler("XpM:setPlayerData", function(players)

        -- Remove disconnected players
        for i=#Players,1,-1 do
            local active = PlayerIsActive(players, Players[i].id)

            if not Players[i].fake then
                if not active then
                    table.remove(Players, i)
                end
            end
        end

        -- Add new players
        for k, v in pairs(players) do
            local active = PlayerIsActive(Players, v.id)

            if not active then
                table.insert(Players, v)
            else
                Players[active] = v
            end

            if v.current then
                Player = v
            end            
        end

        -- Update leaderboard
        SendNUIMessage({
            xpm_updateleaderboard = true,
            xpm_players = Players
        })
    end)
end

-- Error Printing
RegisterNetEvent("XpM:print")
AddEventHandler("XpM:print", function(message)
    local s = string.rep("=", string.len(message))
    print(s)
    print(message)
    print(s)           
end)

------------------------------------------------------------
--                       FUNCTIONS                        --
------------------------------------------------------------

------------
-- UpdateXP.
--
-- @global
-- @param	int 	_xp 	
-- @param	bool	init	
-- @return	void
function UpdateXP(_xp, init)
    _xp = tonumber(_xp)

    local points = CurrentXP + _xp
    local max = XPM_GetMaxXP()

    if init then
        points = _xp
    end

    points = LimitXP(points)

    local rank = XPM_GetRank(points)

    TriggerServerEvent("XpM:setXP", points, rank)
end


------------
-- XPM_SetInitial.
--
-- @global
-- @param	int 	XPInit	
-- @return	void
function XPM_SetInitial(XPInit)
    local GoalXP = tonumber(XPInit)
    -- Check for valid XP
    if not GoalXP or (GoalXP < 0 or GoalXP > XPM_GetMaxXP()) then
        TriggerEvent("XpM:print", _('err_xp_update', XPInit, "XPM_SetInitial"))
        return
    end    
    UpdateXP(tonumber(GoalXP), true)
end

------------
-- XPM_SetRank.
--
-- @global
-- @param	int	Rank	
-- @return	void
function XPM_SetRank(Rank)
    local GoalRank = tonumber(Rank)

    if not GoalRank then
        TriggerEvent("XpM:print", _('err_lvl_update', Rank, "XPM_SetRank"))
        return
    end

    local XPAdd = tonumber(Config.Ranks[GoalRank]) - CurrentXP

    XPM_Add(XPAdd)
end

------------
-- XPM_Add.
--
-- @global
-- @param	int 	XPAdd	
-- @return	void
function XPM_Add(XPAdd)
    -- Check for valid XP
    if not tonumber(XPAdd) then
        TriggerEvent("XpM:print", _('err_xp_update', XPAdd, "XPM_Add"))
        return
    end       
    UpdateXP(tonumber(XPAdd))
end

------------
-- XPM_Remove.
--
-- @global
-- @param	int 	XPRemove	
-- @return	void
function XPM_Remove(XPRemove)
    -- Check for valid XP
    if not tonumber(XPRemove) then
        TriggerEvent("XpM:print", _('err_xp_update', XPRemove, "XPM_Remove"))
        return
    end       
    UpdateXP(-(tonumber(XPRemove)))
end

------------
-- XPM_GetRank.
--
-- @global
-- @param	int 	_xp	
-- @return	void
function XPM_GetRank(_xp)

    if _xp == nil then
        return CurrentRank
    end

    local len = #Config.Ranks
    for rank = 1, len do
        if rank < len then
            if Config.Ranks[rank + 1] > tonumber(_xp) then
                return rank
            end
        else
            return rank
        end
    end
end	

------------
-- XPM_GetXPToNextRank.
--
-- @global
-- @return	int
function XPM_GetXPToNextRank()
    local currentRank = XPM_GetRank()

    return Config.Ranks[currentRank + 1] - tonumber(CurrentXP)   
end

------------
-- XPM_GetXPToRank.
--
-- @global
-- @param	int 	Rank	
-- @return	int
function XPM_GetXPToRank(Rank)
    local GoalRank = tonumber(Rank)
    -- Check for valid rank
    if not GoalRank or (GoalRank < 1 or GoalRank > #Config.Ranks) then
        TriggerEvent("XpM:print", _('err_lvl_update', Rank, "XPM_GetXPToRank"))
        return
    end

    local goalXP = tonumber(Config.Ranks[GoalRankl])

    return goalXP - CurrentXP
end

------------
-- XPM_GetXP.
--
-- @global
-- @return	int
function XPM_GetXP()
    return tonumber(CurrentXP)
end

------------
-- XPM_GetMaxXP.
--
-- @global
-- @return	int
function XPM_GetMaxXP()
    return Config.Ranks[#Config.Ranks]
end

------------
-- XPM_GetMaxRank.
--
-- @global
-- @return	int
function XPM_GetMaxRank()
    return #Config.Ranks
end

------------
-- XPM_ShowUI.
--
-- @global
-- @return	void
function XPM_ShowUI(update)
    UIActive = true

    if update ~= nil then
        TriggerServerEvent("XpM:getPlayerData")
    end
    
    SendNUIMessage({
        xpm_show = true
    })    
end

------------
-- XPM_HideUI.
--
-- @global
-- @return	void
function XPM_HideUI()
    UIActive = false
        
    SendNUIMessage({
        xpm_hide = true
    })      
end

function XPM_TimeoutUI(update)
    UIActive = true

    if update ~= nil then
        TriggerServerEvent("XpM:getPlayerData")
    end
    
    SendNUIMessage({
        xpm_display = true
    })    
end

function XPM_SortLeaderboard(type)
    SendNUIMessage({
        xpm_lb_sort = true,
        xpm_lb_order = type or "rank"
    })   
end

------------------------------------------------------------
--                        CONTROLS                        --
------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        if IsControlJustReleased(0, Config.UIKey) then
            UIActive = not UIActive
            
            if UIActive then
                TriggerServerEvent("XpM:getPlayerData")
                SendNUIMessage({
                    xpm_show = true
                })                 
            else
                SendNUIMessage({
                    xpm_hide = true
                })                
            end
        elseif IsControlJustPressed(0, 174) then
            if UIActive then
                SendNUIMessage({
                    xpm_lb_prev = true
                })
            end
        elseif IsControlJustPressed(0, 175) then
            if UIActive then
                SendNUIMessage({
                    xpm_lb_next = true
                })
            end
        end

        Citizen.Wait(1)
    end
end)


------------------------------------------------------------
--                         MAIN                          --
------------------------------------------------------------

RegisterNetEvent("XpM:updateUI")
AddEventHandler("XpM:updateUI", function(_xp)
    CurrentXP = tonumber(_xp)

    SendNUIMessage({
        xpm_set = true,
        xp = CurrentXP
    })
end)

-- SET INTITIAL XP
RegisterNetEvent("XpM:SetInitial")
AddEventHandler('XpM:SetInitial', XPM_SetInitial)

-- ADD XP
RegisterNetEvent("XpM:Add")
AddEventHandler('XpM:Add', XPM_Add)

-- REMOVE XP
RegisterNetEvent("XpM:Remove")
AddEventHandler('XpM:Remove', XPM_Remove)

RegisterNetEvent("XpM:SetRank")
AddEventHandler('XpM:SetRank', XPM_SetRank)

-- RANK CHANGE NUI CALLBACK
RegisterNUICallback('xpm_rankchange', function(data)
    if data.rankUp then
        TriggerEvent("XpM:rankUp", data.current, data.previous)
    else
        TriggerEvent("XpM:rankDown", data.current, data.previous)
    end
end)

RegisterNUICallback('xpm_uichange', function(data)
    UIActive = false
end)

RegisterNUICallback('xpm_lbchange', function(data)
    LBActive = false
end)


------------------------------------------------------------
--                        EXPORTS                         --
------------------------------------------------------------

-- SET INTITIAL XP
exports('XPM_SetInitial', XPM_SetInitial)

-- ADD XP
exports('XPM_Add', XPM_Add)

-- REMOVE XP
exports('XPM_Remove', XPM_Remove)

-- SET RANK
exports('XPM_SetRank', XPM_SetRank)

-- GET CURRENT XP
exports('XPM_GetXP', XPM_GetXP)

-- GET CURRENT RANK
exports('XPM_GetRank', XPM_GetRank)

-- GET XP REQUIRED TO RANK-UP
exports('XPM_GetXPToNextRank', XPM_GetXPToNextRank)

-- GET XP REQUIRED TO RANK-UP
exports('XPM_GetXPToRank', XPM_GetXPToRank)

-- GET MAX XP
exports('XPM_GetMaxXP', XPM_GetMaxXP)

-- GET MAX RANK
exports('XPM_GetMaxRank', XPM_GetMaxRank)

-- SHOW UI
exports('XPM_ShowUI', XPM_ShowUI)

-- HIDE UI
exports('XPM_HideUI', XPM_HideUI)

-- TIMEOUT UI
exports('XPM_TimeoutUI', XPM_TimeoutUI)

-- SORT LEADERBOARD
exports('XPM_SortLeaderboard', XPM_SortLeaderboard)


------------------------------------------------------------
--                        COMMANDS                        --
------------------------------------------------------------
TriggerEvent('chat:addSuggestion', '/XPM', 'Display your XP stats')

RegisterCommand('XPM', function(source, args)
    Citizen.CreateThread(function()
        local xpToNext = XPM_GetXPToNextRank()

        -- SHOW THE XP BAR
        SendNUIMessage({ xpm_display = true })        

        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", _('cmd_current_xp', CurrentXP)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", _('cmd_current_lvl', CurrentRank)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", _('cmd_next_lvl', xpToNext, CurrentRank + 1)}
        })                
    end)
end)