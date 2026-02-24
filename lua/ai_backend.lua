-- ai_backend.lua - Backend pour l'API locale de devastral/llama.cpp
-- Gère les requêtes vers le serveur local et les fallbacks

local http = require("socket.http")
local ltn12 = require("ltn12")
local json = require("dkjson")
local config = require("config")

local AIBackend = {}
AIBackend.__index = AIBackend

-- Configuration par défaut
local default_config = {
    api_url = "http://127.0.0.1:8080/v1/completions",
    max_tokens = 256,
    temperature = 0.5,
    timeout = 10,
}

-- Créer une nouvelle instance
function AIBackend.new(custom_config)
    local self = setmetatable({}, AIBackend)
    self.config = custom_config or default_config
    return self
end

-- Envoyer une requête à l'API locale
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
        headers = {
            ["Content-Type"] = "application/json",
        },
        source = ltn12.source.string(request_body),
        sink = ltn12.sink.table(response),
        timeout = self.config.timeout,
    }

    if not success or status ~= 200 then
        print("⚠️ Erreur API IA: " .. tostring(status))
        return nil, "L'AI est temporairement indisponible."
    end

    local data = table.concat(response)
    local parsed = json.decode(data)
    if not parsed or not parsed.choices or not parsed.choices[1] then
        return nil, "Réponse invalide de l'AI."
    end

    return parsed.choices[1].text:gsub("^%s*", ""), nil
end

-- Générer une réponse avec fallback
function AIBackend:get_response(prompt)
    local ok, result, err = pcall(function()
        return self:query(prompt)
    end)
    if not ok or not result then
        return "Désolé, je ne peux pas répondre pour l'instant. Essayez plus tard."
    end
    return result
end

return AIBackend

