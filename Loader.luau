local placeId = game.PlaceId

local function loadScriptForPlaceId(placeId)
    if placeId == 13955927965 then
        -- Replace with your actual loadstring code for this PlaceId
        loadstring(game:HttpGet("https://raw.githubusercontent.com/nNiou-sudo/GunHub/refs/heads/Games/BloodZone.luau"))()
    elseif placeId == 87654321 then
        -- Replace with your actual loadstring code for this PlaceId
        loadstring("print('This is PlaceId 87654321')")()
    else
        print("No script for this PlaceId: " .. placeId)
    end
end

loadScriptForPlaceId(placeId)
