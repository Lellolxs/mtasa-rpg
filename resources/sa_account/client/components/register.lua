Components.register = {};
local component = Components.register;

component.__uiElements = {};

local width, height = 250 * getResp(), 300 * getResp();
local x, y = ScreenWidth / 2 - width / 2, ScreenHeight / 2 - height / 2;
local font = Core:requireFont("opensans-bold", 10);

component.__render = function()
    local ui = component.__uiElements;

    ui.username.render(x, y, width, height * 0.125);
    ui.password.render(x, y + height * 0.135, width, height * 0.125);
    ui.password_again.render(x, y + height * 0.27, width, height * 0.125);
    ui.email.render(x, y + height * 0.402, width, height * 0.125);
    ui.inviter.render(x, y + height * 0.535, width, height * 0.125);

    component.__uiElements.register_btn.render(
        "Regisztráció", 
        x + width * 0.05, y + height * 0.735, 
        width * 0.9, height * 0.125
    );
    component.__uiElements.return_btn.render(
        "Visszalépés", 
        x + width * 0.05, y + height * 0.875, 
        width * 0.9, height * 0.125
    );
end

component.proceedRegistration = function(self, button, state)
    if (button ~= "left" or state ~= "up") then 
        return;
    end 

    local ui = component.__uiElements;

    if (not ui) then 
        return;
    end 

    if (
        not ui.username or 
        string.len(ui.username.value) < 3
    ) then 
        return Info:showNotification(
            "error",
            "Érvénytelen felhasználónév! (Minimum 3 karakter)" 
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

    if (
        not ui.password_again or 
        ui.password.value ~= ui.password_again.value
    ) then 
        return Info:showNotification(
            "error",
            "Hibás jelszómegerősítés!" 
        );
    end 

    if (
        not ui.email.value or 
        not ui.email.value:match("^[A-Za-z0-9%.]+@[%a%d]+%.[%a%d]+$")
    ) then 
        return Info:showNotification("error", "Érvénytelen email cím!");
    end

    triggerServerEvent(
        "account:register",
        resourceRoot, 
        ui.username.value, 
        ui.email.value, 
        ui.password.value, 
        ui.password_again.value, 
        ui.inviter.value
    );
end 

component.returnToLogin = function(self, button, state)
    if (button ~= "left" or state ~= "up") then 
        return;
    end 

    component.unmount();
    Components.login.mount();
end 

component.mount = function()
    component.__uiElements.username = Editbox("register_username", { placeholder = "Felhasználónév" });
    component.__uiElements.password = Editbox("register_password", { placeholder = "Jelszó", masked = true, specialsAllowed = true });
    component.__uiElements.password_again = Editbox("register_passwordagain", { placeholder = "Jelszó megerősítés", masked = true, specialsAllowed = true });
    component.__uiElements.email = Editbox("register_email", { placeholder = "Email cím", specialsAllowed = true });
    component.__uiElements.inviter = Editbox("register_inviter", { placeholder = "Meghívód account idje" });

    component.__uiElements.register_btn = Button("register_proceed", { font = Core:requireFont("opensans-bold", 12) });
    component.__uiElements.return_btn = Button("register_switch", { font = Core:requireFont("opensans-bold", 12) });

    component.__uiElements.register_btn.on("click", component.proceedRegistration);
    component.__uiElements.return_btn.on("click", component.returnToLogin);

    addEventHandler("onClientRender", root, component.__render);
end 

component.unmount = function()
    for key, element in pairs(component.__uiElements) do 
        if (element.destroy) then 
            element.destroy()
        end

        element = nil;
    end 

    removeEventHandler("onClientRender", root, component.__render);
end 
