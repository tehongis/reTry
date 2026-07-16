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

    Camera(glm::vec3 startPosition);
    glm::mat4 getViewMatrix();
    void updateDirection(float xoffset, float yoffset);
    void moveForward(float speed);
    void moveStrafe(float speed);
    void moveUp(float speed); // Uusi funktio pystysuuntaiseen liikkeeseen
};

#endif
