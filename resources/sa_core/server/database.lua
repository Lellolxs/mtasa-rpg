local connection;
local timeout = 50; -- dbPoll
local tried = 0;
local maxTryCount = 5;
local connectionInfo = {
    host = '?', 
    username = '?',
    password = '?',
    database = '?',
};

function main(resource) 
    connection = dbConnect('mysql', 'dbname=' .. connectionInfo.database .. ';host=' .. connectionInfo.host .. ';charset=utf8', connectionInfo.username, connectionInfo.password);
    if (not connection) then 
        if (maxTryCount > tried) then 
            print('Sikertelen adatbázis csatlakozás! Újrapróbálkozás ' .. timeout / 1000 .. ' másodpercen belül.');
            tried = tried + 1;
            setTimer(main, timeout, 2000, getThisResource());
        else 
            print('Sikertelen adatbázis kapcsolat. Core leállítása.');
            stopResource(getThisResource());
        end
    else 
        print("Sikeres adatbazis kapcsolodas.")
        triggerEvent("onDatabaseConnection", root, connection);
    end 
end
addEventHandler('onResourceStart', resourceRoot, main);

function getConnection()
    return connection;
end

function getDatabase()
    return connection;
end

addEvent("onDatabaseConnection", false);
