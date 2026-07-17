#version 330 core
out vec4 FragColor;

in vec3 FragPos;
in vec3 Normal;
in vec2 TexCoords;

uniform vec3 lightDir;       // Aurinko
uniform vec3 lightColor;     // Auringon väri
uniform vec3 viewPos;        // Kameran paikka
uniform vec3 playerLightPos; // Aluksen valon paikka
uniform vec3 playerLightDir; // Aluksen valon suunta
uniform vec3 playerLightColor;// Aluksen valon väri
uniform float time;

void main() {
    vec3 norm = normalize(Normal);
    vec3 viewDirVec = normalize(viewPos - FragPos);

    // 1. METALLIN PERUSVÄRI (Tumma teollisuusteräs)
    vec3 baseColor = vec3(0.3, 0.32, 0.35);
    
    // Piirretään paneeliruudukko pintaan
    float gridX = sin(FragPos.x * 3.0);
    float gridZ = sin(FragPos.z * 3.0);
    if (gridX > 0.96 || gridZ > 0.96) {
        baseColor *= 0.4; // Paneelien saumat ovat tummempia
    }

    // 2. AURINGON VALAISTUS (Mukaan lukien kiilto/specular)
    float ambientStrength = 0.3;
    vec3 ambient = ambientStrength * lightColor;

    vec3 lightDirection = normalize(-lightDir);
    float diff = max(dot(norm, lightDirection), 0.0);
    vec3 diffuse = diff * lightColor;

    // Spekulaarinen kiilto auringosta (Blinn-Phong)
    vec3 halfwayDir = normalize(lightDirection + viewDirVec);
    float spec = pow(max(dot(norm, halfwayDir), 0.0), 64.0); // 64.0 määrittelee kiillon terävyyden
    vec3 specular = spec * lightColor * 0.8; // 0.8 on metallin heijastavuus

    // 3. ALUKSEN MAASTOVALO (Voimakas kohdevalo metallipinnalle)
    vec3 lightToFragDir = normalize(FragPos - playerLightPos);
    float theta = dot(lightToFragDir, normalize(playerLightDir));
    float cutOff = cos(radians(15.0));
    float outerCutOff = cos(radians(22.0));

    float flashDiff = max(dot(norm, -lightToFragDir), 0.0);
    vec3 flashDiffuse = flashDiff * playerLightColor;

    // Spekulaarinen kiilto aluksen lampusta
    vec3 flashHalfwayDir = normalize(-lightToFragDir + viewDirVec);
    float flashSpec = pow(max(dot(norm, flashHalfwayDir), 0.0), 32.0);
    vec3 flashSpecular = flashSpec * playerLightColor * 1.2; // Aluksen valo luo kirkkaan heijastuksen

    // Kohdevalon vaimennukset ja reunapehmennykset
    float epsilon = cutOff - outerCutOff;
    float intensity = clamp((theta - outerCutOff) / epsilon, 0.0, 1.0);
    float distance = length(FragPos - playerLightPos);
    float attenuation = 1.0 / (1.0 + 0.01 * distance + 0.002 * (distance * distance));

    vec3 totalFlashlight = (flashDiffuse + flashSpecular) * intensity * attenuation;

    // 4. SYKKIVÄ ORANSSI NEON-RENGAS (Laskeutumisopastus)
    vec3 neonGlow = vec3(0.0);
    float distToCenter = length(FragPos.xz - vec2(64.0, 64.0));
    if (distToCenter > 3.8 && distToCenter < 4.2) {
        float pulse = sin(time * 3.0) * 0.3 + 0.7;
        neonGlow = vec3(1.0, 0.4, 0.0) * 3.0 * pulse;
    }

    // Yhdistetään kaikki valokomponentit
    vec3 finalLight = (ambient + diffuse) * baseColor + specular + totalFlashlight + neonGlow;

    // 5. KEVYT ILMAKEHÄSUMU (Sekoitetaan alustaan vähän Mars-pölyä etäisyyden mukaan)
    vec3 fogColor = vec3(0.48, 0.24, 0.15);
    float fogFactor = exp(-pow(distance * 0.012, 2.0)); // Alusta käyttää kevyempää sumua, jotta se näkyy paremmin
    fogFactor = clamp(fogFactor, 0.0, 1.0);

    FragColor = vec4(mix(fogColor, finalLight, fogFactor), 1.0);
}
