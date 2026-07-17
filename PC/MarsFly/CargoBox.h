#ifndef CARGO_BOX_H
#define CARGO_BOX_H

#include <GL/glew.h>
#include <glm/glm.hpp>
#include "Shader.h"
#include "Terrain.h"

class CargoBox {
public:
    CargoBox(Terrain& terrain);
    ~CargoBox();

    // Päivittää köyden ja laatikon fysiikat suhteessa alukseen
    void update(glm::vec3 playerPos, glm::vec3& playerVelocity, float deltaTime, Terrain& terrain);
    
    // Piirtää laatikon ja köyden
    void draw(Shader& shader, glm::vec3 playerPos);

    // Tarkistaa onko laatikko toimitettu turvallisesti alustalle
    bool isDelivered(glm::vec3 padPos, float padRadius) const;

    void resetPosition(Terrain& terrain);

    void cutRope();


    glm::vec3 getPosition() const { return position; }
    bool isAttached() const { return attached; }

private:
    unsigned int boxVAO, boxVBO;
    unsigned int ropeVAO, ropeVBO;

    glm::vec3 position;
    glm::vec3 velocity;
    
    bool attached;          // Onko laatikko kiinni aluksessa
    float ropeLength;       // Köyden maksimipituus
    float cargoMass;        // Laatikon paino (vaikuttaa aluksen inertiaan)

    void setupMesh();
};

#endif // CARGO_BOX_H
