
Player = nil
XP = 0

TriggerServerEvent("XpM:ready")

RegisterNetEvent("XpM:init")
AddEventHandler("XpM:init", function(_xp)

    local Ranks = CheckRanks()

    -- All ranks are valid
    if #Ranks == 0 then
        XP = tonumber(_xp)
        SendNUIMessage({
            xpm_init = true,
            xp = XP,
            xpm_config = Config
        });

        StatSetInt("MPPLY_GLOBALXP", XP, 1)
    else
        print(trans('err_lvls_check', #Ranks, 'Config.Ranks'))
    end
end)

RegisterNetEvent("XpM:update")
AddEventHandler("XpM:update", function(_xp)

    local currentRank = XPM_GetRank()
    local endRank = XPM_GetRank(points)
            
    XP = tonumber(_xp)
    SendNUIMessage({
        xpm_set = true,
        xp = XP
    })

    StatSetInt("MPPLY_GLOBALXP", XP, 1)

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

    local points = XP + _xp;
    local max = XPM_GetMaxXP()

    if init then
        points = _xp
    end

    points = LimitXP(points)

    TriggerServerEvent("XpM:setXP", points)
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

    local XPAdd = tonumber(Config.Ranks[GoalRank]) - XP

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
    local len = #Config.Ranks
    local points = XP
    if _xp then
        points = _xp
    end

    for rank = 1, len do
        if rank < len then
            if Config.Ranks[rank + 1] >= tonumber(points) then
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

    return Config.Ranks[currentRank + 1] - tonumber(XP)   
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

    return goalXP - XP
end

------------
-- XPM_GetXP.
--
-- @global
-- @return	int
function XPM_GetXP()
    return tonumber(XP)
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
    XP = tonumber(_xp)

    SendNUIMessage({
        xpm_set = true,
        xp = XP
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
            args = {"SYSTEM", trans('cmd_current_xp', XP)}
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
        XP = LimitXP(tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = XP
        });   
    else
        print("XpM: Invalid XP") 
    end       
end)

RegisterCommand('XPM_Add', function(source, args)
    if IsInt(args[1]) then
        XP = LimitXP(XP + tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = XP
        }); 
    else
        print("XpM: Invalid XP") 
    end  
end)

RegisterCommand('XPM_Remove', function(source, args)
    if IsInt(args[1]) then    
        XP = LimitXP(XP - tonumber(args[1]))
        SendNUIMessage({
            xpm_set = true,
            xp = XP
        }); 
    else
        print("XpM: Invalid XP") 
    end     
end)