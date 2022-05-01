Components['Rectangle'] = [[
	function __requestRoundRectangleShader(withoutFilled)
		local woF = not withoutFilled and ""
		return
	_OPENDOUBLEBRACKET_
	texture sourceTexture;
	float4 color = float4(1,1,1,1);
	bool textureLoad = false;
	bool textureRotated = false;
	float4 isRelative = 1;
	float4 radius = 0.2;
	float borderSoft = 0.01;
	bool colorOverwritten = true;
	_CLOSEDOUBLEBRACKET_..(woF or _OPENDOUBLEBRACKET_
	float2 borderThickness = float2(0.2,0.2);
	float radiusMultipler = 0.95;
	_CLOSEDOUBLEBRACKET_).._OPENDOUBLEBRACKET_
	SamplerState tSampler{
		Texture = sourceTexture;
		MinFilter = Linear;
		MagFilter = Linear;
		MipFilter = Linear;
	};
	float4 rndRect(float2 tex: TEXCOORD0, float4 _color : COLOR0):COLOR0{
		float4 result = textureLoad?tex2D(tSampler,textureRotated?tex.yx:tex)*color:color;
		float alp = 1;
		float2 tex_bk = tex;
		float2 dx = ddx(tex);
		float2 dy = ddy(tex);
		float2 dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
		float a = dd.x/dd.y;
		float2 center = 0.5*float2(1/(a<=1?a:1),a<=1?1:a);
		float4 nRadius;
		float aA = borderSoft*100;
		if(a<=1){
			tex.x /= a;
			aA *= dd.y;
			nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.y,isRelative.y==1?radius.y/2:radius.y*dd.y,isRelative.z==1?radius.z/2:radius.z*dd.y,isRelative.w==1?radius.w/2:radius.w*dd.y);
		}else{
			tex.y *= a;
			aA *= dd.x;
			nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.x,isRelative.y==1?radius.y/2:radius.y*dd.x,isRelative.z==1?radius.z/2:radius.z*dd.x,isRelative.w==1?radius.w/2:radius.w*dd.x);
		}
		float2 fixedPos = tex-center;
		float2 corner[] = {center-nRadius.x,center-nRadius.y,center-nRadius.z,center-nRadius.w};
		//LTCorner
		if(-fixedPos.x >= corner[0].x && -fixedPos.y >= corner[0].y){
			float dis = distance(-fixedPos,corner[0]);
			alp = 1-(dis-nRadius.x+aA)/aA;
		}
		//RTCorner
		if(fixedPos.x >= corner[1].x && -fixedPos.y >= corner[1].y){
			float dis = distance(float2(fixedPos.x,-fixedPos.y),corner[1]);
			alp = 1-(dis-nRadius.y+aA)/aA;
		}
		//RBCorner
		if(fixedPos.x >= corner[2].x && fixedPos.y >= corner[2].y){
			float dis = distance(float2(fixedPos.x,fixedPos.y),corner[2]);
			alp = 1-(dis-nRadius.z+aA)/aA;
		}
		//LBCorner
		if(-fixedPos.x >= corner[3].x && fixedPos.y >= corner[3].y){
			float dis = distance(float2(-fixedPos.x,fixedPos.y),corner[3]);
			alp = 1-(dis-nRadius.w+aA)/aA;
		}
		if (fixedPos.y <= 0 && -fixedPos.x <= corner[0].x && fixedPos.x <= corner[1].x && (nRadius[0] || nRadius[1])){
			alp = (fixedPos.y+center.y)/aA;
		}else if (fixedPos.y >= 0 && -fixedPos.x <= corner[3].x && fixedPos.x <= corner[2].x && (nRadius[2] || nRadius[3])){
			alp = (-fixedPos.y+center.y)/aA;
		}else if (fixedPos.x <= 0 && -fixedPos.y <= corner[0].y && fixedPos.y <= corner[3].y && (nRadius[0] || nRadius[3])){
			alp = (fixedPos.x+center.x)/aA;
		}else if (fixedPos.x >= 0 && -fixedPos.y <= corner[1].y && fixedPos.y <= corner[2].y && (nRadius[1] || nRadius[2])){
			alp = (-fixedPos.x+center.x)/aA;
		}
		alp = clamp(alp,0,1);
		_CLOSEDOUBLEBRACKET_..(woF or _OPENDOUBLEBRACKET_
		float2 newborderThickness = borderThickness*dd*100;
		tex_bk = tex_bk+tex_bk*newborderThickness;
		dx = ddx(tex_bk);
		dy = ddy(tex_bk);
		dd = float2(length(float2(dx.x,dy.x)),length(float2(dx.y,dy.y)));
		a = dd.x/dd.y;
		center = 0.5*float2(1/(a<=1?a:1),a<=1?1:a);
		aA = borderSoft*100;
		if(a<=1){
			tex_bk.x /= a;
			aA *= dd.y;
			nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.y,isRelative.y==1?radius.y/2:radius.y*dd.y,isRelative.z==1?radius.z/2:radius.z*dd.y,isRelative.w==1?radius.w/2:radius.w*dd.y);
		}
		else{
			tex_bk.y *= a;
			aA *= dd.x;
			nRadius = float4(isRelative.x==1?radius.x/2:radius.x*dd.x,isRelative.y==1?radius.y/2:radius.y*dd.x,isRelative.z==1?radius.z/2:radius.z*dd.x,isRelative.w==1?radius.w/2:radius.w*dd.x);
		}
		fixedPos = (tex_bk-center*(newborderThickness+1));
		float4 nRadiusHalf = nRadius*radiusMultipler;
		corner[0] = center-nRadiusHalf.x;
		corner[1] = center-nRadiusHalf.y;
		corner[2] = center-nRadiusHalf.z;
		corner[3] = center-nRadiusHalf.w;
		//LTCorner
		float nAlp = 0;
		if(-fixedPos.x >= corner[0].x && -fixedPos.y >= corner[0].y){
			float dis = distance(-fixedPos,corner[0]);
			nAlp = (dis-nRadiusHalf.x+aA)/aA;
		}
		//RTCorner
		if(fixedPos.x >= corner[1].x && -fixedPos.y >= corner[1].y){
			float dis = distance(float2(fixedPos.x,-fixedPos.y),corner[1]);
			nAlp = (dis-nRadiusHalf.y+aA)/aA;
		}
		//RBCorner
		if(fixedPos.x >= corner[2].x && fixedPos.y >= corner[2].y){
			float dis = distance(float2(fixedPos.x,fixedPos.y),corner[2]);
			nAlp = (dis-nRadiusHalf.z+aA)/aA;
		}
		//LBCorner
		if(-fixedPos.x >= corner[3].x && fixedPos.y >= corner[3].y){
			float dis = distance(float2(-fixedPos.x,fixedPos.y),corner[3]);
			nAlp = (dis-nRadiusHalf.w+aA)/aA;
		}
		if (fixedPos.y <= 0 && -fixedPos.x <= corner[0].x && fixedPos.x <= corner[1].x && (nRadiusHalf[0] || nRadiusHalf[1])){
			nAlp = 1-(fixedPos.y+center.y)/aA;
		}else if (fixedPos.y >= 0 && -fixedPos.x <= corner[3].x && fixedPos.x <= corner[2].x && (nRadiusHalf[2] || nRadiusHalf[3])){
			nAlp = 1-(-fixedPos.y+center.y)/aA;
		}else if (fixedPos.x <= 0 && -fixedPos.y <= corner[0].y && fixedPos.y <= corner[3].y && (nRadiusHalf[0] || nRadiusHalf[3])){
			nAlp = 1-(fixedPos.x+center.x)/aA;
		}else if (fixedPos.x >= 0 && -fixedPos.y <= corner[1].y && fixedPos.y <= corner[2].y && (nRadiusHalf[1] || nRadiusHalf[2])){
			nAlp = 1-(-fixedPos.x+center.x)/aA;
		}
		alp *= clamp(nAlp,0,1);
		_CLOSEDOUBLEBRACKET_).._OPENDOUBLEBRACKET_
		result.rgb = colorOverwritten?result.rgb:_color.rgb;
		result.a *= _color.a*alp;
		return result;
	}
	technique rndRectTech{
		pass P0{
			PixelShader = compile ps_2_a rndRect();
		}
	}
	_CLOSEDOUBLEBRACKET_
	end

	local __RectangleCache = {};
	local __TruncateRectanglesInterval = 100;

	function dxDrawRoundedRectangle(x, y, width, height, color, radius, fill, borderThickness, isPostGUI)
		if (not radius) then radius = 0.3; end 
		if (fill == nil) then fill = true; end 
		if (not borderThickness) then borderThickness = { 0.2, 0.2 }; end 

		if (type(radius) == 'number') then
			radius = { radius, radius, radius, radius }; 
		end 

		if (type(borderThickness) == 'number') then
			borderThickness = { borderThickness, borderThickness }; 
		end 

		local shaderId = 'rounded;' .. table.concat(radius, ';') .. tostring(fill) .. table.concat(borderThickness, ';') .. tonumber(color);
		local shader = __RectangleCache[shaderId];
		if (not shader) then 
			__RectangleCache[shaderId] = {
				element = dxCreateShader(__requestRoundRectangleShader(not fill)), 
				__lastVisible = getTickCount(),
			};

			shader = __RectangleCache[shaderId];

			local b = bitExtract(color, 0, 8);
			local g = bitExtract(color, 8, 8);
			local r = bitExtract(color, 16, 8);
			local a = bitExtract(color, 24, 8);

			dxSetShaderValue(shader.element, 'color', { r / 255, g / 255, b / 255, a / 255 });
			dxSetShaderValue(shader.element, 'radius', radius);
			dxSetShaderValue(shader.element, 'borderThickness', borderThickness);
		end 

		dxDrawImage(x, y, width, height, shader.element, 0, 0, 0, nil, isPostGUI);

		shader.__lastVisible = getTickCount();
	end 

	function dxDrawGradientRectangle(x, y, width, height, fromColor, toColor, orientation)
		local rectId = fromColor .. ';' .. toColor .. ';' .. orientation;
		if (not __RectangleCache[rectId]) then 
			__RectangleCache[rectId] = {
				element = dxCreateRenderTarget(width, height, true),
				__lastVisible = getTickCount(),
			};

			local fB = bitExtract(fromColor, 0, 8);
			local fG = bitExtract(fromColor, 8, 8);
			local fR = bitExtract(fromColor, 16, 8);
			local fA = bitExtract(fromColor, 24, 8);

			local tB = bitExtract(toColor, 0, 8);
			local tG = bitExtract(toColor, 8, 8);
			local tR = bitExtract(toColor, 16, 8);
			local tA = bitExtract(toColor, 24, 8);

			local index = 0;

			dxSetRenderTarget(__RectangleCache[rectId].element, true);
				if (orientation == 'horizontal') then 
					while (index < width) do 
						local r, g, b = interpolateBetween(fR, fG, fB, tR, tG, tB, index / width, 'Linear');
						local alpha = interpolateBetween(fA, 0, 0, tA, 0, 0, index / width, 'Linear');

						dxDrawRectangle(
							index,
							0, 1, height, 
							tocolor(r, g, b, alpha)
						);

						index = index + 1;
					end 
				elseif (orientation == 'vertical') then 

				end 
			dxSetRenderTarget(nil);
		end 

		--dxDrawRectangle(x, y, width, height, tocolor(255, 0, 0, 25));
		dxDrawImage(x, y, width, height, __RectangleCache[rectId].element);

		__RectangleCache[rectId].__lastVisible = getTickCount();
	end 

	setTimer(function()
		local tick = getTickCount();

		for k,v in pairs(__RectangleCache) do 
			if (
				v.__lastVisible and 
				v.__lastVisible + __TruncateRectanglesInterval < tick
			) then 
				if (isElement(v.element)) then 
					destroyElement(v.element);
				end 

				__RectangleCache[k] = nil;
			end 
		end 
	end, __TruncateRectanglesInterval, 0);
]]