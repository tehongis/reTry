#version 330 core
out vec4 FragColor;

in vec2 TexCoords;

// Pelin dynaamiset arvot moottorista
uniform vec2 screenResolution;
uniform vec3 viewPos;       // Aluksen paikka
uniform vec3 viewDir;       // Aluksen katsevektori
uniform vec3 padPosition;   // Alustan paikka
uniform vec3 cargoPosition; // Laatikon paikka
uniform int cargoAttached;  // 1 = kiinni, 0 = irti
uniform float time;
uniform float playerYawRad; // <--- UUSI: Pelaajan virallinen katsekulma radiaaneina

#define PI 3.14159265359f

// Apufunktio: Laskee pisteen paikan tutkaympyrän sisällä suhteessa aluksen suuntaan
vec2 getRadarSpacePos(vec3 targetPos, vec3 playerPos, float headingYaw, float radarRadius) {
    vec3 diff = targetPos - playerPos;
    
    // Etäisyys vaakatasossa (XZ-tasossa)
    float dist = length(vec2(diff.x, diff.z));
    
    // Skaalataan etäisyys tutkalle (max 150 yksikön päässä olevat kohteet näkyvät)
    float maxRadarDist = 150.0f;
    float scaledDist = (dist / maxRadarDist) * radarRadius;
    
    // Rajoitetaan kohde pysymään tutkarenkaan sisäpuolella, vaikka se olisi kauempana
    if (scaledDist > radarRadius - 4.0f) {
        scaledDist = radarRadius - 4.0f;
    }
    
    // Lasketaan kohteen suuntakulma XZ-maailmassa
    float angleToTarget = atan(diff.z, diff.x);
    
    // MATEMAATTISESTI VAKIOITU KORJAUS:
    // Vähennetään kohteen maailmankulmasta pelaajan oma katsekulma.
    // Lisätään PI / 2.0f (90 astetta), jotta aluksen nokka osoittaa tasan ylöspäin tutkalla.
    float relativeAngle = angleToTarget - headingYaw + (PI / 2.0f);
    
    // Palautetaan siirtymävektori tutkan keskipisteestä katsottuna.
    // Koska haluamme dynaamisen +Y-akselin osoittavan ETEENPÄIN ja +X-akselin OIKEALLE,
    // standardi 2D-ympyräprojektio lasketaan näin:
    return vec2(cos(relativeAngle) * scaledDist, sin(relativeAngle) * scaledDist);
}



void main() {
    // 1. MÄÄRITETÄÄN TUTKAN KOKO JA SIJAINTI (Oikea alakulma)
    float radarSize = 130.0f; // Tutkan säde pikseleinä
    vec2 radarCenter = vec2(screenResolution.x - radarSize - 30.0f, radarSize + 30.0f);
    
    // Nykyisen pikselin koordinaatit ruudulla
    vec2 pixelPos = TexCoords * screenResolution;
    
    // Etäisyysvektori nykyisestä pikselistä tutkan keskipisteeseen
    vec2 distVec = pixelPos - radarCenter;
    float currentDist = length(distVec);
    
    // Jos pikseli on tutkaympyrän ulkopuolella, jätetään se läpinäkyväksi
    if (currentDist > radarSize) {
        discard;
    }
    
    // --- 2. TUTKAN TAUSTA JA ETÄISYYSRENKAAT ---
    vec3 radarColor = vec3(0.01f, 0.08f, 0.02f); // Tummanvihreä scifi-pohja
    
    if (abs(currentDist - radarSize * 0.33f) < 1.0f || 
        abs(currentDist - radarSize * 0.66f) < 1.0f || 
        abs(currentDist - radarSize * 0.98f) < 1.5f) {
        radarColor = vec3(0.1f, 0.4f, 0.15f);
    }
    
    // --- 3. PYÖRIVÄ SKANNAUSVIIVA (Sweeper Effect) ---
    float pixelAngle = atan(distVec.y, distVec.x);
    if (pixelAngle < 0.0f) pixelAngle += 2.0f * PI;
    
    float sweepAngle = mod(time * 2.5f, 2.0f * PI);
    float angleDiff = sweepAngle - pixelAngle;
    if (angleDiff < 0.0f) angleDiff += 2.0f * PI;
    
    float sweepGlow = exp(-angleDiff * 4.0f); 
    radarColor += vec3(0.0f, 0.35f, 0.05f) * sweepGlow;
    
    // --- 4. DYNAAMISET KOHTEET (BLIPS) ---
    float playerYaw = atan(viewDir.z, viewDir.x);
    
    // KORJAUS: Kohdepisteet lasketaan nyt dynaamisina absoluuttisina pikselipisteinä ruudulla!
    // Lisätään keskipisteen osoite (radarCenter) saatuun offset-vektoriin.
    

    // A: Laskeutumisalusta (Vihreä kohde)
    vec2 padPixelPos = radarCenter + getRadarSpacePos(padPosition, viewPos, playerYawRad, radarSize);
    float distToPadBlip = length(pixelPos - padPixelPos);
    if (distToPadBlip < 5.0f) {
        radarColor = vec3(0.1f, 0.9f, 0.2f);
    }
    
    // B: Rahtilaatikko (Vilkkuva keltainen/sininen kohde)
    vec3 finalCargoWorldPos = (cargoAttached == 1) ? viewPos : cargoPosition;
    vec2 cargoPixelPos = radarCenter + getRadarSpacePos(finalCargoWorldPos, viewPos, playerYawRad, radarSize);
    float distToCargoBlip = length(pixelPos - cargoPixelPos);
    
    if (distToCargoBlip < 4.5f) {
        vec3 cargoBlipColor = (cargoAttached == 1) ? vec3(0.2f, 0.6f, 1.0f) : vec3(0.9f, 0.7f, 0.0f);
        float blipPulse = 0.7f + 0.3f * sin(time * 10.0f);
        radarColor = cargoBlipColor * blipPulse;
    }
    
    // --- 5. KESKIPISTE (Pelaajan oma alus) ---
    if (currentDist < 3.0f) {
        radarColor = vec3(1.0f, 1.0f, 1.0f);
    }
    
    float edgeSmoothing = smoothstep(radarSize, radarSize - 2.0f, currentDist);
    FragColor = vec4(radarColor, edgeSmoothing * 0.85f);
}
