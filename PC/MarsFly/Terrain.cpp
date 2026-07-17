#include "Terrain.h"
#include "Noise.h"
#include <cmath>
#include <vector>
#include <glm/glm.hpp>

// Luokan oma metodi kutsuu nyt vapaata globaalia kohinafunktiota
float Terrain::getHeight(float x, float z) {
    // Poistettu Terrain:: domainWarpNoise -kutsun edestä
    return domainWarpNoise(static_cast<float>(x), static_cast<float>(z));
}

void Terrain::generate(std::vector<float>& vertices, std::vector<unsigned int>& indices) {
    const float terrainScale = 20.0f; 

    // 1. Vaihe: Luodaan ja tallennetaan korkeudet taulukkoon (tämä pitää olla valmiina ennen normaalien laskentaa)
    for (int z = 0; z < MAP_SIZE; ++z) {
        for (int x = 0; x < MAP_SIZE; ++x) {
            float rawNoise = getHeight(static_cast<float>(x), static_cast<float>(z));
            heightMap[z][x] = rawNoise * terrainScale;
        }
    }

    // 2. Vaihe: Lasketaan normaalit ja rakennetaan vertex-puskuri (9 floatia per vertex)
    for (int z = 0; z < MAP_SIZE; ++z) {
        for (int x = 0; x < MAP_SIZE; ++x) {
            float currentHeight = heightMap[z][x];

            // Luetaan viereisten pisteiden korkeudet. Jos ollaan reunalla, käytetään nykyistä korkeutta.
            float hLeft  = (x > 0) ? heightMap[z][x - 1] : currentHeight;
            float hRight = (x < MAP_SIZE - 1) ? heightMap[z][x + 1] : currentHeight;
            float hDown  = (z > 0) ? heightMap[z - 1][x] : currentHeight;
            float hUp    = (z < MAP_SIZE - 1) ? heightMap[z + 1][x] : currentHeight;

            // Lasketaan pinnan kallistus (tangentit) X- ja Z-akseleiden suuntaan
            // Skaalauskerroin (2.0f) vastaa kahden pisteen välistä etäisyyttä datassa
            glm::vec3 normal(hLeft - hRight, 2.0f, hDown - hUp);
            normal = glm::normalize(normal);

            // 1. PAIKKATIETO (Layout 0: 3 floatia)
            vertices.push_back(static_cast<float>(x));
            vertices.push_back(currentHeight); 
            vertices.push_back(static_cast<float>(z));

            // 2. AITO NORMAALIVEKTORI VALAISTUKSELLE (Layout 1: 3 floatia)
            vertices.push_back(normal.x);
            vertices.push_back(normal.y);
            vertices.push_back(normal.z);

            // 3. APUTIEDOT / TEKSTUURIKOORDINAATIT (Layout 2: 3 floatia)
            // Hyödynnetään nämä paikat maaston UV-koordinaateille väliltä 0.0 - 1.0
            vertices.push_back(static_cast<float>(x) / static_cast<float>(MAP_SIZE));
            vertices.push_back(static_cast<float>(z) / static_cast<float>(MAP_SIZE));
            vertices.push_back(0.0f); // Viimeinen tyhjäksi täytteeksi, jotta 9 floatia täyttyy
        }
    }

    // 3. Vaihe: Indeksipuskurin luonti (pysyy samana)
    for (int z = 0; z < MAP_SIZE - 1; ++z) {
        for (int x = 0; x < MAP_SIZE - 1; ++x) {
            unsigned int topLeft     = z * MAP_SIZE + x;
            unsigned int topRight    = topLeft + 1;
            unsigned int bottomLeft  = (z + 1) * MAP_SIZE + x;
            unsigned int bottomRight = bottomLeft + 1;

            indices.push_back(topLeft);
            indices.push_back(bottomLeft);
            indices.push_back(topRight);

            indices.push_back(topRight);
            indices.push_back(bottomLeft);
            indices.push_back(bottomRight);
        }
    }
}




// Apufunktio barysentrisen korkeuden laskemiseen kolmion sisällä
float barocentricInterpolation(float p1X, float p1Y, float p1Z, 
                               float p2X, float p2Y, float p2Z, 
                               float p3X, float p3Y, float p3Z, 
                               float x, float z) {
    float det = (p2Z - p3Z) * (p1X - p3X) + (p3X - p2X) * (p1Z - p3Z);
    if (std::abs(det) < 1e-6f) return p1Y; // Estetään nollalla jakaminen

    float l1 = ((p2Z - p3Z) * (x - p3X) + (p3X - p2X) * (z - p3Z)) / det;
    float l2 = ((p3Z - p1Z) * (x - p3X) + (p1X - p3X) * (z - p3Z)) / det;
    float l3 = 1.0f - l1 - l2;

    return l1 * p1Y + l2 * p2Y + l3 * p3Y;
}
float Terrain::getHeightAt(float x, float z) {
    if (x < 0.0f || x >= MAP_SIZE - 1 || z < 0.0f || z >= MAP_SIZE - 1) {
        return 0.0f; 
    }

    int gridX = static_cast<int>(std::floor(x));
    int gridZ = static_cast<int>(std::floor(z));

    float coordX = x - gridX;
    float coordZ = z - gridZ;

    // VARMISTA TÄMÄ JÄRJESTYS: [gridZ] on ensimmäinen (rivi), [gridX] on toinen (sarake)
    float h00 = heightMap[gridZ][gridX];         // Ylä-Vasen
    float h10 = heightMap[gridZ][gridX + 1];     // Ylä-Oikea
    float h01 = heightMap[gridZ + 1][gridX];     // Ala-Vasen
    float h11 = heightMap[gridZ + 1][gridX + 1]; // Ala-Oikea

    // Jos pelaaja putoaa yhä läpi diagonaalin kohdalla, vaihda ehto muotoon: (coordX >= coordZ)
    if (coordX <= (1.0f - coordZ)) {
        return barocentricInterpolation(
            0.0f, h00, 0.0f,
            0.0f, h01, 1.0f,
            1.0f, h10, 0.0f,
            coordX, coordZ
        );
    } else {
        return barocentricInterpolation(
            1.0f, h10, 0.0f,
            0.0f, h01, 1.0f,
            1.0f, h11, 1.0f,
            coordX, coordZ
        );
    }
}
