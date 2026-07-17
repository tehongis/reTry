#ifndef CAMERA_H
#define CAMERA_H

#include <glm/glm.hpp>

class Camera {
public:
    glm::vec3 position;
    glm::vec3 front;
    glm::vec3 up;
    glm::vec3 right;
    glm::vec3 worldUp;

    float yaw;
    float pitch;

    // Aluksen nopeusmuuttujat
    float velocityForward;
    float velocityStrafe;
    float velocityUp; // <--- LISÄÄ TÄMÄ RIVI TÄHÄN

    // Vakiot (Varmista että nämä löytyvät tai säädä arvoja)
    const float ACCELERATION = 20.0f;
    const float MAX_SPEED = 15.0f;
    const float DRAG = 0.15f;

    Camera(glm::vec3 startPosition);
    glm::mat4 getViewMatrix();
    void updateDirection(float xoffset, float yoffset);
    void moveForward(bool active, float direction, float deltaTime);
    void moveStrafe(bool active, float direction, float deltaTime);
    
    // Päivitä moveUp vastaamaan uutta muotoa:
    void moveUp(bool active, float direction, float deltaTime); 
    
    void updatePosition(float deltaTime);
};

#endif
