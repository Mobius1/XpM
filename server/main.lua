CurrentXP = 0
CurrentRank = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

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
                
                TriggerClientEvent("XpM:init", _source, CurrentXP, CurrentRank)
            end
        end)
    end
end)

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

function UpdatePlayer(xp)
    local _source = source
    local identifier = GetSteamIdentifier(_source)

    if identifier then
        MySQL.Async.execute('UPDATE users SET rp_xp = @xp WHERE identifier = @identifier', {
            ['@identifier'] = identifier,
            ['@xp'] = xp
        }, function(result)
            CurrentXP = tonumber(xp)

            TriggerClientEvent("XpM:updateUI", _source, CurrentXP)
        end)
    end
end

------------------------------------------------------------
--                        EVENTS                          --
------------------------------------------------------------

AddEventHandler("XpM:setInitial", function(XPInit)
    if IsInt(XPInit) then
        UpdatePlayer(LimitXP(XPInit))
    end
end)

AddEventHandler("XpM:addXP", function(XPAdd)
    if IsInt(XPAdd) then
        local NewXP = CurrentXP + XPAdd
        UpdatePlayer(LimitXP(NewXP))
    end
end)

AddEventHandler("XpM:removeXP", function(XPRemove)
    if IsInt(XPRemove) then
        local NewXP = CurrentXP - XPRemove
        UpdatePlayer(LimitXP(NewXP))
    end
end)