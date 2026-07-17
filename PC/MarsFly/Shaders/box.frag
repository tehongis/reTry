#version 330 core
out vec4 FragColor;

in vec3 FragPos;
in vec3 Normal;

// Maailman valaistus
uniform vec3 lightDir;
uniform vec3 lightColor;
uniform vec3 viewPos;

// Aluksen valonheitin
uniform vec3 playerLightPos;
uniform vec3 playerLightDir;
uniform vec3 playerLightColor;

// Efektit
uniform float time;
uniform int cargoAttached; // 1 jos aluksessa, 0 jos maassa

void main() {
    vec3 norm = normalize(Normal);
    vec3 viewDir = normalize(viewPos - FragPos);
    
    // --- 1. RAHTILAATIKON PERUSVÄRI (Sci-fi oranssi) ---
    vec3 boxBaseColor = vec3(0.9f, 0.45f, 0.05f); // Teollisuusoranssi
    
    // --- 2. GLOBAALI AURINKOVALO (Ambient + Diffuse) ---
    float ambientStrength = 0.25f;
    vec3 ambient = ambientStrength * lightColor;
    
    float diff = max(dot(norm, normalize(-lightDir)), 0.0f);
    vec3 diffuse = diff * lightColor;
    
    // --- 3. ALUKSEN VALONHEITIN (Spotlight) ---
    vec3 lightToFrag = normalize(FragPos - playerLightPos);
    float theta = dot(lightToFrag, normalize(playerLightDir));
    
    vec3 spotlight = vec3(0.0f);
    // Valokeilan kulma (0.91 tarkoittaa noin 25 astetta)
    if (theta > 0.91f) {
        float spotDiff = max(dot(norm, -lightToFrag), 0.0f);
        // Vaimennetaan valoa etäisyyden mukaan
        float distance = length(FragPos - playerLightPos);
        float attenuation = 1.0f / (1.0f + 0.01f * distance + 0.001f * (distance * distance));
        
        spotlight = spotDiff * playerLightColor * attenuation;
    }
    
    // --- 4. SYKKIVÄ LED-HÄTÄVALO (Emission) ---
    // Jos laatikko on maassa, se vilkkuu hitaasti punaisena. Jos se on poimittu, se hehkuu vihreänä.
    vec3 ledColor = (cargoAttached == 1) ? vec3(0.1f, 0.9f, 0.2f) : vec3(1.0f, 0.05f, 0.05f);
    
    // Sini-aalto ajan mukaan luo tasaisen sykkivän efektin (arvo välillä 0.2 - 1.0)
    float pulse = 0.6f + 0.4f * sin(time * 5.0f); 
    vec3 emission = ledColor * pulse;
    
    // --- LOPULLINEN VÄRI ---
    vec3 result = (ambient + diffuse + spotlight) * boxBaseColor + emission;
    FragColor = vec4(result, 1.0f);
}
