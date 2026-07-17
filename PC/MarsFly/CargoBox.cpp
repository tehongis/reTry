#include "CargoBox.h"
#include <cstdlib>
#include <ctime>
#include <algorithm>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

CargoBox::CargoBox(Terrain& terrain) 
    : velocity(0.0f), attached(false), ropeLength(8.0f), cargoMass(12.0f) {
    
    // Arvotaan satunnainen paikka kartalta (esim. X: 15-110, Z: 15-110, jotta ei osu alustalle)
    std::srand(static_cast<unsigned int>(std::time(nullptr)));
    float rx = 15.0f + static_cast<float>(std::rand() % 95);
    float rz = 15.0f + static_cast<float>(std::rand() % 95);
    float ry = terrain.getHeightAt(rx, rz) + 0.5f; // Laatikon puolikas korkeus

    position = glm::vec3(rx, ry, rz);
    setupMesh();
}

CargoBox::~CargoBox() {
    glDeleteVertexArrays(1, &boxVAO);
    glDeleteBuffers(1, &boxVBO);
    glDeleteVertexArrays(1, &ropeVAO);
    glDeleteBuffers(1, &ropeVBO);
}

void CargoBox::setupMesh() {
    // 3D-KUUTION DATA: 6 sivua x 6 verteksiä = 36 pistettä. Jokaisella pisteellä paikka (3) ja normaali (3) = 6 floatia.
    float boxVertices[] = {
        // Sijainti (X,Y,Z)      // Normaalit (X,Y,Z)
        // 1. Kattopinta
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  1.0f,  0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  1.0f,  0.0f,
        // 2. Etupinta
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
         0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
         0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f,  0.0f,  1.0f,
        // 3. Vasen pinta
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f, -0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f, -0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        -0.5f,  0.5f,  0.5f, -1.0f,  0.0f,  0.0f,
        // 4. Oikea pinta
         0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
         0.5f,  0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
         0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
         0.5f, -0.5f, -0.5f,  1.0f,  0.0f,  0.0f,
         0.5f, -0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
         0.5f,  0.5f,  0.5f,  1.0f,  0.0f,  0.0f,
        // 5. Takapinta
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
         0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
         0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
        // 6. Pohjapinta
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
         0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f,
         0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
         0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, -1.0f,  0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, -1.0f,  0.0f
    };

    glGenVertexArrays(1, &boxVAO);
    glGenBuffers(1, &boxVBO);
    
    glBindVertexArray(boxVAO);
    glBindBuffer(GL_ARRAY_BUFFER, boxVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(boxVertices), boxVertices, GL_STATIC_DRAW);

    // KORJAUS: Stride on nyt tasan 6 * sizeof(float)
    GLsizei stride = 6 * sizeof(float);
    
    // Atribuutti 0: Paikka (X, Y, Z)
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, stride, (void*)0);
    glEnableVertexAttribArray(0);
    
    // Atribuutti 1: Normaalit (X, Y, Z)
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, stride, (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    
    // KORJAUS: Lukitaan kolmas paikka pois käytöstä, jotta se ei ylivuoda muistissa
    glDisableVertexAttribArray(2);

    glBindVertexArray(0);

    glGenVertexArrays(1, &ropeVAO);
    glGenBuffers(1, &ropeVBO);
}

