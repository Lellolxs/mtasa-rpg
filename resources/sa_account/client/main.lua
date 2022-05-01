Core = exports.sa_core;
Info = exports.sa_notifications;
Preview = exports.object_preview;

Colors = Core:getColors();
Components = {};

loadstring(Core:require({ 'Rectangle', 'Editbox', 'Textarea', 'Button', 'Checkbox', 'Select' }))();

CameraTimer = nil;
local cameraIndex = 3;
local cameraPosition = {
    {
        from = {
            pos = Vector3(94.08887481689453, 1198.24658203125, 20.04305839538574),
            at = Vector3(-327.1327209472656, 1198.597412109375, 20.52428245544434),
        },
        to = {
            pos = Vector3(-216.3959655761719, 1198.293212890625, 20.52428245544434),
            at = Vector3(-327.1327209472656, 1198.597412109375, 20.52428245544434),
        },
        time = 60000,
    },
    {
        from = {
            pos = Vector3(676.9065551757812, -645.9168701171875, 30.27002716064453),
            at = Vector3(617.1944580078125, -566.36767578125, 19.95548248291016),
        },
        to = {
            pos = Vector3(776.0988159179688, -507.7952880859375, 37.45508575439453),
            at = Vector3(844.875732421875, -577.2343139648438, 16.28995704650879),
        },
        time = 60000,
    },
    {
        from = {
            pos = Vector3(2131.248779296875, 196.9951477050781, 92.28293609619141),
            at = Vector3(2365.463134765625, 27.95848274230957, 30.09332084655762),
        },
        to = {
            pos = Vector3(2133.756591796875, -184.1922302246094, 92.28293609619141),
            at = Vector3(2365.463134765625, 27.95848274230957, 30.09332084655762),
        },
        time = 60000,
    },
};

function startCameraCinematic()    
    local current = cameraPosition[cameraIndex];
    Core:doCameraCinematic(current.from, current.to, current.time);

    CameraTimer = setTimer(function()
        cameraIndex = (not cameraPosition[(cameraIndex + 1)]) and 1 or (cameraIndex + 1);
        startCameraCinematic();
    end, current.time, 1);
end 

function handleBanResult(isBanned, details)
    if (isBanned) then 
        Components.ban.mount(details);
    else 
        Components.background.mount();
        Components.login.mount();
    end 

    startCameraCinematic();
    removeEventHandler('account:banResult', resourceRoot, handleBanResult);
end

function main()
    fadeCamera(true, 0);
    setPlayerHudComponentVisible('all', false);
    showCursor(true);
    showChat(false);

    addEvent('account:banResult', true);
    addEventHandler('account:banResult', resourceRoot, handleBanResult);

    triggerServerEvent('account:isBanned', resourceRoot);
end 
addEventHandler('onClientResourceStart', resourceRoot, main);

-- local test = Select('test_select');

-- addEventHandler('onClientRender', root, function()
--     test.render(500, 500, 200, 30);
-- end);