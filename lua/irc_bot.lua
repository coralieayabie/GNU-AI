-- irc_bot.lua - Bot IRC avancé inspiré de RGP-IRC_GAME
-- Utilise LuaSocket et s'inspire de lua-irc-engine

local socket = require("socket")
local config = require("config")
local RPGAgent = require("rpg.rpg_agent")

local IRCBot = {}

-- État du bot
local bot_state = {
    connected = false,
    socket = nil,
    last_ping = 0,
    characters = {},
    monsters = {}
}

-- Créer un nouveau bot IRC
function IRCBot.new()
    local self = setmetatable({}, { __index = IRCBot })
    self.rpg_agent = RPGAgent.create_rpg_agent()
    self.rpg_context = self.rpg_agent.context
    self.state = bot_state
    return self
end

-- Connecter au serveur IRC
function IRCBot:connect()
    print(string.format("🔌 Connexion à %s:%d...", 
                      config.irc.server, config.irc.port))
    
    local sock = socket.tcp()
    sock:settimeout(config.irc.connection_timeout)
    
    local success, err = sock:connect(config.irc.server, config.irc.port)
    if not success then
        print("❌ Erreur de connexion: " .. tostring(err))
        return false
    end
    
    self.state.socket = sock
    self.state.connected = true
    self.state.last_ping = socket.gettime()
    
    print("✅ Connecté au serveur IRC")
    
    -- Envoyer les informations d'identification
    self:send("NICK " .. config.irc.nickname)
    self:send("USER " .. config.irc.username .. " 0 * :" .. config.irc.realname)
    
    -- Rejoindre le canal
    self:send("JOIN " .. config.irc.default_channel)
    
    print(string.format("📝 Rejoint le canal %s", config.irc.default_channel))
    return true
end

-- Envoyer une commande IRC
function IRCBot:send(message)
    if not self.state.socket then return false end
    local success, err = self.state.socket:send(message .. "\r\n")
    if not success then
        print("❌ Erreur d'envoi: " .. tostring(err))
        return false
    end
    return true
end

-- Recevoir et traiter les messages
function IRCBot:receive()
    if not self.state.socket then return nil, "Non connecté" end
    
    local line, err = self.state.socket:receive()
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
function IRCBot:process_command(sender, command)
    if not command or command == "" then
        return "Aucune commande spécifiée. Utilisez !help pour l'aide."
    end
    
    -- Extraire la commande (enlever le préfixe !)
    local cmd = command:match("^!(%w+)")
    if not cmd then return "Commande non reconnue. Utilisez !help pour l'aide." end
    
    -- Extraire la commande sans le préfixe ! pour le système RPG
    local rpg_command = command:sub(2)  -- Enlever le premier caractère (!)
    
    -- Debug: voir ce que nous passons
    print("DEBUG IRC_BOT: command =", command, "rpg_command =", rpg_command, "type =", type(rpg_command))
    
    -- Exécuter la commande RPG
    local result = self.rpg_agent.execute_command(rpg_command, self.rpg_context)
    return result or "Commande exécutée avec succès."
end

-- Gérer les commandes IRC
function IRCBot:handle_irc_command(sender, message)
    if not message or message == "" then
        return
    end
    
    -- Commandes spéciales (doivent être vérifiées avant les commandes RPG)
    if message:lower() == "!ping" then
        self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": Pong!")
        return
    end
    
    if message:lower() == "!version" then
        self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": GNU-AI Bot v1.0 - RPG + IRC")
        return
    end
    
    -- Commandes RPG (toutes les autres commandes commençant par !)
    if message:match("^!") then
        local response = self:process_command(sender, message)
        -- Remplacer les retours à la ligne par des espaces pour éviter les erreurs IRC
        response = response:gsub("\n", " | ")
        -- Limiter la longueur du message pour éviter les erreurs IRC
        if #response > 400 then
            response = response:sub(1, 400) .. "..."
        end
        self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. sender .. ": " .. response)
        return
    end
end

-- Fonction pour envoyer un message de combat sur le canal
function IRCBot:send_combat_log(message)
    -- Vérifier que le message n'est pas trop long
    if #message > 400 then
        message = message:sub(1, 400) .. "..."
    end
    self:send("PRIVMSG " .. config.irc.default_channel .. " :" .. message)
end

-- Boucle principale du bot
function IRCBot:run()
    if not self:connect() then
        return false
    end
    
    print("🔄 Bot IRC en cours d'exécution. Appuyez sur Ctrl+C pour quitter.")
    
    while self.state.connected do
        local line, err = self:receive()
        
        if not line then
            if err == "timeout" then
                -- Vérifier le ping périodique
                if socket.gettime() - self.state.last_ping > config.irc.ping_interval then
                    self:send("PING :" .. config.irc.server)
                    self.state.last_ping = socket.gettime()
                end
            else
                print("❌ Déconnecté: " .. tostring(err))
                break
            end
        else
            print("← " .. line)
            
            -- Traiter les messages PRIVMSG
            local sender, channel, msg = line:match("^:(.-)!.- PRIVMSG (.-) :(.+)")
            if sender and channel and msg then
                self:handle_irc_command(sender, msg)
            end
            
            -- Répondre aux PING
            if line:match("^PING :") then
                local ping_target = line:match("^PING :(.+)")
                self:send("PONG :" .. ping_target)
            end
        end
        
        socket.sleep(0.1)
    end
    
    self:disconnect()
    return true
end

-- Déconnecter proprement
function IRCBot:disconnect()
    if self.state.socket then
        self:send("QUIT :GNU-AI Bot déconnecté")
        self.state.socket:close()
        self.state.socket = nil
        self.state.connected = false
    end
end

return IRCBot
