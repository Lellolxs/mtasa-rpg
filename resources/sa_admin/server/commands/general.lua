function toggleFly(player)
    setElementData(player, "admin:fly", not getElementData(player, "admin:fly"));
end 
Command("fly", { required = { admin = 3, off_admin = 8 }, args = { }, alias = { "noclip" } }, toggleFly);

function toggleMessagePanel(player)
    triggerClientEvent(player, "admin:setMessagePanelState", player);
end 
Command("am", { required = { admin = 1 }, args = { } }, toggleMessagePanel);

function showCommands(player)
    triggerClientEvent(player, "admin:openCommandList", player, __Commands);
end 
Command("adminhelp", { description = "Na vajon mi? :O", required = { admin = 1 }, args = { }, alias = { "ah" } }, showCommands);

function toggleAdminDuty(player)
    local admin = getElementData(player, 'admin') or {};

    if (not admin.duty) then 
        admin.duty = true;
        setElementData(player, 'admin', admin);

        outputToAdmins(getPlayerAdminName(player) .. " szolgálatba lépett.", 1);

        sendNotificationTo("info", getPlayerAdminName(player) .. " adminszolgálatba lépett.", 0)
    else 
        admin.duty = false;
        setElementData(player, 'admin', admin);

        outputToAdmins(getPlayerAdminName(player) .. " kilépett a szolgálatból.", 1);

        sendNotificationTo("info", getPlayerAdminName(player) .. " kilépett az adminszolgálatból.", 0)
    end 
end 
Command("aduty", { required = { admin = 3, off_admin = 3 }, args = { }, alias = { "adminduty" }, }, toggleAdminDuty);

function vanishAdmin(player)
    local state = (getElementData(player, 'invisible') or false);

    if (not state) then 
        setElementAlpha(player, 0);
        setElementData(player, "invisible", true);
        outputChatBox(Core:getServerPrefix("server", "Admin") .. "Láthatatlan vagy.", player);
        outputToAdmins(getPlayerAdminName(player) .. " láthatatlánná vált.", 1);
    else 
        setElementAlpha(player, 255);
		setElementData(player, "invisible", false);
		outputChatBox(Core:getServerPrefix("server", "Admin") .. "Látható vagy.", player);
        outputToAdmins(getPlayerAdminName(player) .. " láthatóvá vált.", 1);
    end 
end 
Command("vanish", { required = { admin = 3, off_admin = 8 }, args = { }, alias = { "disappear" } }, vanishAdmin);

function disableAdminLogOutput(player)
    local newState = changeAdminsLogOutputState(player);

    outputChatBox(
        Core:getServerPrefix("server", "Admin") .. (newState and "Kikapcsoltad" or "Bekapcsoltad") .." az admin üzeneteket.", 
        player
    );
end 
Command("adminlog", { description="Elrejti az admin üzeneteket. (fixveh, unflip, etc..)", required = { admin = 3 }, args = { } }, disableAdminLogOutput);

function changeServerPassword(player, passwd)
    if (passwd ~= 'remove') then
        setServerPassword(passwd);
        outputToAdmins(getPlayerAdminName(player) .. " beállította a szerver jelszavát. (" .. passwd .. ")", 1);
    else 
        setServerPassword(nil);
        outputToAdmins(getPlayerAdminName(player) .. " leszedte a szerverről a jelszót.", 1);
    end 
end 
Command("passwd", { description = "Beállítja a szerver jelszavát. (\"remove\" a törléshez.)", required = { admin = 10 }, args = { { type = 'string', name = 'Jelszó' } } }, changeServerPassword);

local AdminStatFields = { "fixveh", "fuelveh", "unflip", "getcar", "gotocar", "goto", "gethere" };
local AdminStatMaxHours = 4380;
function getAdminStats(player, accountId, hours)
    dbQuery(
        function(qh)
            local result = dbPoll(qh, 100);

            if (result and #result > 0) then 
                outputChatBox(" ", player);

                local time = getRealTime(getRealTime().timestamp - (hours * 4380));
                local date = string.format("%04d-%02d-%02d %02d:%02d:%02d", time.year + 1900, time.month + 1, time.monthday, time.hour, time.minute, time.second);

                outputChatBox(Core:getServerPrefix("server", "Admin") .. result[1].username .. ' statisztikái ' .. date .. ' óta.', player);
                for _, v in ipairs(result) do 
                    outputChatBox(
                        Core:getServerPrefix("server", "Admin") .. v.action .. " - " .. v.count, 
                        player
                    );
                end 

                outputChatBox(" ", player);
            else 
                outputChatBox(
                    Core:getServerPrefix("server", "Admin") .. "Nincsenek logok az adminhoz köthetően.", 
                    player
                );
            end 
        end, 
        Database, 
        string.format([[
            SELECT
                logs__admin.admin_id, logs__admin.action, 
                users.id, users.username, COUNT(*) AS count
            FROM 
                logs__admin
            LEFT JOIN
                users
            ON 
            users.id = logs__admin.admin_id
            WHERE 
                logs__admin.action IN ('%s') AND
                logs__admin.admin_id = ? AND
                logs__admin.date > DATE_SUB(NOW(), INTERVAL ? HOUR)
            GROUP BY logs__admin.action
        ]], table.concat(AdminStatFields, "', '")),
        accountId, 
        hours
    );
end 
Command("adminstats", { description = "Admin statisztikái", required = { admin = 8 }, args = { { type = 'number', name = "Account ID" }, { type = 'number', name = "Elmúlt X óra (max " .. AdminStatMaxHours .. ")", min = 1, max = AdminStatMaxHours } } }, getAdminStats);