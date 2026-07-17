#version 330 core
out vec4 FragColor;

uniform vec2 screenResolution;
uniform vec3 viewPos;
uniform vec3 viewDir;
uniform vec3 padPosition;
uniform vec3 cargoPosition;
uniform int cargoAttached;
uniform float time;

void main() {
    vec2 uv = gl_FragCoord.xy / screenResolution;
    vec2 radarCenter = vec2(0.5, 0.15);
    float radarRadius = 0.11;

    vec2 aspectCorrectedDiff = uv - radarCenter;
    aspectCorrectedDiff.x *= (screenResolution.x / screenResolution.y);
    float distToRadarCenter = length(aspectCorrectedDiff);

    // Jos ollaan tutkan ulkopuolella, shader ei piirrä mitään (läpinäkyvä)
    if (distToRadarCenter >= radarRadius) {
        discard; 
    }

    // --- TÄHÄN TULEE TÄSMÄLLEEN SE SAMA TUTKALOGIIKKA KUIN AIEMMIN ---
    vec3 radarGreen = vec3(0.0, 0.8, 0.2);
    vec3 radarBg = vec3(0.0, 0.05, 0.01) * (1.0 - distToRadarCenter / radarRadius);
    
    if (distToRadarCenter > radarRadius - 0.003) radarBg = radarGreen; 
    if (distToRadarCenter < 0.004) radarBg = vec3(1.0, 1.0, 1.0);     

    vec2 localRadarCoord = aspectCorrectedDiff / radarRadius;
    float ellipse = (localRadarCoord.x * localRadarCoord.x) + (localRadarCoord.y * localRadarCoord.y * 3.0);
    if (abs(ellipse - 0.3) < 0.02 || abs(ellipse - 0.7) < 0.02) radarBg = radarGreen * 0.4;
    
    if (abs(localRadarCoord.x) < 0.015 && abs(localRadarCoord.y) < 0.8) radarBg = radarGreen * 0.3;
    if (abs(localRadarCoord.y) < 0.005 && abs(localRadarCoord.x) < 0.9) radarBg = radarGreen * 0.3;

    float radarRange = 80.0; 
    float angle = atan(viewDir.z, viewDir.x) - (3.14159 / 2.0);
    float cosA = cos(angle);
    float sinA = sin(angle);



    // =========================================================
    // LANDINGPADIN KORJATTU PIIRTOLOGIIKKA
    // =========================================================
    vec2 dirToPad = padPosition.xz - viewPos.xz;
    float distToPad = length(dirToPad);
    if (distToPad < radarRange) {
        vec2 rotatedDirPad = vec2(dirToPad.x * cosA - dirToPad.y * sinA, dirToPad.x * sinA + dirToPad.y * cosA);
        vec2 padRadarPos = (rotatedDirPad / radarRange);
        
        // Litistetään Y-akseli (syvyys suunnassa) luomaan 3D-kiekkoefekti
        vec2 padPixelPos = vec2(padRadarPos.x, padRadarPos.y * 0.5); 
        
        // KORJAUS: Lasketaan korkeusero ja lisätään se VAIN Y-koordinaattiin puhtaana vec2-laskuna
        float heightDiffPad = (padPosition.y - viewPos.y) * 0.02; 
        vec2 targetPixelPosPad = vec2(padPixelPos.x, padPixelPos.y + heightDiffPad);

        // Piirretään keltainen pystytolppa oikein aluksen paikan ja kohteen välille
        if (abs(localRadarCoord.x - padPixelPos.x) < 0.004) {
            float minY = min(padPixelPos.y, targetPixelPosPad.y);
            float maxY = max(padPixelPos.y, targetPixelPosPad.y);
            if (localRadarCoord.y >= minY && localRadarCoord.y <= maxY) {
                radarBg = vec3(0.8, 0.8, 0.0); 
            }
        }
        
        // Piirretään itse blip
        if (length(localRadarCoord - targetPixelPosPad) < 0.035) {
            radarBg = vec3(1.0, 0.4, 0.0); 
        }
    }

    // =========================================================
    // CARGOBOXIN KORJATTU PIIRTOLOGIIKKA
    // =========================================================
    if (cargoAttached == 0) {
        vec2 dirToCargo = cargoPosition.xz - viewPos.xz;
        float distToCargo = length(dirToCargo);
        if (distToCargo < radarRange) {
            vec2 rotatedDirCargo = vec2(dirToCargo.x * cosA - dirToCargo.y * sinA, dirToCargo.x * sinA + dirToCargo.y * cosA);
            vec2 cargoRadarPos = (rotatedDirCargo / radarRange);
            
            // Litistetään syvyyssuunnan Y-akseli
            vec2 cargoPixelPos = vec2(cargoRadarPos.x, cargoRadarPos.y * 0.5); 
            
            // KORJAUS: Sama puhdas vec2-korjaus rahtilaatikon korkeudelle
            float heightDiffCargo = (cargoPosition.y - viewPos.y) * 0.02; 
            vec2 targetPixelPosCargo = vec2(cargoPixelPos.x, cargoPixelPos.y + heightDiffCargo);

            // Piirretään sinertävä pystytolppa
            if (abs(localRadarCoord.x - cargoPixelPos.x) < 0.004) {
                float minY = min(cargoPixelPos.y, targetPixelPosCargo.y);
                float maxY = max(cargoPixelPos.y, targetPixelPosCargo.y);
                if (localRadarCoord.y >= minY && localRadarCoord.y <= maxY) {
                    radarBg = vec3(0.0, 0.5, 0.8); 
                }
            }
            
            // Piirretään itse blip
            if (length(localRadarCoord - targetPixelPosCargo) < 0.035) {
                radarBg = vec3(0.0, 0.6, 1.0); 
            }
        }
    }


    FragColor = vec4(radarBg, 1.0);
}
