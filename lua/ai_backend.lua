local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")
local config = require("config")

local AIBackend = {}
AIBackend.__index = AIBackend

function AIBackend.new()
    local self = setmetatable({}, AIBackend)
    self.config = config.ai
    return self
end

function AIBackend:query(prompt)
    local request_body = json.encode({
        prompt = "[INST]" .. prompt .. "[/INST]",
        max_tokens = self.config.max_tokens,
        temperature = self.config.temperature,
        stream = false,
    })

    local response = {}
    local success, status = http.request{
        url = self.config.api_url,
        method = "POST",
        headers = {["Content-Type"] = "application/json"},
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response),
        timeout = 10,
    }

    if not success or status ~= 200 then
        print("⚠️ Erreur API IA: " .. tostring(status))
        return nil
    end

    local data = table.concat(response)
    local parsed = json.decode(data)
    if not parsed or not parsed.choices or not parsed.choices[1] then
        return nil
    end

    return parsed.choices[1].text:gsub("^%s*", "")
end

function AIBackend:get_response(prompt)
    local ok, result = pcall(function() return self:query(prompt) end)
    if not ok or not result then
        return "Désolé, l'AI est temporairement indisponible."
    end
    return result
end

return AIBackend

