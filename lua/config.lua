-- config.lua - Ajout de la configuration AI
local config = {}

-- Configuration IRC (existante)
config.irc = {
    server = "irc.oftc.net",
    port = 6667,
    nickname = "GNU_AI_Bot",
    username = "gnu_ai",
    realname = "GNU AI RPG Bot",
    default_channel = "#gnu-ai-test",
}

-- Configuration RPG (existante)
config.game = {
    character_save_dir = "saves/",
    max_level = 100,
}

-- Configuration AI (NOUVEAU)
config.ai = {
    enabled = true,
    api_url = "http://127.0.0.1:8080/v1/completions",
    max_tokens = 256,
    temperature = 0.5,
}

return config

