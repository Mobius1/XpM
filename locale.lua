Locales = {}

function trans(str, ...)
    if Locales[Config.Locale] ~= nil then

        if Locales[Config.Locale][str] ~= nil then
            return string.format(Locales[Config.Locale][str], ...)
        else
            return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
        end

    else
        return 'Locale [' .. Config.Locale .. '] does not exist'
    end
end