Core = exports.sa_core;
Info = exports.sa_notifications;

Database = Core:getDatabase();

loadstring(Core:require({ }))(); -- Csak hogy a table fasz meglegyen

addEvent('account:register', true);
addEventHandler('account:register', resourceRoot, function(username, email, password, passwordAgain, inviter)
    local player = client;

    if (not username or string.len(username) < 3) then 
        return Info:showNotification(player, 'error', 'Érvénytelen felhasználónév. (Minimum 3 karakter!)');
    end 

    if (not email or not email:match('^[A-Za-z0-9%.]+@[%a%d]+%.[%a%d]+$')) then 
        return Info:showNotification(player, 'error', 'Érvénytelen email cím!');
    end 

    if (not password or string.len(password) < 6) then 
        return Info:showNotification(player, 'error', 'Érvénytelen jelszó. (Minimum 6 karakter!)');
    end 

    if (not passwordAgain or password ~= passwordAgain) then 
        return Info:showNotification(player, 'error', 'Érvénytelen jelszó megerősítés.');
    end 

    dbQuery(
        function(qh)
            local result = dbPoll(qh, 10);

            if (result and result[1] ~= nil) then
                local user = result[1];
                
                if (user.serial == getPlayerSerial(player)) then 
                    return Info:showNotification(player, 'error', 'Ehhez az accounthoz már tartozik felhasználó.');
                end 

                if (user.username == username) then 
                    return Info:showNotification(player, 'error', 'A megadott felhasználónév már foglalt.');
                end

                if (user.email == email) then 
                    return Info:showNotification(player, 'error', 'A megadott email cím már tartozik egy felhasználóhoz.');
                end 
            end 

            local salt = genSalt(16);
            local hashedPassword = encryptPassword(password, salt);

            dbExec(
                Database, 
                [[
                    INSERT INTO
                        users (username, password, email, salt, serial)
                    VALUES
                        (?, ?, ?, ?, ?)
                ]], 
                username, hashedPassword, email,  
                salt, getPlayerSerial(player)
            );

            Info:showNotification(player, 'success', 'Sikeres regisztracio');
        end, 
        Database, 
        [[
            SELECT 
                * 
            FROM 
                users
            WHERE 
                serial = ? OR
                username = ? OR 
                email = ?
            LIMIT 1
        ]], 
        getPlayerSerial(player), 
        username, 
        email, 
        nickname
    );
end);

