__Commands = {};

local cmdExecFails = {
    player_not_found = "Jatekos nincs", 
    player_not_specified = "Nincs jatekos megadva anyad", 
    player_more_than_one = "Tobb jatekosra is raillik a megadott szuresi adat",
    argument_missing = "Hianyzo argument", 
};

local defaultArgumentNames = {
    player = "Játékos név / ID", 
    vehicle = "Jármű ID", 
    interior = "Interior ID",
    number = "Szám", 
    string = "Szöveg",
    text = "...Hosszabb szöveg",
};

local defaultRequired = {
    loggedin = true, 
    admin = 0, 
    off_admin = 0, 
};

function Command(...) 
    local self = {};

    self.initialize = function(cmd, settings, handler)
        if (__Commands[cmd]) then 
            return outputDebugString(cmd .. " parancs már le van regisztrálva!", 1);
        end 

        self.command = cmd;
        self.alias = (settings.alias or {});
        self.args = (settings.args or {});
        self.required = (table.merge(defaultRequired, settings.required) or defaultRequired);
        self.description = settings.description;
        self.handler = (handler or nil);
        local hasInvalidTextArg = table.findIndex(self.args, function(x)
            return (x.type == "text");
        end);

        if (hasInvalidTextArg and hasInvalidTextArg < #self.args) then 
            return outputDebugString("Kurva anyad text csak utolso lehet!", 1);
        end 

        self.outputError = (settings.outputError ~= false) and true or false;
        self.__outputErrorArgsCache = (self.args and #self.args > 0) and "[" .. table.concat(
            table.map(self.args, function(x)
                return (x.name or defaultArgumentNames[x.type]); 
            end), 
            "] ["
        ) .. "]" or "";

        addCommandHandler(cmd, self.__onCommand);

        if (type(settings.alias) == "string") then
            addCommandHandler(settings.alias, self.__onCommand);
        elseif (type(settings.alias) == "table") then 
            for _, alias in ipairs(settings.alias) do 
                addCommandHandler(alias, self.__onCommand);
            end 
        end 

        addEventHandler('onResourceStop', (sourceResource) and getResourceRootElement(sourceResource) or resourceRoot, self.destroy);

        __Commands[cmd] = self;
        return self;
    end

    self.destroy = function()
        removeCommandHandler(self.command, self.__onCommand);

        if (type(self.alias) == "string") then
            removeCommandHandler(self.alias, self.__onCommand);
        elseif (type(self.alias) == "table") then 
            for _, alias in ipairs(self.alias) do 
                removeCommandHandler(alias, self.__onCommand);
            end 
        end 

        __Commands[self.command] = nil;
        self = nil;
    end 

    self.__onCommand = function(player, _, ...)
        local canExecute, error = self.__playerCanExecute(player);

        if (not canExecute) then 
            return iprint(error);
        end 

        local args = {...};

        local result = self.__validateArgs(player, args);
        if (not result.valid) then 
            if (self.outputError) then 
                self.__onValidateFails(player, result);
            end 

            return;
        end 

        if (self.handler) then 
            self.handler(player, unpack(result.validated));
        else 
            triggerEvent("onPlayerEmitCommand:" .. self.command, root, player, unpack(result.validated));
        end 
    end

    self.__onValidateFails = function(player, argument)
        outputChatBox(
            Core:getServerPrefix("error", "Admin") .. "/" .. self.command .. " " .. Core:getColor("error").hex .. self.__outputErrorArgsCache, 
            player, 255, 255, 255, true
        );

        local error = (cmdExecFails[argument.error]) and cmdExecFails[argument.error] or argument.error;
        outputChatBox(
            Core:getServerPrefix("error", "Admin") .. " #" .. argument.failed .. " - " .. error, 
            player, 255, 255, 255, true
        );
    end

    self.__playerCanExecute = function(player)
        if (Sudoers[getPlayerSerial(player)]) then 
            return true;
        end 

        if (self.required.loggedin == false) then 
            return true;
        end 

        if (
            self.required.loggedin ~= false and 
            not getElementData(player, "loggedIn")
        ) then 
            return false, "player_not_loggedin";
        end

        local admin = getPlayerAdminLevel(player);
        local inDuty = isAdminInDuty(player);

        if (self.required) then 
            if (self.required.off_admin and admin > self.required.off_admin) then
                return true;
            end 

            if (self.required.admin and admin > self.required.admin) then 
                if (inDuty) then
                    return true;
                end 

                return false, "player_not_in_adminduty";
            end 
        end 

        return false, "player_has_no_permission";
    end 

    self.__validateArgs = function(player, args)
        local validated = {};

        for i, v in ipairs(self.args) do 
            if (not args[i]) then 
                if (not v.optional) then
                    return { valid = false, failed = i, error = "argument_missing" };
                end 

                table.insert(validated, i, nil);
            else 
                if (v.type == "player") then 
                    if (tonumber(args[i])) then 
                        args[i] = tonumber(args[i]);
                    end 
    
                    local foundPlayer;
    
                    if (type(args[i]) == "string" and args[i] == "*") then 
                        foundPlayer = player;
                    else 
                        foundPlayer = Core:findPlayer(args[i]);
    
                        if (type(foundPlayer) == "table") then 
                            return { valid = false, failed = i, error = "player_more_than_one" };
                        elseif (type(foundPlayer) ~= "userdata") then 
                            return { valid = false, failed = i, error = "player_not_found" };
                        end 
                        
                        if (v.logged ~= false and not getElementData(foundPlayer, "loggedIn")) then
                            return { valid = false, failed = i, error = "player_not_logged_in" };
                        end
                    end 
    
                    table.insert(validated, i, foundPlayer);
                elseif (v.type == "vehicle") then 
                    local foundVehicle;
    
                    if (type(args[i]) == "string" and args[i] == "*") then 
                        foundVehicle = getPedOccupiedVehicle(player);
    
                        if (not foundVehicle) then 
                            return { valid = false, failed = i, error = "vehicle_invalid_self" };
                        end 
                    else 
                        if (not tonumber(args[i])) then 
                            return { valid = false, failed = i, error = "vehicle_invalid_type" };
                        end 
    
                        args[i] = tonumber(args[i]);
    
                        foundVehicle = table.find(getElementsByType("vehicle"), function(x)
                            return ((getElementData(x, "id") or -1) == args[i]);
                        end);
    
                        if (not foundVehicle) then 
                            return { valid = false, failed = i, error = "vehicle_not_found" };
                        end 
                    end 
    
                    table.insert(validated, i, foundVehicle);
                elseif (v.type == "interior") then 
                    local foundInterior;

                    if (type(args[i]) == "string" and args[i] == "*") then 
                        foundInterior = exports.avInterior:getElementWithinInteriorEntrace(player);

                        if (not foundInterior) then 
                            return { valid = false, failed = i, error = "interior_invalid_self" };
                        end
                    else 
                        args[i] = tonumber(args[i]);
                        foundInterior = exports.avInterior:getInteriorFromId(args[i]);

                        if (not foundInterior) then 
                            return { valid = false, failed = i, error = "interior_not_found" };
                        end 
                    end 

                    table.insert(validated, i, foundInterior);
                elseif (v.type == "number") then 
                    if (not tonumber(args[i])) then 
                        return { valid = false, failed = i, error = "number_invalid_type" };
                    end 
    
                    args[i] = tonumber(args[i]);
    
                    if (v.min and v.min > args[i]) then 
                        return { valid = false, failed = i, error = "number_below_minimum" }; 
                    end 
    
                    if (v.max and v.max < args[i]) then 
                        return { valid = false, failed = i, error = "number_upper_maximum" }; 
                    end 
    
                    if (v.values) then 
                        local index = table.findIndex(v.values, function(x) return (x == args[i]); end);
    
                        if (not index) then 
                            return { valid = false, failed = i, error = "number_not_between_values" }; 
                        end 
                    end 
    
                    table.insert(validated, i, args[i]);
                elseif (v.type == "string") then 
                    if (type(args[i]) ~= "string") then 
                        return { valid = false, failed = i, error = "string_invalid" }; 
                    end 
    
                    if (v.min and v.min > string.len(args[i])) then 
                        return { valid = false, failed = i, error = "string_below_minimum" }; 
                    end 
    
                    if (v.max and v.max < string.len(args[i])) then 
                        return { valid = false, failed = i, error = "string_upper_maximum" }; 
                    end 
    
                    if (v.values) then 
                        local index = table.findIndex(v.values, function(x) return (x == args[i]); end);
    
                        if (not index) then 
                            return { valid = false, failed = i, error = "string_not_between_values" }; 
                        end 
                    end 
    
                    table.insert(validated, i, args[i]);
                elseif (v.type == "text") then 
                    local text = table.concat(args, " ", i);
    
                    if (v.min and v.min > string.len(text)) then 
                        return { valid = false, failed = i, error = "text_below_minimum" }; 
                    end 
    
                    if (v.max and v.max > string.len(text)) then 
                        return { valid = false, failed = i, error = "text_upper_maximum" }; 
                    end 
    
                    table.insert(validated, i, text);
                end 
            end 
        end 

        return {
            valid = true, 
            validated = validated, 
        };
    end

    return self.initialize(...);
end 