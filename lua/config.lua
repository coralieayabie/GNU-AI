-- config.lua - Configuration pour le bot IRC GNU-AI

local config = {}

-- Configuration IRC
config.irc = {
    server = "irc.libera.chat",
    port = 6667,
    nickname = "GNU_AI_Bot",
    username = "gnu_ai",
    realname = "GNU AI RPG Bot",
    default_channel = "#gnu-ai-test",
    reconnect_delay = 10,
    connection_timeout = 30,
    receive_timeout = 5,
    ping_interval = 60
}

-- Configuration du jeu
config.game = {
    character_save_dir = "saves/",
    monster_save_dir = "saves/monster/",
    max_character_name_length = 50,
    max_monster_name_length = 50,
    max_level = 100,
    starting_energy = 100,
    max_dice_roll = 10
}

-- Configuration du bot
config.bot = {
    command_prefix = "!",
    admin_nick = "owner",
    max_combat_log = 100
}

return config