addEvent('account:loadCharacter', false);
addEventHandler('account:loadCharacter', resourceRoot, function(player)
    local accountId = (getElementData(player, 'userId') or -1);
    if (accountId == -1) then 
        return Info:showNotification(player, 'error', 'Kérlek csatlakozz újra, hiba keletkezett bejelentkezés közben. (Ha továbbra se jó, jelezd egy fejlesztőnek.)');
    end 

    dbQuery(
        function(qh)
            local result = dbPoll(qh, 10);

            if (not result or #result == 0) then 
                return Info:showNotification(player, 'error', 'Nem tartozik a felhasználóhoz karakter lol.');
            end 

            local character = result[1];

            setElementData(player, 'charId', character.id);
            setElementData(player, 'name', character.name);
            setElementData(player, 'cash', character.cash);
            setElementData(player, 'premium', character.premium);

            local position = fromJSON(character.position);
            local coord = position.position;

            spawnPlayer(
                player, coord.x, coord.y, coord.z, 
                position.heading, character.skin, 
                position.interior, position.dimension
            );

            local stats = fromJSON(character.stats);
            setElementHealth(player, stats.health);
            setElementData(player, 'thirst', stats.thirst);
            setElementData(player, 'hunger', stats.hunger);

            triggerClientEvent(player, 'account:loginResponse', resourceRoot, true);
        end, 
        Database, 
        [[
            SELECT 
                * 
            FROM 
                characters
            WHERE 
                account = ?
        ]], 
        accountId
    );
end);

addEvent('account:createCharacter', true);
addEventHandler('account:createCharacter', resourceRoot, function(name, description, spawn, gender, skinIndex)
    local player = client;

    local accountId = (getElementData(player, 'userId') or -1);
    if (accountId == -1) then 
        return Info:showNotification(player, 'error', 'Kérlek csatlakozz újra, hiba keletkezett karakter készítés közben. (Ha továbbra se jó, jelezd egy fejlesztőnek.)');
    end 

    if (
        type(name) ~= 'string' or 
        string.len(name) < 6 or 
        not name:match('[a-z-A-Z]+_[a-zA-Z]+_?[a-zA-Z]+')
    ) then 
        return Info:showNotification(player, 'error', 'Érvénytelen karakternév. (Minimum 6 karakter.)');
    end 

    if (
        type(description) ~= 'string' or
        string.len(description) < 150
    ) then 
        return Info:showNotification(player, 'error', 'Hibás karakterleírás. (Minimum 150 karakter szükséges.)');
    end 

    if (
        type(spawn) ~= 'string' or
        not Config.startPositions[spawn]
    ) then 
        return Info:showNotification(player, 'error', 'Érvénytelen kezdőváros. (Válassz ki egyet.)');
    end 

    if (
        type(gender) ~= 'string' or
        not Config.skins[gender] or 
        type(skinIndex) ~= 'number' or
        not Config.skins[gender][skinIndex] 
    ) then 
        return Info:showNotification(player, 'error', 'Érvénytelen kinézet. (Jelezd fejlesztőnek!)');
    end 

    local skin = Config.skins[gender][skinIndex];

    dbQuery(
        function(qh)
            local result = dbPoll(qh, 10);

            if (result and #result > 0) then 
                local character = result[1];

                if (character.account == accountId) then 
                    return Info:showNotification(player, 'error', 'A felhasználódhoz már tartozik karakter.');
                end 

                if (character.name == name) then 
                    return Info:showNotification(player, 'error', 'A megadott karakternév már foglalt.');
                end 
            end 

            local spawnPosition = toJSON({
                position = Config.startPositions[spawn].position, 
                heading = 0, 
                interior = 0, 
                dimension = 0, 
            });

            local insert = dbExec(
                Database, 
                [[
                    INSERT INTO
                        characters (name, position, skin, account)
                    VALUES
                        (?, ?, ?, ?)
                ]], 
                name, 
                spawnPosition, 
                skin,
                accountId
            );

            if (insert) then 
                Info:showNotification(player, 'Sikeres karakter létrehozás.', 'success')
                triggerClientEvent(player, "account:onCharacterCreated", resourceRoot);
            else 
                return Info:showNotification(player, 'error', 'Sikertelen karakter létrehozás.');
            end 
        end, 
        Database, 
        [[
            SELECT 
                COUNT(id) as chars
            FROM 
                characters
            WHERE 
                name = ? AND 
                account = ?
            LIMIT 1
        ]], 
        name, 
        accountId
    );
end); -- confused screaming

addEvent('account:login', true);
addEventHandler('account:login', resourceRoot, function(username, password)
    local player = client;

    if (not username or string.len(username) < 3) then 
        return Info:showNotification(player, 'error', 'Érvénytelen felhasználónév.');
    end 

    if (not password or string.len(password) < 6) then 
        return Info:showNotification(player, 'error', 'Érvénytelen jelszó.');
    end 

    dbQuery(
        function(qh)
            local result = dbPoll(qh, 10);

            if (not result or not result[1]) then 
                return Info:showNotification(player, 'error', 'Nem találtam a felhasználót.');
            end 

            local user = result[1];

            if (user.serial ~= getPlayerSerial(player) and user.serial ~= '_') then 
                Info:showNotification(player, 'error', 'Ez a felhasználó más serialhoz van csatolva.');
                return;
            end 

            local passwd = encryptPassword(password, user.salt);
            if (passwd ~= user.password) then
                Info:showNotification(player, 'error', 'A megadott jelszó hibás.');
                return; 
            end 

            setElementData(player, 'userId', user.id);
            setElementData(player, 'loggedIn', true);
            
            local admin = fromJSON(user.admin);
            setElementData(player, 'admin', admin);

            if (not user.userChars or user.userChars == 0) then 
                return triggerClientEvent(
                    player, 
                    "account:loginResponse", 
                    resourceRoot, 
                    false
                );
            else 
                triggerEvent('account:loadCharacter', resourceRoot, player);
            end

            if (user.serial == '_') then 
                dbExec(
                    Database, 
                    [[
                        UPDATE 
                            users
                        SET
                            serial = ?
                        WHERE 
                            id = ?
                    ]], 
                    getPlayerSerial(player),
                    user.id
                );
            end 
        end, 
        Database, 
        [[
            SELECT
                users.*, COUNT(characters.account) AS userChars
            FROM 
                users
            LEFT JOIN
                characters ON users.id = characters.account
            WHERE 
                users.username = ?
        ]], 
        username
    );
end);

addEvent('account:isBanned', true);
addEventHandler('account:isBanned', resourceRoot, function()
    local player = client;

    dbQuery(
        function(qh)
            local result = dbPoll(qh, 10);

            if (result and #result > 0) then 
                triggerClientEvent(player, 'account:banResult', player, true, result);
            else 
                triggerClientEvent(player, 'account:banResult', resourceRoot, false, nil);
            end
        end, 
        Database, -- TODO: majd joinos sql query basszamteherbe
        [[
            SELECT
                *
            FROM 
                bans
            WHERE 
                user_serial = ? AND
                state = 'active'
            LIMIT 1
        ]], 
        getPlayerSerial(client)
    );
end);

-- 5 percenkent atallitja azokat a bannokat inactivera amik lejartak es eddig activeak voltak.
function updateBans()
    dbExec(
        Database, 
        [[
            UPDATE 
                bans
            SET
                state = 'expired'
            WHERE 
                expire_date < now() AND
                state = 'active'
        ]]
    );
end 
setTimer(updateBans, 60000 * 5, 0);