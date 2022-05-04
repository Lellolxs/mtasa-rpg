ScreenWidth, ScreenHeight = guiGetScreenSize();
Core = exports.sa_core;
Interface = exports.sa_interface;

addEventHandler('onResourceStart', root, function(resource)
    if (getResourceName(resource) == 'sa_core') then 
        Core = exports.sa_core;
    end 
end);

loadstring(Core:require({ "Rectangle", "Editbox", "Textarea", "Scrollbar" }))()