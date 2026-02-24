-- Configuration globale du projet GNU-AI
local config = {}

-- Configuration IRC
config.irc = {
    server = "irc.oftc.net",
    port = 6667,
    nickname = "GNU_AI_Bot",
    username = "gnu_ai",
    realname = "GNU AI RPG Bot",
    default_channel = "#gnu-ai-test",
    ping_interval = 60,
    connection_timeout = 30,
    command_cooldown = 1
}

-- Configuration AI
config.ai = {
    enabled = true,
    api_url = "http://127.0.0.1:8080/v1/completions",
    max_tokens = 256,
    temperature = 0.5,
    timeout = 10
}

-- Configuration du jeu
config.game = {
    max_level = 100,
    default_energy = 50,
    max_dice_roll = 10,
    creation_points = 100,
    character_save_dir = "saves/",
    monster_save_dir = "saves/monsters/"
}

return config

