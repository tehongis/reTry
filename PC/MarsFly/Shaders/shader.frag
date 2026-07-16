#version 330 core
out vec4 FragColor;

in vec3 FragPos;
in vec3 Color;
in vec3 Normal;

uniform vec3 lightDir;  
uniform vec3 lightColor; 
uniform int renderMode; // 1 = Standard, 2 = Night Vision, 3 = Thermal, 4 = Sci-Fi Grid

void main() {
    // ---------------------------------------------------------
    // TYYLI 1: STANDARD MARS
    // ---------------------------------------------------------
    if (renderMode == 1) {
        float ambientStrength = 0.25;
        vec3 ambient = ambientStrength * lightColor;
        
        vec3 norm = normalize(Normal);
        vec3 lightDirection = normalize(-lightDir);
        float diff = max(dot(norm, lightDirection), 0.0);
        vec3 diffuse = diff * lightColor;
                
        vec3 result = (ambient + diffuse) * Color;
        FragColor = vec4(result, 1.0);
    }
    // ---------------------------------------------------------
    // TYYLI 2: NIGHT VISION (Vihreä tutka + Skannausviivat)
    // ---------------------------------------------------------
    else if (renderMode == 2) {
        vec3 norm = normalize(Normal);
        vec3 lightDirection = normalize(-lightDir);
        float diff = max(dot(norm, lightDirection), 0.0) + 0.3; // Lisävalo pimeään
        
        // Luodaan skannausviivat siniaallolla FragPos.y tai z mukaan
        float scanline = sin(FragPos.z * 8.0) * 0.15 + 0.85;
        
        // Muutetaan harmaasävyiseksi ja kerrotaan vihreällä
        float greenIntensity = (Color.r + Color.g + Color.b) / 3.0 * diff * scanline;
        FragColor = vec4(0.0, greenIntensity * 1.5, 0.0, 1.0);
    }
    // ---------------------------------------------------------
    // TYYLI 3: THERMAL IMAGING (Lämpökamera korkeuden mukaan)
    // ---------------------------------------------------------
    else if (renderMode == 3) {
        // Otetaan korkeustieto (FragPos.y) ja skaalataan se välille 0.0 - 1.0
        float h = (FragPos.y + 8.0) / 20.0;
        h = clamp(h, 0.0, 1.0);
        
        vec3 thermalColor;
        if (h < 0.33) {
            // Kylmä: Sinisestä Vihreään
            thermalColor = mix(vec3(0.0, 0.0, 1.0), vec3(0.0, 1.0, 0.0), h / 0.33);
        } else if (h < 0.66) {
            // Keskiverto: Vihreästä Keltaiseen
            thermalColor = mix(vec3(0.0, 1.0, 0.0), vec3(1.0, 1.0, 0.0), (h - 0.33) / 0.33);
        } else {
            // Kuuma: Keltaisesta Punaiseen
            thermalColor = mix(vec3(1.0, 1.0, 0.0), vec3(1.0, 0.0, 0.0), (h - 0.66) / 0.34);
        }
        
        // Lisätään kevyt pinnan varjostus muotojen korostamiseksi
        vec3 norm = normalize(Normal);
        float diff = max(dot(norm, normalize(-lightDir)), 0.0) * 0.4 + 0.6;
        
        FragColor = vec4(thermalColor * diff, 1.0);
    }
    // ---------------------------------------------------------
    // TYYLI 4: SCI-FI GRID (Reunaviivat / Abstrakti oranssi)
    // ---------------------------------------------------------
    else if (renderMode == 4) {
        vec3 norm = normalize(Normal);
        // Lasketaan jyrkkyys suhteessa maahan (mitä jyrkempi seinämä, sen kirkkaampi reuna)
        float edge = 1.0 - max(dot(norm, vec3(0.0, 1.0, 0.0)), 0.0);
        
        // Ruudukkoefekti pinnan koordinaateista
        float gridX = sin(FragPos.x * 2.0);
        float gridZ = sin(FragPos.z * 2.0);
        float grid = (gridX > 0.98 || gridZ > 0.98) ? 1.0 : 0.0;
        
        vec3 neonColor = vec3(0.9, 0.4, 0.1); // Kyber-oranssi
        vec3 finalColor = neonColor * (edge * 0.7 + grid * 0.5 + 0.1);
        
        FragColor = vec4(finalColor, 1.0);
    }
}
