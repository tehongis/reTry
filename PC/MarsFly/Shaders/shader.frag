#version 330 core
out vec4 FragColor;

in vec3 FragPos;
in vec3 Normal;
in vec2 TexCoords;

uniform vec3 lightDir;       
uniform vec3 lightColor;     
uniform vec3 viewPos;        
uniform vec3 viewDir;        // Aluksen katsomasuunta (front)
uniform vec3 playerLightPos; 
uniform vec3 playerLightDir; 
uniform vec3 playerLightColor;
uniform float time;          
uniform vec3 cargoPosition;
uniform int cargoAttached;


// UUDET UNIFORMIT TUTKAA VARTEN
uniform vec2 screenResolution; // Esim. 1280, 720
uniform vec3 padPosition;      // Laskeutumisalustan paikka (64, Y, 64)

float getIceMask(vec2 uv) {
    vec2 mapPos = uv * 128.0;
    float d1 = length(mapPos - vec2(32.0, 32.0));
    float d2 = length(mapPos - vec2(80.0, 50.0));
    float ice1 = smoothstep(12.0 * 0.6, 12.0 * 0.4, d1);
    float ice2 = smoothstep(18.0 * 0.6, 18.0 * 0.4, d2);
    return clamp(ice1 + ice2, 0.0, 1.0);
}

void main() {
    // ---------------------------------------------------------
    // MAASTON PERUSRENDERÖINTI (Säilytetään täysin ennallaan)
    // ---------------------------------------------------------
    vec3 norm = normalize(Normal);
    float iceFactor = getIceMask(TexCoords);
    float heightFactor = clamp((FragPos.y + 5.0) / 25.0, 0.0, 1.0);
    
    vec3 sandColor = mix(vec3(0.35, 0.12, 0.08), vec3(0.65, 0.28, 0.15), heightFactor);
    vec3 iceColor = vec3(0.75, 0.85, 0.95); 
    vec3 marsBaseColor = mix(sandColor, iceColor, iceFactor);

    float ambientStrength = 0.45;
    vec3 ambient = ambientStrength * lightColor;
    vec3 lightDirection = normalize(-lightDir);
    float diff = max(dot(norm, lightDirection), 0.0);
    vec3 diffuse = diff * lightColor;

    vec3 lightToFragDir = normalize(FragPos - playerLightPos);
    float theta = dot(lightToFragDir, normalize(playerLightDir));
    float cutOff = cos(radians(15.0));
    float outerCutOff = cos(radians(22.0));
    
    float flashDiff = max(dot(norm, -lightToFragDir), 0.0);
    vec3 flashlightEffect = flashDiff * playerLightColor * (1.0 + iceFactor * 0.5);
    
    float epsilon = cutOff - outerCutOff;
    float intensity = clamp((theta - outerCutOff) / epsilon, 0.0, 1.0);
    flashlightEffect *= intensity;
    
    float distance = length(FragPos - playerLightPos);
    float attenuation = 1.0 / (1.0 + 0.01 * distance + 0.002 * (distance * distance));
    flashlightEffect *= attenuation;

    vec3 baseOutputColor = ((ambient + diffuse) * marsBaseColor) + flashlightEffect;

    vec3 fogColor = vec3(0.48, 0.24, 0.15); 
    float viewDistance = length(viewPos - FragPos);
    float stormWind = sin(time * 0.5) * 0.005;
    float baseDensity = 0.017 + stormWind;
    
    float dustScud = sin(FragPos.x * 0.1 + time * 4.0) * cos(FragPos.z * 0.1 + time * 2.0);
    float dynamicDensity = baseDensity + (max(dustScud, 0.0) * 0.008);
    fogColor = mix(fogColor, vec3(0.55, 0.35, 0.20), max(dustScud, 0.0) * 0.4);

    float fogFactor = exp(-pow(viewDistance * dynamicDensity, 2.0));
    fogFactor = clamp(fogFactor, 0.0, 1.0);

    float upDot = viewDir.y; 
    vec3 spaceColor = vec3(0.01, 0.005, 0.01); 
    float atmosphereGlow = smoothstep(-0.2, 0.5, upDot);
    vec3 skyColor = mix(fogColor, spaceColor, atmosphereGlow);

    if (upDot > 0.0) {
        vec3 starPos = viewDir * 350.0;
        float starNoise = sin(starPos.x * 12.3) * cos(starPos.y * 7.4) * sin(starPos.z * 9.1);
        if (starNoise > 0.990) {
            float twinkle = sin(time * 4.0 + starPos.x) * 0.4 + 0.6;
            float atmosphereClearance = smoothstep(0.0, 0.4, upDot);
            skyColor += vec3(1.0, 1.0, 1.0) * twinkle * atmosphereClearance;
        }
    }
    
    fogColor = skyColor;
    vec3 finalColorWithFog = mix(fogColor, baseOutputColor, fogFactor);

    FragColor = vec4(finalColorWithFog, 1.0);
}