void CargoBox::update(glm::vec3 playerPos, glm::vec3& playerVelocity, float deltaTime, Terrain& terrain) {
    const float MARS_GRAVITY = 3.7f;

    // --- JOS LAATIKKO ON KIINNITETTY ALUKSEEN ---
    if (attached) {
        // 1. Painovoima ja ilmanvastus laatikon omalle nopeudelle
        velocity.y -= MARS_GRAVITY * deltaTime;
        velocity *= (1.0f - 0.5f * deltaTime);

        // Päivitetään laatikon paikka
        position += velocity * deltaTime;

        // 2. Köysijännitys ja heiluriliike
        glm::vec3 ropeVec = position - playerPos;
        float currentLength = glm::length(ropeVec);

        if (currentLength > ropeLength) {
            glm::vec3 ropeDir = glm::normalize(ropeVec);
            float stretch = currentLength - ropeLength;

            float springK = 150.0f; 
            glm::vec3 pullForce = -ropeDir * stretch * springK;

            velocity += (pullForce / cargoMass) * deltaTime;
            position = playerPos + ropeDir * ropeLength;

            // Laatikon paino vaikuttaa alukseen (Newton III)
            playerVelocity -= (pullForce * 0.4f) * deltaTime; 
        }

        // Maastotörmäys laahaavalle laatikolle
        float groundY = terrain.getHeightAt(position.x, position.z) + 0.5f;
        if (position.y < groundY) {
            position.y = groundY;
            velocity.y = std::max(0.0f, velocity.y);
            velocity.x *= (1.0f - 2.0f * deltaTime);
            velocity.z *= (1.0f - 2.0f * deltaTime);
        }
    } 
    // --- JOS LAATIKKO ON IRTI ALUKSESTA (Heitetty lentävä laatikko tai maassa nököttävä) ---
    else {
        // KORJAUS: POIMINTAMEKANIIKKA TAKAISIN MUKAAN!
        // Jos alus on laatikon yläpuolella lähellä (etäisyys alle 4 yksikköä), se tarttuu dynaamisesti mukaan
        float distToPlayer = glm::distance(playerPos, position);
        if (distToPlayer < 4.0f && playerPos.y > position.y) {
            attached = true;
            return; // Keskeytetään tämä kehys, jotta ensi kehyksessä siirrytään suoraan ylempään attached-lohkoon
        }

        float groundY = terrain.getHeightAt(position.x, position.z) + 0.5f;

        // Jos laatikko on ilmassa (heiton jälkeen), lasketaan sille ballistinen lentorata
        if (position.y > groundY + 0.001f) {
            velocity.y -= MARS_GRAVITY * deltaTime; // Painovoima vetää alaspäin
            velocity *= (1.0f - 0.2f * deltaTime);   // Kevyt ilmanvastus lennon aikana
            position += velocity * deltaTime;       // Liikutetaan heittosuuntaan
        }

        // Dynaaminen maastotörmäys heitetylle laatikolle (laskeutuminen)
        groundY = terrain.getHeightAt(position.x, position.z) + 0.5f;
        if (position.y <= groundY) {
            position.y = groundY;
            
            // Jos laatikolla oli vielä pystysuuntaista pudotusnopeutta, nollataan se
            if (velocity.y < 0.0f) {
                velocity.y = 0.0f;
            }

            // Kitka maata vasten: laatikko liukuu hetken aikaa maassa heiton voimasta ennen kuin pysähtyy
            velocity.x *= (1.0f - 5.0f * deltaTime);
            velocity.z *= (1.0f - 5.0f * deltaTime);

            // Jos liike-energia on hiipunut olemattomaksi, lukitaan nopeus täysin nollaan (pysähtyy)
            if (glm::length(glm::vec2(velocity.x, velocity.z)) < 0.1f) {
                velocity = glm::vec3(0.0f);
            }
        }
    }
}



void CargoBox::draw(Shader& shader, glm::vec3 playerPos) {
    // 1. PIIRRETÄÄN LAATIKKO
    glm::mat4 boxModel = glm::mat4(1.0f);
    boxModel = glm::translate(boxModel, position);
    boxModel = glm::scale(boxModel, glm::vec3(1.2f));
    shader.setMat4("model", glm::value_ptr(boxModel));

    glBindVertexArray(boxVAO);
    // Varmistetaan että vain tarvittavat attribuutit ovat päällä kuutiolle
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    glDisableVertexAttribArray(2); 

    glDrawArrays(GL_TRIANGLES, 0, 36);

    // 2. PIIRRETÄÄN KÖYSI
    if (attached) {
        float ropeLines[] = {
            playerPos.x, playerPos.y - 1.0f, playerPos.z,
            position.x,  position.y + 0.5f,  position.z  
        };

        glBindVertexArray(ropeVAO);
        glBindBuffer(GL_ARRAY_BUFFER, ropeVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(ropeLines), ropeLines, GL_DYNAMIC_DRAW);
        
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
        glEnableVertexAttribArray(0);
        glDisableVertexAttribArray(1); // Köysi ei tarvitse normaaleja!

        glm::mat4 identity = glm::mat4(1.0f);
        shader.setMat4("model", glm::value_ptr(identity));

        glLineWidth(3.0f); 
        glDrawArrays(GL_LINES, 0, 2);
        glLineWidth(1.0f); 
    }
    glBindVertexArray(0);
}

        
bool CargoBox::isDelivered(glm::vec3 padPos, float padRadius) const {
    // 1. Lasketaan dynaaminen etäisyys vaakatasossa (XZ-tasossa alustan keskipisteeseen)
    float distanceXZ = glm::length(glm::vec2(position.x, position.z) - glm::vec2(padPos.x, padPos.z));
    
    // 2. Koska alusta sijaitsee maassa, riittää että laatikko tuodaan alustan dynaamisen säteen sisään
    // ja se roikkuu tarpeeksi matalalla (alle 6 yksikköä alustan pinnasta)
    return (distanceXZ < padRadius && position.y < (padPos.y + 6.0f));
}

void CargoBox::resetPosition(Terrain& terrain) {
    // Irrotetaan laatikko aluksesta ja nollataan sen fysiikat
    attached = false;
    velocity = glm::vec3(0.0f);

    // Arvotaan uusi paikka kartalta (X: 15-110, Z: 15-110)
    float rx = 15.0f + static_cast<float>(std::rand() % 95);
    float rz = 15.0f + static_cast<float>(std::rand() % 95);
    float ry = terrain.getHeightAt(rx, rz) + 0.5f; // Nostetaan hieman maaston yläpuolelle

    position = glm::vec3(rx, ry, rz);
}

void CargoBox::cutRope() {
    if (attached) {
        attached = false;
    }
}
