-- agent.lua - Conversion du système d'agents C en Lua
-- Équivalent de agent.h et agent.c

local Agent = {}
Agent.__index = Agent

-- Constructor - Équivalent de create_agent
function Agent.new(name, execute_func, context)
    local self = setmetatable({}, Agent)
    self.name = name
    self.execute = execute_func
    self.context = context
    return self
end

-- Destructor - Équivalent de destroy_agent
-- En Lua, le garbage collector gère la mémoire automatiquement
-- Mais on peut fournir une méthode pour nettoyer les ressources si nécessaire
function Agent:destroy()
    -- Dans un vrai projet, on pourrait nettoyer des ressources ici
    -- Par exemple : self.context = nil
end

-- Méthode pour exécuter l'agent
function Agent:run()
    if self.execute then
        self.execute(self.context)
    end
end

return Agent