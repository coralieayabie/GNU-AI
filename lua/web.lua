-- web.lua - Conversion du module web C en Lua
-- Équivalent de web.h et web.c
-- Utilise la bibliothèque http.lua (à installer via luarocks)

local http = require("resty.http")  -- Alternative: require("socket.http")

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

-- Fonction de callback pour traiter la réponse - Équivalent de write_callback
local function process_response(ctx, response_body)
    if response_body then
        ctx.result = response_body
    else
        ctx.result = "Erreur: aucune réponse reçue"
    end
end

-- Fonction principale de recherche web - Équivalent de web_search_agent_execute
function Web.web_search_agent_execute(context)
    local ctx = context
    
    -- Créer un client HTTP
    local httpc = http.new()
    
    -- Encoder la requête pour l'URL
    local encoded_query = string.gsub(ctx.query, "[", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    
    -- Construire l'URL pour DuckDuckGo
    local url = "https://api.duckduckgo.com/?q=" .. encoded_query .. "&format=json&no_redirect=1"
    
    -- Effectuer la requête
    local res, err = httpc:request_uri(url, {
        method = "GET",
        ssl_verify = false  -- Désactiver la vérification SSL pour simplifier (à améliorer en production)
    })
    
    if not res then
        ctx.result = "Erreur: " .. (err or "inconnu")
        return
    end
    
    -- Traiter la réponse
    process_response(ctx, res.body)
end

return {
    WebContext = WebContext,
    web_search_agent_execute = Web.web_search_agent_execute
}