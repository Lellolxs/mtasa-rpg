Components.charcreator = {};
local component = Components.charcreator;

component.__uiElements = {};

local width, height = 500 * getResp(), 250 * getResp();
local x, y = ScreenWidth / 2 - width / 2, ScreenHeight / 2 - height / 2;
local font = Core:requireFont('opensans-bold', 11);
local font2 = Core:requireFont('opensans-bold', 10);
local icon = Core:requireFont('fontawesome', 15);

local skinIndex = 1;
local skinGender = 'male';
local spawns = {};

component.render = function()
    -- dxDrawRectangle(x, y, width, height, tocolor(255, 0, 0, 50))

    local ui = component.__uiElements;
    ui.name.render(x, y, width * 0.475, height * 0.15);
    -- ui.age.render(x, y + height * 0.17, width * 0.15, height * 0.15);
    -- ui.weight.render(x + width * 0.1625, y + height * 0.17, width * 0.15, height * 0.15);
    -- ui.height.render(x + width * 0.325, y + height * 0.17, width * 0.15, height * 0.15);
    ui.start.render(x, y + height * 0.165, width * 0.475, height * 0.15);
    ui.description.render(x, y + height * 0.33, width * 0.475, height * 0.5);

    ui.set_male.render('', x + width * 0.66, y + height * 0.85, width * 0.08, height * 0.15);
    ui.set_female.render('', x + width * 0.76, y + height * 0.85, width * 0.08, height * 0.15);

    ui.previous_skin.render('', x + width * 0.55, y + height * 0.425, width * 0.08, height * 0.15);
    ui.next_skin.render('', x + width * 0.865, y + height * 0.425, width * 0.08, height * 0.15);

    ui.finish.render("Karakter befejezése", x, y + height * 0.85, width * 0.475, height * 0.15);
end

component.__changeGender = function(gender)
    if (skinGender ~= gender) then 
        skinGender = gender;
        skinIndex = 1;

        setElementModel(component.element, Config.skins[gender][skinIndex]);
    end 
end 

component.__changeSkin = function(state)
    if (state == 'previous') then 
        skinIndex = (not Config.skins[skinGender][skinIndex - 1]) and #Config.skins[skinGender] or skinIndex - 1;
    elseif (state == 'next') then 
        skinIndex = (not Config.skins[skinGender][skinIndex + 1]) and 1 or skinIndex + 1;
    end 

    setElementModel(component.element, Config.skins[skinGender][skinIndex]);
end 

component.createCharacter = function(self, button, state)
    local ui = component.__uiElements;

    if (
        button ~= 'left' or 
        state ~= 'up' or
        ui.start.open -- elkerulve hogy random ranyomjon mikor nyitvavan aza geci
    ) then 
        return;
    end 

    if (
        type(ui.name.value) ~= 'string' or 
        string.len(ui.name.value) < 6 or 
        not ui.name.value:match('[a-z-A-Z]+_[a-zA-Z]+_?[a-zA-Z]+')
    ) then 
        return Info:showNotification('error', 'Érvénytelen karakternév. (Minimum 6 karakter.)');
    end 

    if (
        type(ui.description.value) ~= 'string' or
        string.len(ui.description.value) < 150
    ) then 
        return Info:showNotification('error', 'Hibás karakterleírás. (Minimum 150 karakter szükséges.)');
    end 

    triggerServerEvent(
        'account:createCharacter', 
        resourceRoot, 
        ui.name.value,  
        ui.description.value, 
        spawns[ui.start.selected], 
        skinGender, 
        skinIndex
    );
end 

component.__onCharacterCreated = function()
    component.unmount();
    Components.login.mount();
end 

component.mount = function()
    local ui = component.__uiElements;

    -- 
    -- Character data
    -- 

    ui.name = Editbox('charcreator_name', { placeholder = "Karakter név (pl: Lompos_Frigyes)", font = font, specialsAllowed = true, style = { align = 'center', radius = 0.5 } });

    local options = {};
    for id, v in pairs(Config.startPositions) do table.insert(options, v.text); table.insert(spawns, id); end 
    ui.start = Select('charcreator_start', { options = options, selected = false, placeholder = "Kezdőváros" });

    ui.description = Textarea('charcreator_description', { placeholder = "Karaktered vizuális leírása (Minimum 150 betű)", specialsAllowed = true, style = { align = 'left', radius = 0.05, padding = 4 } });
    ui.finish = Button('charcreator_finish');

    ui.finish.on('click', component.createCharacter);

    -- 
    -- Character appearance
    -- 

    ui.set_male = Button('charcreator_male', { font = icon, style = { hoverColor = { 92, 166, 209 } }, });
    ui.set_female = Button('charcreator_female', { font = icon, style = { hoverColor = { 234, 117, 213 } }, });
    ui.previous_skin = Button('charcreator_previous_skin', { font = icon });
    ui.next_skin = Button('charcreator_next_skin', { font = icon });

    ui.set_male.on('click', function(self, button, state) if (button == 'left' and state == 'up') then component.__changeGender('male') end end);
    ui.set_female.on('click', function(self, button, state) if (button == 'left' and state == 'up') then component.__changeGender('female') end end);
    ui.previous_skin.on('click', function(self, button, state) if (button == 'left' and state == 'up') then component.__changeSkin('previous'); end end);
    ui.next_skin.on('click', function(self, button, state) if (button == 'left' and state == 'up') then component.__changeSkin('next'); end end);

    local x2, y2, z2 = getCameraMatrix();
	component.element = createPed(Config.skins[skinGender][skinIndex], x2, y2, z2);

	component.preview = Preview:createObjectPreview(component.element, 0, 0, 180, x + width * 0.54, y, width * 0.4, height * 0.8, false, true);
	component.window = guiCreateWindow(x + width * 0.54, y, width * 0.4, height * 0.8, "Preview", false, false);
	guiSetAlpha(component.window, 0);
    guiWindowSetMovable(component.window, false);
    guiWindowSetSizable(component.window, false);

    addEventHandler('onClientRender', root, component.render);
    addEventHandler('account:onCharacterCreated', resourceRoot, component.__onCharacterCreated);
end

component.unmount = function()
    for id, element in pairs(component.__uiElements) do 
        if (element.destroy) then 
            element.destroy();
        end 

        element = nil;
    end 

    Preview:destroyObjectPreview(component.preview);
    if (isElement(component.element)) then destroyElement(component.element); end
    if (isElement(component.window)) then destroyElement(component.window); end

    removeEventHandler('onClientRender', root, component.render);
    removeEventHandler('account:onCharacterCreated', resourceRoot, component.__onCharacterCreated);
end

addEvent('account:onCharacterCreated', true);