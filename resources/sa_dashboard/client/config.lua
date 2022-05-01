Core = exports.sa_core;
Admin = exports.sa_admin;
Preview = exports.object_preview;

loadstring(Core:require({ "Rectangle", "Switch" }))();

-- ScreenWidth, ScreenHeight = 800, 600;

Config = {
    total_size = Vector2(1000 * getResp(), 600 * getResp()), 

    page = { position = Vector2(0.188, 0.0), size = Vector2(0.812, 1.0) },
    page_order = { "home", "property", "factions", "premium", "admins", "settings" },

    components = {
        navbar = {
            position = Vector2(0, 0), 
            size = Vector2(0.188, 1.0),

            indicatorSize = Vector2(0.015, 0.05),

            background = tocolor(24, 24, 24),
        },
    },

    pages = {
        home = {
            preview = {
                window_multiplier = 1.5,
            },

            colors = {
                background = tocolor(28, 28, 28), 
            },
        },

        admins = {
            countPerColumn = 13,
            level_range = { from = 1, to = 11 },
            colors = {
                background = tocolor(28, 28, 28), 
                row_even = tocolor(24, 24, 24), 
                row_odd = tocolor(16, 16, 16),
                footer = tocolor(200, 200, 200),
                no_admin = "#636363",
                admin_offduty = tocolor(99, 99, 99),
                -- admin_duty = tocolor(unpack(Core:getColor('server').rgb))
            },
            footer_text = [[
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
                Ipsum dolor sit amet consectetur adipiscing elit duis. Donec et odio pellentesque diam volutpat commodo sed. 
                Scelerisque mauris pellentesque pulvinar pellentesque. Ridiculus mus mauris vitae ultricies.
            ]]
        },

        settings = {
            colors = {
                background = tocolor(28, 28, 28), 
            },
        },
    },
};