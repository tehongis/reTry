#include "Noise.h"
#include <cmath>
#include <algorithm>

// ... pito- ja fade-funktiot Perlin-kohinalle pysyvät ennallaan ...

// Standard smoothstep fading function
float fade(float t) {
    return t * t * t * (t * (t * 6.0f - 15.0f) + 10.0f);
}

// Linear interpolation
float lerp(float t, float a, float b) {
    return a + t * (b - a);
}

// Computes the dot product of a constant gradient vector and the distance vector
float grad(int hash, float x, float z) {
    int h = hash & 7;
    float u = h < 4 ? x : z;
    float v = h < 4 ? z : x;
    return ((h & 1) ? -u : u) + ((h & 2) ? -2.0f * v : 2.0f * v);
}

// The missing implementation of your 2D smooth noise function
float noise(float x, float z) {
    // Permutation table for pseudo-random gradient lookups
    static const int p[512] = {
        151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
        190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,88,237,149,56,87,174,
        20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,
        230,220,105,92,41,55,46,245,40,244,102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,
        18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,5,202,
        38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,223,183,170,213,119,248,152,
        2,44,154,163, 70,221,153,101,155,167, 43,172,9,129,22,39,253, 19,98,108,110,79,113,224,232,178,185,
        112,104,218,246,97,228,251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
        49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,138,236,205,93,222,114,
        67,29,24,72,243,141,128,195,78,212,151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,
        103,30,69,142,8,99,37,240,21,10,23,190,6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,
        32,57,177,33,88,237,149,56,87,174,20,125,136,171,168,68,175,74,165,71,134,139,48,27,166,77,146,
        158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,102,143,54,65,25,63,161,1,
        216,80,73,209,76,132,187,208,89,18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186,3,
        64,52,217,226,250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,
        28,42,223,183,170,213,119,248,152,2,44,154,163,70,221,153,101,155,167,43,172,9,129,22,39,253,19,
        98,108,110,79,113,224,232,178,185,112,104,218,246,97,228,251,34,242,193,238,210,144,12,191,179,
        162,241,81,51,145,235,249,14,239,107,49,192,214,31,181,199,106,157,184,84,204,176,115,121,50,45,
        127,4,150,254,138,236,205,93,222,114,67,29,24,72,243,141,128,195,78
    };

    // Find unit grid cell containing point
    int X = static_cast<int>(std::floor(x)) & 255;
    int Z = static_cast<int>(std::floor(z)) & 255;

    // Get relative local coordinates of point inside cell
    x -= std::floor(x);
    z -= std::floor(z);

    // Compute fade curves for x, z
    float u = fade(x);
    float v = fade(z);

    // Hash coordinates of the 4 cell corners
    int aa = p[p[X] + Z];
    int ab = p[p[X] + Z + 1];
    int ba = p[p[X] + 1 + Z];
    int bb = p[p[X] + 1 + Z + 1];

    // Add blended results from 4 corners of the cell
    return lerp(v, lerp(u, grad(aa, x, z), 
                           grad(ba, x - 1.0f, z)),
                   lerp(u, grad(ab, x, z - 1.0f), 
                           grad(bb, x - 1.0f, z - 1.0f)));
}

















// Layers multiple octaves of noise to create detailed terrain
float fbm(float x, float z) {
    float total = 0.0f;
    float amplitude = 1.0f;
    float frequency = 0.005f; // Scale down coordinates for smoother terrain
    float lacunarity = 2.0f;
    float gain = 0.5f;
    
    for (int i = 0; i < 4; ++i) {
        total += amplitude * noise(x * frequency, z * frequency);
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return total;
}














// Laskee kraaterivääristymän tiettyyn keskipisteeseen
float getSingleCrater(float x, float z, float cx, float cz, float radius, float depth) {
    float dx = x - cx;
    float dz = z - cz;
    float dist = std::sqrt(dx * dx + dz * dz);
    
    if (dist > radius * 2.0f) return 0.0f;

    // Normalisoitu etäisyys (0.0 keskellä, 1.0 reunan kohdalla)
    float nDist = dist / radius;

    if (nDist < 1.0f) {
        // Kraaterin sisäpuoli ja pohja: pehmeä kuoppa (smoothstep-tyyppinen)
        float floorEffect = (1.0f - std::cos(nDist * 3.14159f)) * 0.5f - 1.0f;
        return floorEffect * depth;
    } else if (nDist < 1.5f) {
        // Kraaterin kohotettu reuna (rim)
        float rimWeight = (nDist - 1.0f) / 0.5f; // 0.0 -> 1.0
        float rimEffect = std::sin(rimWeight * 3.14159f);
        return rimEffect * (depth * 0.25f); // Reuna on 25% kraaterin syvyydestä korkeammalla
    }
    
    return 0.0f;
}

float craterNoise(float x, float z) {
    float craterFloor = 0.0f;
    
    // Luodaan maastoon kolme kiinteää kraateria eri puolille karttaa
    // Parametrit: x, z, keskipisteX, keskipisteZ, säde, syvyys
    craterFloor += getSingleCrater(x, z, 32.0f, 32.0f, 12.0f, 0.6f);
    craterFloor += getSingleCrater(x, z, 80.0f, 50.0f, 18.0f, 0.8f);
    craterFloor += getSingleCrater(x, z, 45.0f, 95.0f, 8.0f, 0.4f);
    
    return craterFloor;
}

float domainWarpNoise(float x, float z) {
    float qx = fbm(x + 0.0f,  z + 0.0f);
    float qz = fbm(x + 5.2f,  z + 1.3f);

    float distortionIntensity = 40.0f;
    float baseTerrain = fbm(x + distortionIntensity * qx, z + distortionIntensity * qz);
    
    // Yhdistetään vuoristokohina ja meteoriittikraaterit
    return baseTerrain + craterNoise(x, z);
}
