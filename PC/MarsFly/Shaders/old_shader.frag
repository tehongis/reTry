#version 330 core
out vec4 FragColor;

in vec3 FragPos;
in vec3 Normal;
in vec2 TexCoords;

uniform vec3 lightDir;       
uniform vec3 lightColor;     
uniform int renderMode;      // 1 = Standard, 2 = Night Vision, 3 = Thermal, 4 = Sci-Fi Grid
uniform vec3 viewPos;           
uniform vec3 playerLightPos;    
uniform vec3 playerLightDir;    
uniform vec3 playerLightColor;  
uniform float time; 

// Apufunktio, joka laskee onko piste kraaterin pohjalla (palauttaa 1.0 jos on jäätä, muuten 0.0)
float getIceMask(vec3 pos) {
    // Tarkistetaan etäisyys Noise.cpp:ssä määriteltyjen kahden suurimman kraaterin keskipisteisiin
    // Kraateri 1: keskipiste (32, 32), säde 12
    float d1 = length(pos.xz - vec2(32.0, 32.0));
    // Kraateri 2: keskipiste (80, 50), säde 18
    float d2 = length(pos.xz - vec2(80.0, 50.0));
    
    // Jos ollaan tarpeeksi syvällä kraaterin pohjalla (alle 60% säteestä), siellä on jäätä
    float ice1 = smoothstep(12.0 * 0.6, 12.0 * 0.4, d1);
    float ice2 = smoothstep(18.0 * 0.6, 18.0 * 0.4, d2);
    
    return clamp(ice1 + ice2, 0.0, 1.0);
}

