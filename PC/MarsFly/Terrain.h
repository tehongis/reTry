#ifndef TERRAIN_H
#define TERRAIN_H

#include <vector>

class Terrain {
private:
    static const int MAP_SIZE = 512;
    float heightMap[MAP_SIZE][MAP_SIZE];

    float noise(int x, int z);
    float getNoiseHeight(float x, float z);

public:
    void generate(std::vector<float>& vertices, std::vector<unsigned int>& indices);
    float getHeightAt(float x, float z); // Uusi funktio törmäystarkistukseen
};

#endif
