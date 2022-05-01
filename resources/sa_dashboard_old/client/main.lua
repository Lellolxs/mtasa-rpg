core = exports.sa_core

loadstring(core:require({ }))()

config = {}

colors = core:getColors()
fonts = {
    opensansregular = core:requireFont('opensans', 14),
    opensansregular13 = core:requireFont('opensans', 13),
    opensansbold = core:requireFont('opensans-bold', 14),
    opensansbold13 = core:requireFont('opensans-bold', 13),
    fontawesome = core:requireFont('fontawesome', 12),
}

sx, sy = guiGetScreenSize()

local Dashboard = {
    show = false,
    size = Vector2(850, 600),
    pselectorSize = Vector2(200, 600)
}
Dashboard.pos = Vector2(sx / 2 - Dashboard.size.x / 2, sy / 2 - Dashboard.size.y / 2)
setmetatable({}, {__index = Dashboard})

local handlers = {
    {
        name = 'onClientRender',
        func = function(...)
            return Dashboard:Render(...)
        end
    },
}

function Dashboard:Open(element)
    for _, event in pairs(handlers) do
        removeEventHandler(event.name, event.arg or root, event.func)
        addEventHandler(event.name, event.arg or root, event.func)
    end
    self.show = element
    self.activePage = 1
end

function Dashboard:Close()
    for _, event in pairs(handlers) do
        removeEventHandler(event.name, event.arg or root, event.func)
    end
    self.show = false
    self.hovered = false
end


-- render
local page = 2 
local propertyPage = 1

function Dashboard:Render()
    -- if getPlayerSerial(localPlayer) == '8006EB3EC09B840C86CF8C028BA064B3' then
        
    -- mainPage    
            dxDrawRectangle(Dashboard.pos + Vector2(100, 0), Dashboard.size, config.colors.dash_bg)
            dxDrawRectangle(Dashboard.pos - Vector2(100, 0), Dashboard.pselectorSize, config.colors.pageselector_bg)
            dxDrawRectangle(Dashboard.pos + Vector2(99, 0), Dashboard.pselectorSize - Vector2(198, 0), config.colors.pageselector_bgline)
            
            drawText(core:getServerProperty('server_name'), Dashboard.pos - Vector2(100, 0) + Vector2(0, 30), 
            Dashboard.pselectorSize, config.colors.servernameColor,
            1, fonts.opensansbold, 'center', 'top', true)
            
            drawText(selectorIcon[1],  Dashboard.pos - Vector2(180, 0) + Vector2(0, 131), Dashboard.pselectorSize, config.colors.servernameColor,1, fonts.fontawesome, 'center', 'top', true)
            drawText('OPCIOK', Dashboard.pos - Vector2(140, 0) + Vector2(0, 130), 
            Dashboard.pselectorSize, config.colors.servernameColor,
            1, fonts.opensansbold13, 'center', 'top', true)

            for i = 1, 5 do
                drawText(pageIcons[i], Dashboard.pos - Vector2(150, 0) + i * Vector2(0, 45) + Vector2(0, 130), Dashboard.pselectorSize, config.colors.pageselector_textcolor, 1, fonts.fontawesome, 'center', 'top', true)
                drawText(pageTexts[i], Dashboard.pos - Vector2(25, 0) + i * Vector2(0, 45) + Vector2(0, 130), 
                Dashboard.pselectorSize, config.colors.pageselector_textcolor,
                1, fonts.opensansregular, 'left', 'top', true)
            end

        -- prem section
            drawText(ppIcon[1],  Dashboard.pos - Vector2(185, 100), Dashboard.pselectorSize, config.colors.servernameColor, 1, fonts.fontawesome, 'center', 'bottom', true)
            drawText('PREMIUM', Dashboard.pos - Vector2(140, 100), 
            Dashboard.pselectorSize, config.colors.servernameColor,
            1, fonts.opensansbold13, 'center', 'bottom', true)

            drawText('PP valami', Dashboard.pos - Vector2(100, 60), 
            Dashboard.pselectorSize, config.colors.pageselector_textcolor,
            1, fonts.opensansregular, 'center', 'bottom', true)

        if page == 1 then

        elseif page == 2 then --propertyPages
            for i = 1, 3 do
                drawText(propertyPages[i], Dashboard.pos + Vector2(20, 30) + i * Vector2(120, 0) , 
                Dashboard.size, config.colors.pageselector_textcolor,
                1, fonts.opensansregular13, 'left', 'top', true)
                if i == propertyPage then
                    dxDrawRectangle(Dashboard.pos + Vector2(20, 55) +  i * Vector2(120, 0), 
                    dxGetTextWidth(propertyPages[i], 1, fonts.opensansregular13), 2, config.colors.servernameColor)


                elseif propertyPage == 1 then 

                    drawText('Jarmuveim (' .. getElementData(localPlayer, 'max_vehicles') .. '/50)', Dashboard.pos + Vector2(140, 90), 
                    Dashboard.size - Vector2(600, 550), 
                    config.colors.servernameColor,
                    1, fonts.opensansbold13, 'left', 'top', true)

                    dxDrawRectangle(Dashboard.pos + Vector2(140, 120), Dashboard.size - Vector2(500, 320), config.colors.property_color)

                    for i = 1, 9 do

                        dxDrawRectangle(Dashboard.pos + i * Vector2(0, 30) + Vector2(145, 97), Dashboard.size - Vector2(510, 575), 
                        config.colors.property_colorLine)

                        drawText(idgkocsik[i], Dashboard.pos + i * Vector2(0, 30) + Vector2(150, 97), Dashboard.size - Vector2(510, 575), 
                        config.colors.servernameColor,
                        1, fonts.opensansregular13, 'left', 'center', true)

                        
                        
                        
                    end
                    -- VEHICLE INFOS[datas]carDatasIcon
                    for i = 1, 6 do
                        
                        dxDrawRectangle(Dashboard.pos + Vector2(80, 420) + i * Vector2(60, 0), Dashboard.size - Vector2(800, 440), config.colors.property_color)
                        

                        drawText(carDatasIcon[i], Dashboard.pos + Vector2(80, 425) + i * Vector2(60, 0), Dashboard.size - Vector2(800, 440), 
                        config.colors.servernameColor, 1, fonts.fontawesome, 'center', 'top', true)

                        drawText(carDatas[i], Dashboard.pos + Vector2(80, 415) + i * Vector2(60, 0), Dashboard.size - Vector2(800, 440), 
                        config.colors.servernameColor, 1, fonts.opensansregular13, 'center', 'bottom', true)

                    end
                end
            end
        end
    -- end
end
Dashboard:Open(localPlayer)



-- MIND BLOW

function drawText(text, position, size, ...)
	return dxDrawText(text, position.x, position.y, position.x + size.x, position.y + size.y, ...)
end
