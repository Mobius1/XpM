
Player = nil
CurrentXP = 0
CurrentRank = 0

TriggerServerEvent("XpM:ready")

RegisterNetEvent("XpM:init")
AddEventHandler("XpM:init", function(_xp, _rank)

    local Ranks = CheckRanks()

    -- All ranks are valid
    if #Ranks == 0 then
        CurrentXP = tonumber(_xp)
        SendNUIMessage({
            xpm_init = true,
            xp = CurrentXP,
            xpm_config = Config
        });

        CurrentRank = _rank

        StatSetInt("MPPLY_GLOBALXP", CurrentXP, 1)
    else
        print(trans('err_lvls_check', #Ranks, 'Config.Ranks'))
    end
end)

RegisterNetEvent("XpM:update")
AddEventHandler("XpM:update", function(_xp, currentRank)

    local endRank = XPM_GetRank(points)
            
    CurrentXP = tonumber(_xp)
    CurrentRank = tonumber(currentRank)
    SendNUIMessage({
        xpm_set = true,
        xp = CurrentXP
    })

    StatSetInt("MPPLY_GLOBALXP", CurrentXP, 1)

    -- PlaySoundFrontend(-1, "MP_RANK_UP", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0)

    if endRank > currentRank then
        for i = currentRank, endRank - 1 do
            TriggerEvent("XpM:rankUp", endRank, currentRank)
        end
    elseif endRank < currentRank then
        for i = endRank, currentRank - 1 do
            TriggerEvent("XpM:rankDown", endRank, currentRank)
        end                
    end
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

    local points = CurrentXP + _xp;
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
        print(trans('err_xp_update', XPInit, "XPM_SetInitial"))
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
        print(trans('err_lvl_update', Rank, "XPM_SetRank"))
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
        print(trans('err_xp_update', XPAdd, "XPM_Add"))
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
        print(trans('err_xp_update', XPRemove, "XPM_Remove"))
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
            if Config.Ranks[rank + 1] >= tonumber(_xp) then
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
        print(trans('err_lvl_update', Rank, "XPM_GetXPToRank"))
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


------------------------------------------------------------
--                        CONTROLS                        --
------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        if IsControlJustReleased(0, 20) then
            SendNUIMessage({
                xpm_display = true
            })
        end
        Citizen.Wait(1)
    end
end)


------------------------------------------------------------
--                         EVENTS                         --
------------------------------------------------------------

RegisterNetEvent("XpM:updateUI")
AddEventHandler("XpM:updateUI", function(_xp)
    CurrentXP = tonumber(_xp)

    SendNUIMessage({
        xpm_set = true,
        xp = CurrentXP
    });
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


------------------------------------------------------------
--                        COMMANDS                        --
------------------------------------------------------------

TriggerEvent('chat:addSuggestion', '/XPM', 'Display your XP stats') 

RegisterCommand('XPM', function(source, args)
    Citizen.CreateThread(function()
        local currentRank = XPM_GetRank()
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
            args = {"SYSTEM", trans('cmd_current_lvl', currentRank)}
        })
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0},
            multiline = true,
            args = {"SYSTEM", trans('cmd_next_lvl', xpToNext, currentRank + 1)}
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
        });   
    else
        print("XpM: Invalid XP") 
    end       
end)

RegisterCommand('XPM_Add', function(source, args)
    if IsInt(args[1]) then
        XPM_Add(LimitXP(tonumber(args[1])))
        -- CurrentXP = LimitXP(CurrentXP + tonumber(args[1]))
        -- SendNUIMessage({
        --     xpm_set = true,
        --     xp = CurrentXP
        -- }); 
    else
        print("XpM: Invalid XP") 
    end  
end)

RegisterCommand('XPM_Remove', function(source, args)
    if IsInt(args[1]) then    
        XPM_Remove(LimitXP(tonumber(args[1])))
        -- CurrentXP = LimitXP(CurrentXP - tonumber(args[1]))
        -- SendNUIMessage({
        --     xpm_set = true,
        --     xp = CurrentXP
        -- }); 
    else
        print("XpM: Invalid XP") 
    end     
end)