void main() {
    vec3 norm = normalize(Normal);
    vec3 baseOutputColor = vec3(0.0);

    // 1. Haetaan jään määrä nykyisessä kohdassa (0.0 = hiekkaa, 1.0 = täysin jäässä)
    float iceFactor = getIceMask(FragPos);

    // 2. Määritetään maaston perusväri (hiekka vs. kuivajää)
    float heightFactor = clamp((FragPos.y + 5.0) / 25.0, 0.0, 1.0);
    vec3 sandColor = mix(vec3(0.35, 0.12, 0.08), vec3(0.65, 0.28, 0.15), heightFactor);
    // Jää on vaaleaa ja siinä on kevyt sinertävä hohde
    vec3 iceColor = vec3(0.75, 0.85, 0.95); 
    
    // Sekoitetaan pintamateriaali jään määrän mukaan
    vec3 marsBaseColor = mix(sandColor, iceColor, iceFactor);

    // 3. Pelaajan maastovalo (Spotlight)
    vec3 lightToFragDir = normalize(FragPos - playerLightPos);
    float theta = dot(lightToFragDir, normalize(playerLightDir));
    float cutOff = cos(radians(15.0));
    float outerCutOff = cos(radians(22.0));
    
    float flashDiff = max(dot(norm, -lightToFragDir), 0.0);
    // Jää heijastaa aluksen valoa hieman voimakkaammin (spekulaarinen efekti)
    vec3 flashlightEffect = flashDiff * playerLightColor * (1.0 + iceFactor * 0.5);
    
    float epsilon = cutOff - outerCutOff;
    float intensity = clamp((theta - outerCutOff) / epsilon, 0.0, 1.0);
    flashlightEffect *= intensity;
    
    float distance = length(FragPos - playerLightPos);
    float attenuation = 1.0 / (1.0 + 0.01 * distance + 0.002 * (distance * distance));
    flashlightEffect *= attenuation;

    // ---------------------------------------------------------
    // TYYLI 1: STANDARD MARS
    // ---------------------------------------------------------
    if (renderMode == 1) {
        float ambientStrength = 0.45;
        vec3 ambient = ambientStrength * lightColor;
        
        vec3 lightDirection = normalize(-lightDir);
        float diff = max(dot(norm, lightDirection), 0.0);
        vec3 diffuse = diff * lightColor;
                
        // Maaston väri (joka sisältää nyt jään) + aluksen valo
        baseOutputColor = ((ambient + diffuse) * marsBaseColor) + flashlightEffect;
    }
    // ---------------------------------------------------------
    // TYYLI 2: NIGHT VISION
    // ---------------------------------------------------------
    else if (renderMode == 2) {
        vec3 lightDirection = normalize(-lightDir);
        float diff = max(dot(norm, lightDirection), 0.0) + 0.3;
        float scanline = sin(FragPos.z * 8.0) * 0.15 + 0.85;
        
        float greenIntensity = (marsBaseColor.r + marsBaseColor.g + marsBaseColor.b) / 3.0 * diff * scanline;
        float flashGreen = (flashlightEffect.r + flashlightEffect.g + flashlightEffect.b) / 3.0;
        
        baseOutputColor = vec3(0.0, (greenIntensity + flashGreen * 2.0) * 1.5, 0.0);
    }
    // ---------------------------------------------------------
    // TYYLI 3: THERMAL IMAGING (Lämpökamera + JÄÄ)
    // ---------------------------------------------------------
    else if (renderMode == 3) {
        // Normaali maaston lämpötila korkeuden mukaan (0.0 - 1.0)
        float h = (FragPos.y + 8.0) / 20.0;
        h = clamp(h, 0.0, 1.0);
        
        vec3 thermalColor;
        
        // MUUTOS: Jos kohdassa on jäätä, pakotetaan se äärimmäisen kylmäksi (violetti/syvä sininen)
        if (iceFactor > 0.1) {
            // Mitä enemmän jäätä, sitä kylmempi violetti sävy
            thermalColor = mix(vec3(0.0, 0.0, 0.5), vec3(0.3, 0.0, 0.5), iceFactor);
        } else {
            // Normaali kalliomaaston lämpökartta
            if (h < 0.33) thermalColor = mix(vec3(0.0, 0.0, 1.0), vec3(0.0, 1.0, 0.0), h / 0.33);
            else if (h < 0.66) thermalColor = mix(vec3(0.0, 1.0, 0.0), vec3(1.0, 1.0, 0.0), (h - 0.33) / 0.33);
            else thermalColor = mix(vec3(1.0, 1.0, 0.0), vec3(1.0, 0.0, 0.0), (h - 0.66) / 0.34);
        }
        
        float diff = max(dot(norm, normalize(-lightDir)), 0.0) * 0.4 + 0.6;
        float flashThermal = max(dot(norm, -lightToFragDir), 0.0) * intensity * attenuation;
        
        baseOutputColor = thermalColor * (diff + flashThermal * 0.5);
    }
    // ---------------------------------------------------------
    // TYYLI 4: SCI-FI GRID
    // ---------------------------------------------------------
    else if (renderMode == 4) {
        float edge = 1.0 - max(dot(norm, vec3(0.0, 1.0, 0.0)), 0.0);
        float gridX = sin(FragPos.x * 2.0);
        float gridZ = sin(FragPos.z * 2.0);
        float grid = (gridX > 0.98 || gridZ > 0.98) ? 1.0 : 0.0;
        
        // Sci-Fi tilassa jää hohtaa sähkönlisen sinisenä ruudukon päällä
        vec3 neonColor = mix(vec3(0.9, 0.4, 0.1), vec3(0.0, 0.6, 1.0), iceFactor);
        float flashGrid = intensity * attenuation * 0.4;
        
        baseOutputColor = neonColor * (edge * 0.7 + grid * 0.5 + 0.1 + flashGrid);
    }

    // ... (Koko alkukoodi jäämaskeineen ja valoineen pysyy täysin samana) ...

    // ---------------------------------------------------------
    // DYNAAMINEN PÖLYMYRSKY, ILMAKEHÄ JA TÄHDET (FOG & SKY)
    // ---------------------------------------------------------
    // Perussumun väri (ruosteisen oranssi Mars-horisontti)
    vec3 fogColor = vec3(0.48, 0.24, 0.15); 
    
    if (renderMode == 2) fogColor = vec3(0.0, 0.05, 0.0); 
    if (renderMode == 4) fogColor = vec3(0.04, 0.02, 0.04);

    // Lasketaan etäisyys kamerasta maaston pisteeseen
    float viewDistance = length(viewPos - FragPos);
    
    // Myrskyn tiheyden aaltoilu ajan myötä
    float stormWind = sin(time * 0.5) * 0.005;
    float baseDensity = 0.017 + stormWind;

    // Liikkuvat pölyvirrat vaakasuunnassa
    float dustScud = sin(FragPos.x * 0.1 + time * 4.0) * cos(FragPos.z * 0.1 + time * 2.0);
    float dynamicDensity = baseDensity + (max(dustScud, 0.0) * 0.008);

    if (renderMode == 1) {
        fogColor = mix(fogColor, vec3(0.55, 0.35, 0.20), max(dustScud, 0.0) * 0.4);
    }

    // Lasketaan sumun peittävyyskerroin (fogFactor)
    float fogFactor = exp(-pow(viewDistance * dynamicDensity, 2.0));
    fogFactor = clamp(fogFactor, 0.0, 1.0);

    // ---------------------------------------------------------
    // LISÄYS: ILMAKEHÄN HEHKU JA AVARUUDEN TÄHDET
    // ---------------------------------------------------------
    // Lasketaan katselukulma suhteessa taivaaseen/horisonttiin
    // FragPosin ja viewPosin suuntavektori maailmassa
    vec3 toFragDir = normalize(FragPos - viewPos);
    float upDot = toFragDir.y; // -1.0 (suoraan alas), 0.0 (horisontti), 1.0 (suoraan ylös)

    // Standard-tilassa (F1) luodaan kaunis avaruustausta tähtineen
    if (renderMode == 1) {
        // Kun katsotaan ylöspäin (upDot > 0), ilmakehä ohenee ja muuttuu avaruuden mustaksi
        vec3 spaceColor = vec3(0.01, 0.005, 0.01); 
        
        // Luodaan liuku horisontin oranssista (fogColor) avaruuden pimeyteen (spaceColor)
        // Ohut kaasukehän hehku rajautuu kauniisti horisontin yläpuolelle
        float atmosphereGlow = smoothstep(-0.1, 0.4, upDot);
        fogColor = mix(fogColor, spaceColor, atmosphereGlow);

        // TÄHTIEN GENERATION (Pseudorandom-matematiikka maailmankoordinaateista)
        if (upDot > 0.05) {
            // Käytetään maaston koordinaatteja luomaan staattinen "tähtikartta" taivaalle
            // Otetaan suuntavektori ja kerrotaan se suurella luvulla korkean taajuuden saamiseksi
            vec3 starPos = toFragDir * 450.0;
            
            // Matemaattinen pistekohina, joka poimii hyvin pieniä, kirkkaita pisteitä
            float starNoise = sin(starPos.x) * cos(starPos.y) * sin(starPos.z);
            
            // Kynnysarvo: vain kaikkein kirkkaimmat huiput muuttuvat tähdiksi
            if (starNoise > 0.993) {
                // Lisätään tähdille pientä tuiketta (tuike riippuu ajasta ja tähden paikasta)
                float twinkle = sin(time * 3.0 + starPos.x) * 0.3 + 0.7;
                
                // Mitä korkeammalle katsotaan (pois ohentuvasta ilmakehästä), sitä kirkkaammin tähdet näkyvät
                float atmosphereClearance = smoothstep(0.05, 0.3, upDot);
                
                vec3 starColor = vec3(0.95, 0.95, 1.0) * twinkle * atmosphereClearance;
                fogColor += starColor; // Sulautetaan tähdet taivaan väriin
            }
        }
    }

    // Lopullinen väri: sekoitetaan maasto ja uusi taivas/sumu sumukertoimen mukaan
    vec3 finalColorWithFog = mix(fogColor, baseOutputColor, fogFactor);

    FragColor = vec4(finalColorWithFog, 1.0);
}
