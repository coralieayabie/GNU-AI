-- irc_client.lua - Client IRC pour GNU-AI
-- Intégration avec lua-irc-engine

local socket = require("socket")
local RPGAgent = require("rpg.rpg_agent")

local IRCClient = {}

-- Configuration par défaut
local DEFAULT_CONFIG = {
    server = "irc.libera.chat",
    port = 6667,
    nickname = "GNU_AI_Bot",
    channel = "#gnu-ai-test",
    realname = "GNU AI RPG Bot",
    username = "gnu_ai"
}

-- Créer un nouveau client IRC
function IRCClient.new(config)
    local self = setmetatable({}, { __index = IRCClient })
    self.config = config or DEFAULT_CONFIG
    self.socket = nil
    self.connected = false
    self.rpg_agent = RPGAgent.create_rpg_agent()
    self.rpg_context = self.rpg_agent.context
    return self
end

-- Connecter au serveur IRC
function IRCClient:connect()
    print(string.format("🔌 Connexion à %s:%d...", self.config.server, self.config.port))
    
    self.socket = socket.tcp()
    self.socket:settimeout(10)
    
    local success, err = self.socket:connect(self.config.server, self.config.port)
    if not success then
        print("❌ Erreur de connexion: " .. tostring(err))
        return false
    end
    
    print("✅ Connecté au serveur IRC")
    self.connected = true
    
    -- Envoyer les informations d'identification
    self:send("NICK " .. self.config.nickname)
    self:send("USER " .. self.config.username .. " 0 * :" .. self.config.realname)
    
    -- Rejoindre le canal
    self:send("JOIN " .. self.config.channel)
    
    print(string.format("📝 Rejoint le canal %s", self.config.channel))
    return true
end

-- Envoyer une commande IRC
function IRCClient:send(message)
    if not self.socket then return false end
    local success, err = self.socket:send(message .. "\r\n")
    if not success then
        print("❌ Erreur d'envoi: " .. tostring(err))
        return false
    end
    return true
end

-- Recevoir et traiter les messages
function IRCClient:receive()
    if not self.socket then return nil, "Non connecté" end
    
    local line, err = self.socket:receive()
    if not line then
        if err == "timeout" then
            return nil, "timeout"
        else
            return nil, "Déconnecté: " .. tostring(err)
        end
    end
    
    return line:gsub("\r?\n$", ""), nil
end

-- Traiter une commande RPG
function IRCClient:process_command(sender, command)
    -- Extraire la commande et les arguments
    local cmd, args = command:match("^(!)(%w+)")
    if not cmd then return "Commande non reconnue" end
    
    -- Extraire la commande sans le préfixe ! pour le système RPG
    local rpg_command = command:sub(2)  -- Enlever le premier caractère (!)
    
    -- Exécuter la commande RPG
    local result = self.rpg_agent.execute_command(rpg_command, self.rpg_context)
    return result or "Commande exécutée"
end

-- Boucle principale du client IRC
function IRCClient:run()
    if not self:connect() then
        return false
    end
    
    print("🔄 Client IRC en cours d'exécution. Appuyez sur Ctrl+C pour quitter.")
    
    while self.connected do
        local line, err = self:receive()
        
        if not line then
            if err == "timeout" then
                -- Envoyer PING pour maintenir la connexion
                self:send("PING :" .. self.config.server)
            else
                print("❌ Déconnecté: " .. tostring(err))
                break
            end
        else
            print("← " .. line)
            
            -- Traiter les messages PRIVMSG
            if line:match("^:.- PRIVMSG %#.- :(!%w+)") then
                local sender = line:match("^:(.-)!")
                local command = line:match("PRIVMSG .- :(.+)")
                
                if sender and command then
                    local response = self:process_command(sender, command)
                    self:send("PRIVMSG " .. self.config.channel .. " :" .. sender .. ": " .. response)
                end
            end
            
            -- Répondre aux PING
            if line:match("^PING :") then
                local ping_target = line:match("^PING :(.+)")
                self:send("PONG :" .. ping_target)
            end
        end
        
        socket.sleep(0.1)
    end
    
    self:socket_close()
    return true
end

-- Fermer la connexion
function IRCClient:socket_close()
    if self.socket then
        self.socket:close()
        self.socket = nil
        self.connected = false
    end
end

return IRCClient