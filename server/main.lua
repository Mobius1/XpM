CurrentXP = 0
CurrentRank = 0

RegisterNetEvent("XpM:ready")
AddEventHandler("XpM:ready", function()
    local _source = source
    local identifier = GetSteamIdentifier(_source)

    if identifier then
        MySQL.Async.fetchAll('SELECT rp_xp, rp_rank FROM users WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(result)
            if #result > 0 then
                CurrentXP = tonumber(result[1]["rp_xp"])
                CurrentRank = tonumber(result[1]["rp_rank"])  
                
                local Players = false

                if Config.Leaderboard.Enabled then
                    FetchActivePlayers(_source, CurrentXP, CurrentRank)
                else
                    TriggerClientEvent("XpM:init", _source, CurrentXP, CurrentRank)
                end
            end
        end)
    end
end)

function FetchActivePlayers(_source, CurrentXP, CurrentRank)
    MySQL.Async.fetchAll('SELECT * FROM users', {}, function(players)
        if #players > 0 then
            local Players = {}
            for _, playerId in ipairs(GetPlayers()) do
                local name = GetPlayerName(playerId)

                for k, v in pairs(players) do
                    if name == v.name then
                        local Player = {
                            name = name,
                            id = playerId,
                            xp = v.rp_xp,
                            rank = v.rp_rank
                        }     
                        
                        if Config.Leaderboard.ShowPing then
                            Player.ping = GetPlayerPing(playerId)
                        end

                        table.insert(Players, Player)
                        break
                    end
                end
            end                
            
            TriggerClientEvent("XpM:init", _source, CurrentXP, CurrentRank, Players)
        end
    end)
end

function GetRank(_xp)
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

RegisterNetEvent("XpM:setXP")
AddEventHandler("XpM:setXP", function(_xp, _rank)
    local _source = source
    local identifier = GetSteamIdentifier(_source)

    _xp = tonumber(_xp)
    _rank = tonumber(_rank)

    if identifier then
        MySQL.Async.execute('UPDATE users SET rp_xp = @xp, rp_rank = @rank  WHERE identifier = @identifier', {
            ['@identifier'] = identifier,
            ['@xp'] = _xp,
            ['@rank'] = _rank
        }, function(result)
            CurrentXP = _xp
            CurrentRank = _rank
            TriggerClientEvent("XpM:update", _source, CurrentXP, CurrentRank)
        end)
    end
end)

function UpdatePlayer(source, xp)
    local _source = source
    local identifier = GetSteamIdentifier(_source)

    CurrentXP = tonumber(xp)
    CurrentRank = GetRank(CurrentXP)

    if identifier then
        MySQL.Async.execute('UPDATE users SET rp_xp = @xp, rp_rank = @rank WHERE identifier = @identifier', {
            ['@identifier'] = identifier,
            ['@xp'] = CurrentXP,
            ['@rank'] = CurrentRank
        }, function(result)

            TriggerClientEvent("XpM:update", _source, CurrentXP, CurrentRank)
        end)
    end
end

------------------------------------------------------------
--                        EVENTS                          --
------------------------------------------------------------

AddEventHandler("XpM:setInitial", function(PlayerID, XPInit)
    if IsInt(XPInit) then
        UpdatePlayer(PlayerID, LimitXP(XPInit))
    end
end)

AddEventHandler("XpM:addXP", function(PlayerID, XPAdd)
    if IsInt(XPAdd) then
        local NewXP = CurrentXP + XPAdd
        UpdatePlayer(PlayerID, LimitXP(NewXP))
    end
end)

AddEventHandler("XpM:removeXP", function(PlayerID, XPRemove)
    if IsInt(XPRemove) then
        local NewXP = CurrentXP - XPRemove
        UpdatePlayer(PlayerID, LimitXP(NewXP))
    end
end)