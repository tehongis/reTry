#ifndef ENGINE_H
#define ENGINE_H

#include <SDL2/SDL.h>
#include <SDL2/SDL_mixer.h>

#include <GL/glew.h>
#include <vector>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

#include "Camera.h"
#include "Terrain.h"
#include "Shader.h"
#include "LandingPad.h"
#include "CargoBox.h"
#include "InputManager.h"

class Engine {
public:
    Engine();
    ~Engine();

    bool init(const char* title, int width, int height);
    void run();
    void shutdown();

private:
    void processInput();
    void update(float deltaTime);
    void render();
    
    void initBuffers();

    // Ääniefektit
    Mix_Chunk* m_sndThruster;
    Mix_Chunk* m_sndPickup;
    Mix_Chunk* m_sndDelivery;

    // Seurataan soiko moottori parhaillaan tietyllä äänikanavalla
    int m_thrusterChannel; 
    
    bool m_wasAttachedLastFrame; // Apumuuttuja poimintaäänen dynaamiseen 

    SDL_Event m_event; // <--- LISÄÄ TÄMÄ RIVI TÄHÄN
    
    // Akatustiedot ja SDL/GL konteksti
    SDL_Window* m_window;
    SDL_GLContext m_glContext;
    int m_screenWidth;
    int m_screenHeight;
    bool m_isRunning;

    // Pelisilmukan ajoitusmuuttujat
    float m_deltaTime;
    float m_lastFrame;
    bool m_missionAccomplished;
    float m_startPadY;

    // Pelioliot ja hallintaluokat
    Camera m_camera;
    Terrain m_terrain;
    InputManager m_inputManager;
    LandingPad* m_landingPad;
    CargoBox* m_cargoBox;

    // Shaderit
    Shader* m_terrainShader;
    Shader* m_padShader;
    Shader* m_radarShader;
    Shader* m_boxShader;

    // OpenGL Puskurit (VAO, VBO, EBO)
    unsigned int m_terrainVAO, m_terrainVBO, m_terrainEBO;
    unsigned int m_radarVAO, m_radarVBO;
    size_t m_terrainIndicesCount;
};

#endif // ENGINE_H
