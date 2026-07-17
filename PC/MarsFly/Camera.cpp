#include "Camera.h"
#include <glm/gtc/matrix_transform.hpp>
#include <algorithm>

Camera::Camera(glm::vec3 startPosition) {
    position = startPosition;
    worldUp = glm::vec3(0.0f, 1.0f, 0.0f);
    yaw = -90.0f;
    pitch = 0.0f;
    front = glm::vec3(0.0f, 0.0f, -1.0f);
    up = glm::vec3(0.0f, 1.0f, 0.0f);
    right = glm::vec3(1.0f, 0.0f, 0.0f);
    
    // Alustetaan nopeudet nollaksi
    velocityForward = 0.0f;
    velocityStrafe = 0.0f;
    velocityUp = 0.0f; // UUSI JÄSENMUUTTUJA PYSTYLIIKKEELLE
}

glm::mat4 Camera::getViewMatrix() {
    return glm::lookAt(position, position + front, up);
}

void Camera::updateDirection(float xoffset, float yoffset) {
    float sensitivity = 0.1f;
    yaw += xoffset * sensitivity;
    pitch -= yoffset * sensitivity;

    if (pitch > 89.0f) pitch = 89.0f;
    if (pitch < -89.0f) pitch = -89.0f;

    glm::vec3 newFront;
    newFront.x = cos(glm::radians(yaw)) * cos(glm::radians(pitch));
    newFront.y = sin(glm::radians(pitch));
    newFront.z = sin(glm::radians(yaw)) * cos(glm::radians(pitch));
    front = glm::normalize(newFront);

    right = glm::normalize(glm::cross(front, worldUp));
    up    = glm::normalize(glm::cross(right, front));
}

void Camera::moveForward(bool active, float direction, float deltaTime) {
    if (active) {
        velocityForward += direction * ACCELERATION * deltaTime;
        velocityForward = std::clamp(velocityForward, -MAX_SPEED, MAX_SPEED);
    }
}

void Camera::moveStrafe(bool active, float direction, float deltaTime) {
    if (active) {
        velocityStrafe += direction * ACCELERATION * deltaTime;
        velocityStrafe = std::clamp(velocityStrafe, -MAX_SPEED, MAX_SPEED);
    }
}

// UUSI JA PARANNETTU METODI PYSTYSUUNTAISELLE OHJAUKSELLE
void Camera::moveUp(bool active, float direction, float deltaTime) {
    if (active) {
        // ACCELERATION voi olla sama tai alukselle ominainen pystysuuntainen teho
        velocityUp += direction * ACCELERATION * deltaTime;
        velocityUp = std::clamp(velocityUp, -MAX_SPEED, MAX_SPEED);
    }
}

void Camera::updatePosition(float /*deltaTime*/) {
    // Jätetään tyhjäksi, liike lasketaan InputManagerissa
}
