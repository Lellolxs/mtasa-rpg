loadstring(exports.sa_core:require({ "Rectangle" }))()

local __ProgressBars = {};

local __ProgressBarStyles = {
    default = {
        progressColor = tocolor(255, 50, 50, 150),
        bgColor = tocolor(0, 0, 0, 150),
        thickness = 0.06, 
        radius = 0.45,
        aliasing = 0.02, 
    },
};

local __DefaultProgressBarSettings = {
    value = 0, 
    min_value = 0, 
    max_value = 100, 

    __transition_interval = 2000,
    __previous_value = 0, 
    __previous_value_change = getTickCount(),

    style = 'default',
    type = "rounded",
};

-- Kitepve DGS-bol mert nem ertek shaderekhez es nem is akarokxd
local shaders_raw = {
    rounded = [[
        #define PI2 6.283185307179586476925286766559
        float borderSoft = 0.02;
        float radius = 0.2;
        float thickness = 0.02;
        float2 progress = float2(0,0.1);
        float4 indicatorColor = float4(1, 1, 1, 1);
        float4 backgroundColor = float4(0.5, 0.5, 0.5, 0.5);
        float4 blend(float4 c1, float4 c2){
            float alp = c1.a+c2.a-c1.a*c2.a;
            float3 color = (c1.rgb*c1.a*(1.0-c2.a)+c2.rgb*c2.a)/alp;
            return float4(color,alp);
        }
        float4 myShader(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
            float2 dxy = float2(length(ddx(tex)),length(ddy(tex)));
            float nBS = borderSoft*sqrt(dxy.x*dxy.y)*100;
            float4 bgColor = backgroundColor;
            float4 inColor = 0;
            float2 texFixed = tex-0.5;
            float delta = clamp(1-(abs(length(texFixed)-radius)-thickness+nBS)/nBS,0,1);
            bgColor.a *= delta;
            float2 progFixed = progress * PI2;
            float angle = atan2(tex.y-0.5,0.5-tex.x)+0.5*PI2;
            bool tmp1 = angle>progFixed.x;
            bool tmp2 = angle<progFixed.y;
            float dis_ = distance(float2(cos(progFixed.x),-sin(progFixed.x))*radius,texFixed);
            float4 Color1,Color2;
            if(dis_<=thickness){
                float tmpDelta = clamp(1-(dis_-thickness+nBS)/nBS,0,1);
                Color1 = indicatorColor;
                inColor = indicatorColor;
                Color1.a *= tmpDelta;
            }
            dis_ = distance(float2(cos(progFixed.y),-sin(progFixed.y))*radius,texFixed);
            if(dis_<=thickness){
                float tmpDelta = clamp(1-(dis_-thickness+nBS)/nBS,0,1);
                Color2 = indicatorColor;
                inColor = indicatorColor;
                Color2.a *= tmpDelta;
            }
            inColor.a = max(Color1.a,Color2.a);
            if(progress.x>=progress.y){
                if(tmp1+tmp2){
                    inColor = indicatorColor;
                    inColor.a *= delta;
                }
            }else{
                if(tmp1*tmp2){
                    inColor = indicatorColor;
                    inColor.a *= delta;
                }
            }
            return blend(bgColor,inColor);
        }
        technique DrawCircle{
            pass P0	{
                PixelShader = compile ps_2_a myShader();
            }
        }
    ]], 
};

function Progressbar(id, settings)
    local settings = (settings or {});
    local self = table.merge(settings, __DefaultProgressBarSettings);

    self.id = id;
    self.style = (type(self.style) ~= 'table')
                        and (__ProgressBarStyles[self.style] or __ProgressBarStyles.default) 
                        or table.merge(self.style, __ProgressBarStyles.default);

    self.__updateShader = function()
        if (shaders_raw[self.type]) then 
            if (not self.__shader) then 
                self.__shader = {};
                self.__shader.progress = dxCreateShader(shaders_raw[self.type]);
            end 

            -- Progress
            local progress = clamp(rangePercentage(self.min_value, self.max_value, (self.__last_shown_value or 0)) / 100, 0.0, 1.0);

            dxSetShaderValue(self.__shader.progress, "progress", 0, progress);
            dxSetShaderValue(self.__shader.progress, "indicatorColor", fromcolor(self.style.progressColor, true, true));
            dxSetShaderValue(self.__shader.progress, "backgroundColor", fromcolor(self.style.bgColor, true, true));
            dxSetShaderValue(self.__shader.progress, "thickness", self.style.thickness);
            dxSetShaderValue(self.__shader.progress, "radius", self.style.radius);
            dxSetShaderValue(self.__shader.progress, "antiAliased", self.style.aliasing);
        end 
    end 

    self.__renderers = {};

    self.__renderers['rounded'] = function(x, y, width, height, rotation)
        local rotation = (rotation or 0);

        dxDrawImage(x, y, width, height, self.__shader.progress, rotation);
    end

    self.render = function(...)
        if (self.type and self.__renderers[self.type]) then 
            self.__last_shown_value = interpolateBetween(
                self.__previous_value, 0, 0, 
                self.value, 0, 0, 
                (getTickCount() - self.__previous_value_change) / self.__transition_interval, 
                "InOutQuad"
            );

            if (self.__last_shown_value ~= self.value) then 
                self.__updateShader();
            end 

            self.__renderers[self.type](...);
        end 
    end

    self.setValue = function(val)
        self.__previous_value = self.value;
        self.value = val;
        self.__previous_value_change = getTickCount();
    end

    self.destroy = function()

    end

    self.__updateShader();

    __ProgressBars[id] = self;
    return self;
end 

function clamp(num, min, max)
    if (num < min) then return min; end 
    if (num > max) then return max; end 
    
    return num;
end 

function rangePercentage(min, max, value)
    return ((value - min) * 100) / (max - min);
end 

function fromcolor(int,useMath,relative)
	local a,r,g,b
	if useMath then
		b = int%256
		local int = (int-b)/256
		g = int%256
		local int = (int-g)/256
		r = int%256
		local int = (int-r)/256
		a = int%256
	else
		a,r,g,b = getColorFromString(format("#%.8x",int))
	end
	if relative then
		a,r,g,b = a/255,r/255,g/255,b/255
	end
	return r,g,b,a
end

local kurva = Progressbar("kurva");

addEventHandler('onClientRender', root, function()
    dxDrawText( inspect(kurva), 500, 20 );
    kurva.render(900, 20, 100, 100, -90);
end);

setTimer(function()
    kurva.setValue(math.random(5, 95));
end, 5000, 0);