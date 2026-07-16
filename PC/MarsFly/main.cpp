#include <SDL2/SDL.h>
#include <GL/glew.h>
#include <iostream>
#include <vector>
#include <cmath>
#include <algorithm>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include "Camera.h"
#include "Terrain.h"
#include "Shader.h"

int main(int argc, char* argv[]) {
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        std::cerr << "SDL alustus epäonnistui: " << SDL_GetError() << "\n";
        return -1;
    }
    
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    SDL_Window* window = SDL_CreateWindow("Mars Simulator - F1-F4 Shader Styles", 
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 1280, 720, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN|SDL_WINDOW_FULLSCREEN_DESKTOP);
    
    if (!window) {
        std::cerr << "Ikkunan luonti epäonnistui: " << SDL_GetError() << "\n";
        SDL_Quit();
        return -1;
    }

    SDL_GLContext glContext = SDL_GL_CreateContext(window);

    glewExperimental = GL_TRUE;
    if (glewInit() != GLEW_OK) {
        std::cerr << "GLEW alustus epäonnistui!\n";
        SDL_GL_DeleteContext(glContext);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return -1;
    }

    glEnable(GL_DEPTH_TEST);

    Shader terrainShader("Shaders/shader.vert", "Shaders/shader.frag");

    Camera camera(glm::vec3(64.0f, 25.0f, 100.0f));
    Terrain terrain;

    std::vector<float> vertices;
    std::vector<unsigned int> indices;
    terrain.generate(vertices, indices);

    unsigned int VAO, VBO, EBO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);

    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(float), vertices.data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned int), indices.data(), GL_STATIC_DRAW);

    GLsizei stride = 9 * sizeof(float);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, stride, (void*)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, stride, (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, stride, (void*)(6 * sizeof(float)));
    glEnableVertexAttribArray(2);

    bool running = true;
    SDL_Event event;
    SDL_SetRelativeMouseMode(SDL_TRUE);

    glm::mat4 model = glm::mat4(1.0f);
    glm::mat4 projection = glm::perspective(glm::radians(45.0f), 1280.0f / 720.0f, 0.1f, 1000.0f);

    float deltaTime = 0.0f;
    float lastFrame = 0.0f;
    
    const float MARS_GRAVITY = 3.7f; 
    const float FLIGHT_SPEED = 20.0f; 
    const float HOVER_HEIGHT = 2.5f;  

    // UUSI: Aktiivinen shader-tyyli globaalina tilana (oletuksena 1 = vakio)
    int currentRenderMode = 1;

    while (running) {
        float currentFrame = static_cast<float>(SDL_GetTicks()) / 1000.0f;
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;

        if (deltaTime > 0.1f) deltaTime = 0.1f;

        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) running = false;
            
            if (event.type == SDL_KEYDOWN) {
                if (event.key.keysym.sym == SDLK_ESCAPE) running = false;
                
                // UUSI: Kuunnellaan tyylinvaihtonäppäimiä (F1 - F4)
                if (event.key.keysym.sym == SDLK_F1) currentRenderMode = 1;
                if (event.key.keysym.sym == SDLK_F2) currentRenderMode = 2;
                if (event.key.keysym.sym == SDLK_F3) currentRenderMode = 3;
                if (event.key.keysym.sym == SDLK_F4) currentRenderMode = 4;
            }
            if (event.type == SDL_MOUSEMOTION) {
                camera.updateDirection(static_cast<float>(event.motion.xrel), static_cast<float>(event.motion.yrel));
            }
        }

        const Uint8* keystate = SDL_GetKeyboardState(NULL);
        float currentSpeed = FLIGHT_SPEED * deltaTime;

        if (keystate[SDL_SCANCODE_W]) camera.moveForward(currentSpeed);
        if (keystate[SDL_SCANCODE_S]) camera.moveForward(-currentSpeed);
        if (keystate[SDL_SCANCODE_A]) camera.moveStrafe(-currentSpeed);
        if (keystate[SDL_SCANCODE_D]) camera.moveStrafe(currentSpeed);
        if (keystate[SDL_SCANCODE_SPACE]) camera.moveUp(currentSpeed);
        if (keystate[SDL_SCANCODE_LCTRL]) camera.moveUp(-currentSpeed);

        camera.moveUp(-MARS_GRAVITY * deltaTime);

        float terrainHeight = terrain.getHeightAt(camera.position.x, camera.position.z);
        float minAllowedHeight = terrainHeight + HOVER_HEIGHT;
        if (camera.position.y < minAllowedHeight) {
            camera.position.y = minAllowedHeight;
        }

        // Taustaväri mukautuu valitun teeman mukaan (esim. pimeänäössä musta avaruus)
        if (currentRenderMode == 2) glClearColor(0.0f, 0.01f, 0.0f, 1.0f);
        else if (currentRenderMode == 4) glClearColor(0.02f, 0.01f, 0.02f, 1.0f);
        else glClearColor(0.15f, 0.06f, 0.04f, 1.0f);
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        terrainShader.use();

        // UUSI: Lähetetään valittu renderöintitila shaderille
        terrainShader.setInt("renderMode", currentRenderMode);

        glm::mat4 view = camera.getViewMatrix();
        terrainShader.setMat4("model", glm::value_ptr(model));
        terrainShader.setMat4("view", glm::value_ptr(view));
        terrainShader.setMat4("projection", glm::value_ptr(projection));

        terrainShader.setVec3("lightDir", -0.5f, -1.0f, -0.3f);
        terrainShader.setVec3("lightColor", 1.0f, 0.85f, 0.75f);

        glBindVertexArray(VAO);
        glDrawElements(GL_TRIANGLES, indices.size(), GL_UNSIGNED_INT, 0);

        SDL_GL_SwapWindow(window);
    }

    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteBuffers(1, &EBO);
    SDL_GL_DeleteContext(glContext);
    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
