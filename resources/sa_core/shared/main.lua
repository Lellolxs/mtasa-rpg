Config = {
    server_name = "San Andreas Stories",
    server_short = "SAS",

    colors = {
        server = { rgb = { 101, 162, 187 }, hex = "#65a2bb" },

        -- General colors
        info = { rgb = { 59, 120, 160 }, hex = "#3b78a0" },
        error = { rgb = { 160, 44, 44 }, hex = "#b65555" },
    },
};

function getServerProperty(property)
    return (property and Config[property])
            and Config[property]
            or false;
end 

function getColors()
    return Config.colors;
end 

function getColor(name)
    return Config.colors[name];
end 