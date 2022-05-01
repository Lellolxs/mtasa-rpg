function Faction(id, data)
    local self = {};

    self.id = id;
    self.label = data.label;

    self.__players = fromJSON(data.members); -- { charId: number, element: Player | null }[]
    self.__vehicles = {}; -- { id: number, element: Vehicle | null }[]
    self.__ranks = fromJSON(data.ranks);

    -- iprint(self);

    -- 
    -- Player methods
    -- 

    self.addPlayer = function(player)

    end 

    self.removePlayer = function()

    end 

    self.promotePlayer = function(player)

    end 

    self.demotePlayer = function(player)

    end
    
    self.getPlayers = function()
        return self.__players;
    end 

    -- 
    -- Vehicle methods
    -- 

    self.addVehicle = function(vehicle)

    end 

    self.removeVehicle = function(vehicle)

    end 

    self.getVehicles = function()
        return self.__vehicles;
    end 

    -- 
    -- Rank methods
    -- 

    self.createRank = function()

    end 

    self.deleteRank = function()

    end 

    self.getRanks = function()
        return self.__ranks;
    end 
end 