texture screenSource;
 
sampler TextureSampler = sampler_state
{
    Texture = <screenSource>;
};

float intensity = 0.0;
float darkness = 0.4;

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
    float4 color = tex2D(TextureSampler, TextureCoordinate);
 
    float value = round((color.r + color.g + color.b) * 20.0f) / 30.0f; 
    color.r = value * darkness;
    color.g = value * darkness;
    color.b = value * darkness;
    color.a = intensity;

    return color;
}
 
technique BlackAndWhite
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}