#include "Terrain.h"
#include <cmath>

float Terrain::noise(int x, int z) {
    int n = x + z * 57;
    n = (n << 13) ^ n;
    return (1.0f - ((n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0f);
}

float Terrain::getNoiseHeight(float x, float z) {
    float total = 0.0f;
    float frequency = 0.05f;
    float amplitude = 12.0f;
    for (int i = 0; i < 4; i++) {
        total += noise(static_cast<int>(x * frequency), static_cast<int>(z * frequency)) * amplitude;
        frequency *= 2.0f;
        amplitude *= 0.4f;
    }
    return total;
}

void Terrain::generate(std::vector<float>& vertices, std::vector<unsigned int>& indices) {
    for (int z = 0; z < MAP_SIZE; ++z) {
        for (int x = 0; x < MAP_SIZE; ++x) {
            heightMap[z][x] = getNoiseHeight(static_cast<float>(x), static_cast<float>(z));
        }
    }

    float normals[MAP_SIZE][MAP_SIZE][3];
    for (int z = 0; z < MAP_SIZE; ++z) {
        for (int x = 0; x < MAP_SIZE; ++x) {
            float hL = (x > 0) ? heightMap[z][x-1] : heightMap[z][x];
            float hR = (x < MAP_SIZE-1) ? heightMap[z][x+1] : heightMap[z][x];
            float hD = (z > 0) ? heightMap[z-1][x] : heightMap[z][x];
            float hU = (z < MAP_SIZE-1) ? heightMap[z+1][x] : heightMap[z][x];
            
            float nx = hL - hR;
            float ny = 2.0f;
            float nz = hD - hU;
            float len = std::sqrt(nx*nx + ny*ny + nz*nz);
            
            normals[z][x][0] = nx / len;
            normals[z][x][1] = ny / len;
            normals[z][x][2] = nz / len;
        }
    }

    for (int z = 0; z < MAP_SIZE; ++z) {
        for (int x = 0; x < MAP_SIZE; ++x) {
            vertices.push_back(static_cast<float>(x));
            vertices.push_back(heightMap[z][x]);
            vertices.push_back(static_cast<float>(z));

            float hFactor = (heightMap[z][x] + 10.0f) / 25.0f;
            if (hFactor < 0.0f) hFactor = 0.0f;
            if (hFactor > 1.0f) hFactor = 1.0f;
            vertices.push_back(0.6f + hFactor * 0.3f);
            vertices.push_back(0.2f + hFactor * 0.15f);
            vertices.push_back(0.1f + hFactor * 0.05f);

            vertices.push_back(normals[z][x][0]);
            vertices.push_back(normals[z][x][1]);
            vertices.push_back(normals[z][x][2]);
        }
    }

    for (int z = 0; z < MAP_SIZE - 1; ++z) {
        for (int x = 0; x < MAP_SIZE - 1; ++x) {
            unsigned int topLeft = z * MAP_SIZE + x;
            unsigned int topRight = topLeft + 1;
            unsigned int bottomLeft = (z + 1) * MAP_SIZE + x;
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

// Palauttaa maaston tarkan korkeuden mistä tahansa kohdasta (blineaarinen interpolointi)
float Terrain::getHeightAt(float x, float z) {
    if (x < 0.0f || x >= MAP_SIZE - 1 || z < 0.0f || z >= MAP_SIZE - 1) {
        return 0.0f; // Maaston ulkopuolella
    }

    int gridX = static_cast<int>(std::floor(x));
    int gridZ = static_cast<int>(std::floor(z));

    float coordX = x - gridX;
    float coordZ = z - gridZ;

    // Interpoloidaan korkeus neliön neljän kulman välillä
    float h00 = heightMap[gridZ][gridX];
    float h10 = heightMap[gridZ][gridX + 1];
    float h01 = heightMap[gridZ + 1][gridX];
    float h11 = heightMap[gridZ + 1][gridX + 1];

    float txt0 = (1.0f - coordX) * h00 + coordX * h10;
    float txt1 = (1.0f - coordX) * h01 + coordX * h11;

    return (1.0f - coordZ) * txt0 + coordZ * txt1;
}
