-- web.lua - Conversion du module web C en Lua
-- Équivalent de web.h et web.c
-- Utilise socket.http (plus courant et facile à installer)

local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")

local Web = {}

-- Structure WebContext - Équivalent de la struct C
local WebContext = {}
WebContext.__index = WebContext

function WebContext.new(query)
    local self = setmetatable({}, WebContext)
    self.query = query
    self.result = ""
    return self
end

-- Fonction pour encoder une URL
local function url_encode(str)
    if str then
        return string.gsub(str, "([^%w%.%- ])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
    end
    return ""
end

-- Fonction principale de recherche web - Équivalent de web_search_agent_execute
function Web.web_search_agent_execute(context)
    local ctx = context
    
    -- Encoder la requête pour l'URL
    local encoded_query = url_encode(ctx.query)
    
    -- Construire l'URL pour DuckDuckGo
    local url = "https://api.duckduckgo.com/?q=" .. encoded_query .. "&format=json&no_redirect=1"
    
    -- Tableau pour stocker la réponse
    local response_body = {}
    
    -- Effectuer la requête HTTP avec socket.http
    local res, status_code = http.request{
        url = url,
        sink = ltn12.sink.table(response_body),
        method = "GET",
        headers = {
            ["User-Agent"] = "GNU-AI Lua Client"
        }
    }
    
    if res then
        ctx.result = table.concat(response_body)
    else
        ctx.result = "Erreur: " .. (status_code or "requête HTTP échouée")
    end
end

return {
    WebContext = WebContext,
    web_search_agent_execute = Web.web_search_agent_execute
}