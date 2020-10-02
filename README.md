# XpM
Adds an XP ranking system like the one found in GTA:O. Work in progress.

This is a framework agnostic version of my [esx_xp](https://github.com/Mobius1/esx_xp) package.

## Features
* Designed to emulate the native GTA:O system
* Saves and loads players XP / rank
* Add / remove XP from your own script / job
* Allows you listen for rank changes to reward players
* Fully customisable UI
* Integrated leaderboard

## TOC
* [Features](#features)
* [Demos](#demos)
* [Requirements](#requirements)
* [Download & Installation](#download---installation)
* [Configuration](#configuration)
* [Functions](#functions)
* [Setters](#setters)
* [Getters](#getters)
* [Client Event Listeners](#client-event-listeners)
* [Server Triggers](#server-triggers)
* [UI](#ui)
* [Commands](#commands)
* [FAQ](#faq)
* [Contributing](#contributing)
* [Legal](#legal)
* [License](#license)

## Demos
You can find an interactive demo [here](https://codepen.io/Mobius1/full/yLeMwzO).

##### Increasing XP

![Demo Image 1](https://i.imgur.com/CpACt9s.gif)

##### Rank Up

![Demo Image 2](https://i.imgur.com/uNPRGo5.gif)

##### Leaderboard
![Demo Image 3](https://i.imgur.com/vOY7xpI.png)

## Requirements

* [fivem-mysql-async](https://github.com/brouznouf/fivem-mysql-async)

## Download & Installation

* Download and extract the package: https://github.com/Mobius1/XpM/archive/master.zip
* Rename the `XpM-master` directory to `XpM`
* Drop the `XpM` directory into your `resources` directory on your server
* Import the `XpM.sql` file into your db
* Add `ensure XpM` in your `server.cfg`
* Edit `config.lua` to your liking
* Start your server

## Configuration

The `config.lua` file is set to emulate GTA:O as close as possible, but can be changed to fit your own needs.

```lua
Config.Enabled      = true  -- enable / disable the resource
Config.Locale       = 'en'  -- Current language
Config.Width        = 532   -- Sets the width of the XP bar in px
Config.Timeout      = 5000  -- Sets the interval in ms that the XP bar is shown before fading out
Config.BarSegments  = 10    -- Sets the number of segments the XP bar has. Native GTA:O is 10
Config.Ranks        = {}    -- XP ranks. Must be a table of integers with the first element being 0.

Config.Leaderboard = {
    Enabled     = true,     -- Enable the leaderboard
    ShowPing    = true,     -- Show player pings on the leaderboard
    Order       = "rank"    -- Order the player list by "name", "rank" or "id"
}
```

## Functions

### Setters

Set initial XP rank for player
```lua
exports.XpM:XPM_SetInitial(xp --[[ integer ]])
```

Set Rank for player. This will add the required XP to advance the player to the given rank.
```lua
exports.XpM:XPM_SetRank(rank --[[ integer ]])
```

Give player XP
```lua
exports.XpM:XPM_Add(xp --[[ integer ]])
```

Remove XP from player
```lua
exports.XpM:XPM_Remove(xp --[[ integer ]])
```

### Getters

Get player's current XP
```lua
exports.XpM:XPM_GetXP()
```

Get player's current rank
```lua
-- Get rank from current XP
exports.XpM:XPM_GetRank()

-- or

-- Get rank from given XP
exports.XpM:XPM_GetRank(xp --[[ integer ]])

```

Get XP required to advance the player to the next rank
```lua
exports.XpM:XPM_GetXPToNextRank()
```

Get XP required to advance the player to the given rank
```lua
exports.XpM:XPM_GetXPToRank(rank --[[ integer ]])
```

Get max attainable XP
```lua
exports.XpM:XPM_GetMaxXP()
```

Get max attainable rank
```lua
exports.XpM:XPM_GetMaxRank()
```

## Client Event Listeners

Listen for rank change events. These can be used to reward / punish the player for changing rank.

Listen for rank-up event
```lua
AddEventHandler("XpM:rankUp", function(newRank --[[ integer ]], previousRank --[[ integer ]])
    -- Do something when player ranks up
end)
```
Listen for rank-down event
```lua
AddEventHandler("XpM:rankDown", function(newRank --[[ integer ]], previousRank --[[ integer ]])
    -- Do something when player drops a rank
end)
```

## Server Triggers
```lua
-- SET INTITIAL XP
TriggerClientEvent('XpM:SetInitial', source, xp)

-- ADD XP
TriggerClientEvent('XpM:Add', source, xp)

-- REMOVE XP
TriggerClientEvent('XpM:Remove', source, xp)

-- SET RANK
TriggerClientEvent('XpM:SetRank', source, rank)

```

## UI
The UI can be toggled with the `Z` key by default. The UI will fade out after the interval defined by `Config.Timeout` or you can close it immediately with the `Z` key.

The data in the leaderboard is refreshed whenever it is opened so you get up-to-date information.

## Commands
Get current XP stats
```lua
/XPM
```
output
```lua
You currently have xxxx XP
Your current rank is xxxx
You require xxxx XP to advance to rank yyyy
```

## FAQ

#### How do I change the look of the UI?

With a little knowledge of HTML5,  CSS3 and JS you can change all aspects of the look and layout of the bar to make it fit with your UI. The main structure is defined in `html/ui.html`, the main style is defined in `html/css/app.css` and scripting is defined in `html/js/app.js`.

You can find a demo of customised UI [here](https://codepen.io/Mobius1/full/eYJRmVy)

#### How do I lock a weapon / vehicle / unlockable to a rank?

To lock something to a rank you can listen for the `XpM:rankUp` or `XpM:rankDown` events:

Example of unlocking the minigun at rank 10:
```lua
AddEventHandler("XpM:rankUp", function(newRank, previousRank)
    if newRank == 10 then
        GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_MINIGUN"), 100, false, false)
    end
end)
```

## Contributing
Pull requests welcome.

## Legal

### License

XpM - FiveM XP System

Copyright (C) 2020 Karl Saunders

This program Is free software: you can redistribute it And/Or modify it under the terms Of the GNU General Public License As published by the Free Software Foundation, either version 3 Of the License, Or (at your option) any later version.

This program Is distributed In the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty Of MERCHANTABILITY Or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License For more details.

You should have received a copy Of the GNU General Public License along with this program. If Not, see http://www.gnu.org/licenses/.