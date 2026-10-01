local function HGet(url: string)
	local ret = request({
		Url = url,
		Method = "GET",
		Headers = {
			["Cache-Control"] = "no-cache"
		}
	})

	return ret.Body
end

local BaseURL = "https://raw.githubusercontent.com/anonymoustwanger/forktown/refs/heads/main/"
local Url = BaseURL .. "Core.lua"

-- Fetch directly into memory without writing to disk
local Code = HGet(Url)

loadstring(Code, "Skidware-Main")(true)
