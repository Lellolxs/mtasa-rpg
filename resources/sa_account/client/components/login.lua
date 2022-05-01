Components.login = {};
local component = Components.login;

component.__uiElements = {};

local width, height = 250 * getResp(), 200 * getResp();
local x, y = ScreenWidth / 2 - width / 2, ScreenHeight / 2 - height / 2;
local font = Core:requireFont('opensans-bold', 10);

component.__render = function()
    local ui = component.__uiElements;
    ui.username.render(x, y, width, height * 0.19);
    ui.password.render(x, y + height * 0.21, width, height * 0.19);

    ui.save_login.render(x + width * 0.025, y + height * 0.45, 24, 24);
    dxDrawText(
        "Adatok megjegyzése", 
        x + width * 0.175, 
        y + height * 0.45, 
        x + width * 0.175, 
        y + height * 0.45 + 24,
        tocolor(200, 200, 200), 
        1, font, 
        "left", "center"
    );

    ui.login_btn.render("Bejelentkezés", x + width * 0.05, y + height * 0.635, width * 0.9, height * 0.175);
    ui.register_btn.render("Regisztráció", x + width * 0.05, y + height * 0.825, width * 0.9, height * 0.175);
end

component.__saveLoginDetails = function(enabled, username, password)
    local xml = xmlLoadFile('@login.xml');

    if (not file) then 
        xml = xmlCreateFile('@login.xml', 'login_details');
        
        local enabledNode = xmlCreateChild(xml, 'enabled');
        xmlNodeSetValue(enabledNode, enabled and "1" or "0");

        xmlCreateChild(xml, 'username');
        xmlCreateChild(xml, 'password');
    end 

    xmlNodeSetValue(xmlFindChild(xml, 'enabled', 0), enabled and "1" or "0");
    xmlNodeSetValue(xmlFindChild(xml, 'username', 0), username);
    xmlNodeSetValue(xmlFindChild(xml, 'password', 0), password);

    xmlSaveFile(xml);
    xmlUnloadFile(xml);
end 

component.__getLoginDetails = function()
    local xml = xmlLoadFile('@login.xml');

    if (not xml) then 
        return false;
    end 

    local enabled = (xmlNodeGetValue(xmlFindChild(xml, 'enabled', 0)) or "0");
    if (not enabled or enabled == "0") then 
        return false;
    end 

    local username = (xmlNodeGetValue(xmlFindChild(xml, 'username', 0)) or "");
    local password = (xmlNodeGetValue(xmlFindChild(xml, 'password', 0)) or "");

    return username, password;
end 

component.__handleLoginResponse = function(hasCharacter)
    if (not hasCharacter) then 
        Components.charcreator.mount();
        component.unmount();
    else 
        component.unmount();
        Components.background.unmount();

        Core:disableCameraCinematic();
        showChat(true);
        showCursor(false);
        setCameraTarget(localPlayer);

        if (isTimer(CameraTimer)) then 
            killTimer(CameraTimer);
        end 
    end

    removeEventHandler('account:loginResponse', resourceRoot, component.__handleLoginResponse);
end 

component.proceedLogin = function(self, button, state)
    if (button ~= 'left' or state ~= 'up') then 
        return;
    end 

    local ui = component.__uiElements;
    component.__saveLoginDetails(ui.save_login.value, ui.username.value, ui.password.value);

    if (
        not ui.username or 
        string.len(ui.username.value) < 3
    ) then 
        return Info:showNotification(
            "error", "Érvénytelen felhasználónév! (Minimum 3 karakter)"
        );
    end 

    if (
        not ui.password or 
        string.len(ui.password.value) < 6
    ) then 
        return Info:showNotification(
            "error",
            "Érvénytelen jelszó! (Minimum 6 karakter)"
        );
    end 

    addEventHandler('account:loginResponse', resourceRoot, component.__handleLoginResponse);
    triggerServerEvent('account:login', resourceRoot, ui.username.value, ui.password.value);
end 

component.switchToRegister = function(self, button, state)
    if (button ~= 'left' or state ~= 'up') then 
        return;
    end 

    component.unmount();
    Components.register.mount();
end 

component.mount = function()
    component.__uiElements.username = Editbox('login_username', { placeholder = 'Felhasználónév' });
    component.__uiElements.password = Editbox('login_password', { placeholder = 'Jelszó', masked = true, specialsAllowed = true });
    component.__uiElements.save_login = Checkbox('login_savelogin', { iconSize = 8 });
    component.__uiElements.login_btn = Button('login_proceed', { font = Core:requireFont('opensans-bold', 12) });
    component.__uiElements.register_btn = Button('login_switch', { font = Core:requireFont('opensans-bold', 12) });

    local username, password = component.__getLoginDetails();
    if (username and password) then 
        component.__uiElements.save_login.value = true;
        component.__uiElements.username.value = username;
        component.__uiElements.password.value = password;
    else 
        component.__uiElements.save_login.value = false;
    end 

    component.__uiElements.login_btn.on('click', component.proceedLogin);
    component.__uiElements.register_btn.on('click', component.switchToRegister);

    addEventHandler('onClientRender', root, component.__render);
end 

component.unmount = function()
    for key, element in pairs(component.__uiElements) do 
        if (element.destroy) then 
            element.destroy()
        end

        element = nil;
    end 

    removeEventHandler('onClientRender', root, component.__render);
end 

addEvent('account:loginResponse', true);