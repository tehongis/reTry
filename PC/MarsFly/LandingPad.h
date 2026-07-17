#ifndef LANDING_PAD_H
#define LANDING_PAD_H

#include <GL/glew.h>
#include <glm/glm.hpp>
#include "Shader.h"
#include "Terrain.h"

class LandingPad {
public:
    LandingPad(glm::vec3 position, glm::vec3 scale);
    ~LandingPad();

    // Päivittää alustan korkeuden maaston mukaan ja piirtää sen
    void draw(Shader& customShader, Terrain& terrain); // Muutettu ottamaan customShader vastaan

    // Palauttaa alustan pinnan korkeuden fysiikkaa varten
    float getSurfaceHeight(float playerX, float playerZ) const;

private:
    unsigned int VAO, VBO;
    glm::vec3 position;
    glm::vec3 scale;

    void setupMesh();
};

#endif // LANDING_PAD_H
