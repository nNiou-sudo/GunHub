local placeId = game.PlaceId

local function loadScriptForPlaceId(placeId)
    if placeId == 13955927965 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nNiou-sudo/GunHub/refs/heads/Games/BloodZone.luau"))()
    elseif placeId == 135140697106817 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nNiou-sudo/GunHub/refs/heads/Games/PolyzZombies.luau"))()
    else
        notify("No script for this Game!", "Place ID not found", 10)
    end
end

loadScriptForPlaceId(placeId)
