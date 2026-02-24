local config = {}

config.irc = {
    server = "irc.oftc.net",
    port = 6667,
    nickname = "GNU_AI_Bot",
    username = "gnu_ai",
    realname = "GNU AI RPG Bot",
    default_channel = "#gnu-ai-test",
    ping_interval = 60,
}

config.ai = {
    enabled = true,
    api_url = "http://127.0.0.1:8080/v1/completions",
    max_tokens = 256,
    temperature = 0.5,
}

config.game = {
    max_level = 100,
    default_energy = 50,
    max_dice_roll = 10,
}

return config

