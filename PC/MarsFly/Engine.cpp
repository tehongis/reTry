#include "Engine.h"
#include <iostream>

Engine::Engine() 
    : m_window(nullptr), m_glContext(nullptr), m_screenWidth(1280), m_screenHeight(720), m_isRunning(false),
      m_deltaTime(0.0f), m_lastFrame(0.0f), m_missionAccomplished(false), m_startPadY(0.0f),
      m_camera(glm::vec3(64.0f, 25.0f, 100.0f)), m_landingPad(nullptr), m_cargoBox(nullptr),
      m_terrainShader(nullptr), m_padShader(nullptr), m_radarShader(nullptr),
      m_terrainVAO(0), m_terrainVBO(0), m_terrainEBO(0), m_radarVAO(0), m_radarVBO(0), m_terrainIndicesCount(0) {
}

Engine::~Engine() {
    shutdown();
}

bool Engine::init(const char* title, int width, int height) {
    m_screenWidth = width;
    m_screenHeight = height;

    // 1. SDL alustus
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        std::cerr << "SDL alustus epäonnistui: " << SDL_GetError() << "\n";
        return false;
    }

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);

    // --- Sijoita tämä Engine::init() -metodin loppupuolelle ---
    // Alustetaan audiojärjestelmä: 44100Hz, 16-bit stereo, 2048 tavun puskuri
    if (Mix_OpenAudio(44100, MIX_DEFAULT_FORMAT, 2, 2048) < 0) {
        std::cerr << "SDL_mixer alustus epäonnistui: " << Mix_GetError() << "\n";
        return false;
    }

    // Ladataan äänitiedostot (varmista että tiedostot löytyvät näistä poluista)
    m_sndThruster = Mix_LoadWAV("Sounds/thruster.wav");
    m_sndPickup   = Mix_LoadWAV("Sounds/pickup.wav");
    m_sndDelivery = Mix_LoadWAV("Sounds/delivery.wav");

    m_thrusterChannel = -1; 
    m_wasAttachedLastFrame = false;

    m_window = SDL_CreateWindow(title, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, 
                                m_screenWidth, m_screenHeight, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);
    if (!m_window) {
        std::cerr << "Ikkunan luonti epäonnistui: " << SDL_GetError() << "\n";
        SDL_Quit();
        return false;
    }

    m_glContext = SDL_GL_CreateContext(m_window);

    // 2. GLEW alustus
    glewExperimental = GL_TRUE;
    if (glewInit() != GLEW_OK) {
        std::cerr << "GLEW alustus epäonnistui!\n";
        return false;
    }

    glEnable(GL_DEPTH_TEST);
    SDL_SetRelativeMouseMode(SDL_TRUE);

    // 3. Shaderien ja peliobjektien allokointi
    m_terrainShader = new Shader("Shaders/shader.vert", "Shaders/shader.frag");
    m_padShader     = new Shader("Shaders/pad.vert", "Shaders/pad.frag");
    m_radarShader   = new Shader("Shaders/radar.vert", "Shaders/radar.frag");
    m_boxShader     = new Shader("Shaders/box.vert", "Shaders/box.frag");

    m_startPadY = m_terrain.getHeightAt(64.0f, 64.0f);
    m_landingPad = new LandingPad(glm::vec3(64.0f, m_startPadY, 64.0f), glm::vec3(12.0f, 1.5f, 12.0f));
    m_cargoBox = new CargoBox(m_terrain);

    // 4. Alustetaan puskurit
    initBuffers();

    m_isRunning = true;
    return true;
}




void Engine::initBuffers() {
    // Maaston puskurit
    std::vector<float> vertices;
    std::vector<unsigned int> indices;
    m_terrain.generate(vertices, indices);
    m_terrainIndicesCount = indices.size();

    glGenVertexArrays(1, &m_terrainVAO);
    glGenBuffers(1, &m_terrainVBO);
    glGenBuffers(1, &m_terrainEBO);

    glBindVertexArray(m_terrainVAO);
    glBindBuffer(GL_ARRAY_BUFFER, m_terrainVBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(float), vertices.data(), GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_terrainEBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned int), indices.data(), GL_STATIC_DRAW);

    GLsizei stride = 9 * sizeof(float);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, stride, (void*)0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, stride, (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, stride, (void*)(6 * sizeof(float)));
    glEnableVertexAttribArray(2);



    // --- TUTKA 2D QUAD PUSKURIT ---
    float radarQuadVertices[] = {
        -1.0f,  1.0f,
        -1.0f, -1.0f,
         1.0f, -1.0f,

        -1.0f,  1.0f,
         1.0f, -1.0f,
         1.0f,  1.0f
    };

    glGenVertexArrays(1, &m_radarVAO);
    glGenBuffers(1, &m_radarVBO);
    
    glBindVertexArray(m_radarVAO);
    glBindBuffer(GL_ARRAY_BUFFER, m_radarVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(radarQuadVertices), radarQuadVertices, GL_STATIC_DRAW);
    
    // Atribuutti 0: Vain 2 floatia per piste (X, Y)
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    // KORJAUS STACK SMASHINGIIN: Sammutetaan attribuutit 1 ja 2 tämän VAO:n osalta,
    // jotta muiden olioiden (maasto/alusta) jättämät tilat eivät yritä lukea olematonta muistia!
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);

    glBindVertexArray(0);

}

void Engine::update(float deltaTime) {
    // 1. PÄIVITETÄÄN PELIFYSIIKAT
    m_inputManager.updateFlightPhysics(m_camera, m_terrain, *m_landingPad, *m_cargoBox, deltaTime);

    // 2. MOOTTORIN ÄÄNI (Thruster Loop)
    const Uint8* keystate = SDL_GetKeyboardState(NULL);
    
    // KORJAUS: Vaihdettu SDL_SCANCODE_SPACE -> SDL_SCANCODE_LSHIFT äänen dynaamiseen liipaisuun
    bool isThrusting = keystate[SDL_SCANCODE_W] || keystate[SDL_SCANCODE_S] ||
                       keystate[SDL_SCANCODE_A] || keystate[SDL_SCANCODE_D] ||
                       keystate[SDL_SCANCODE_SPACE] || keystate[SDL_SCANCODE_LCTRL];


    if (isThrusting) {
        if (m_thrusterChannel == -1 || Mix_Playing(m_thrusterChannel) == 0) {
            m_thrusterChannel = Mix_PlayChannel(-1, m_sndThruster, -1);
        }
    } else {
        if (m_thrusterChannel != -1 && Mix_Playing(m_thrusterChannel) != 0) {
            Mix_HaltChannel(m_thrusterChannel);
            m_thrusterChannel = -1;
        }
    }

    // 3. LAATIKKOON TARTTUMINEN (Pickup One-shot)
    bool isAttachedNow = m_cargoBox->isAttached();
    if (isAttachedNow && !m_wasAttachedLastFrame) {
        Mix_PlayChannel(-1, m_sndPickup, 0); 
    }
    m_wasAttachedLastFrame = isAttachedNow;

    // 4. DYNAAMINEN MAALITUNNISTUS JA LOPUTON PELISILMUKKA
    float padSurfaceY = m_landingPad->getSurfaceHeight(64.0f, 64.0f);
    glm::vec3 currentPadPos = glm::vec3(64.0f, padSurfaceY, 64.0f);

    if (!m_missionAccomplished && m_cargoBox->isDelivered(currentPadPos, 6.0f)) {
        std::cout << "TEHTÄVÄ SUORITETTU! Rahti on tuotu alustalle.\n";
        
        Mix_PlayChannel(-1, m_sndDelivery, 0); // Soitetaan voittoääni
        
        if (m_thrusterChannel != -1) {
            Mix_HaltChannel(m_thrusterChannel);
            m_thrusterChannel = -1;
        }

        m_missionAccomplished = true;
        
        // Pysäytetään peli hetkeksi (2 sekuntia), jotta voittoääni kuuluu nätisti ennen uutta kierrosta
        SDL_Delay(2000);

        // KORJAUS: Irrotetaan laatikko, arvotaan uusi paikka ja nollataan tehtävätila uutta kierrosta varten
        m_cargoBox->resetPosition(m_terrain);
        m_missionAccomplished = false; 
        m_wasAttachedLastFrame = false;
    }
}



void Engine::run() {
    while (m_isRunning) {
        float currentFrame = static_cast<float>(SDL_GetTicks()) / 1000.0f;
        m_deltaTime = currentFrame - m_lastFrame;
        m_lastFrame = currentFrame;

        if (m_deltaTime > 0.1f) m_deltaTime = 0.1f;

        // 1. Käsitellään tapahtumat luokan yhteisellä m_event-muuttujalla
        processInput();
        
        // 2. Päivitetään fysiikat
        update(m_deltaTime);
        
        // 3. Renderöidään maailma
        render();

        SDL_GL_SwapWindow(m_window);
    }
}

void Engine::processInput() {
    // KORJAUS: Ei enää m_event-muuttujaa parametrina, InputManager hoitaa jonon paikallisesti!
    m_inputManager.processEvents(m_camera, m_isRunning);
}


void Engine::render() {

    glClearColor(0.48f, 0.24f, 0.15f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glm::mat4 model = glm::mat4(1.0f);
    glm::mat4 view = m_camera.getViewMatrix();
    glm::mat4 projection = glm::perspective(glm::radians(45.0f), static_cast<float>(m_screenWidth) / m_screenHeight, 0.1f, 1000.0f);
    
    // KORJAUS: Varmistetaan, ettei normalisointi koskaan jaa nollalla, mikä rikkoi muistipinon
    glm::vec3 rawLightDir = glm::vec3(m_camera.front.x, m_camera.front.y - 0.4f, m_camera.front.z);
    if (glm::length(rawLightDir) < 0.001f) {
        rawLightDir = glm::vec3(0.0f, -1.0f, 0.0f);
    }
    glm::vec3 playerLightDir = glm::normalize(rawLightDir);

    // 1. Maaston piirto
    m_terrainShader->use();
    m_terrainShader->setMat4("model", glm::value_ptr(model));
    m_terrainShader->setMat4("view", glm::value_ptr(view));
    m_terrainShader->setMat4("projection", glm::value_ptr(projection));
    m_terrainShader->setVec3("lightDir", -0.5f, -1.0f, -0.3f);
    m_terrainShader->setVec3("lightColor", 1.0f, 0.85f, 0.75f);
    m_terrainShader->setVec3("viewPos", m_camera.position.x, m_camera.position.y, m_camera.position.z);
    m_terrainShader->setVec3("viewDir", m_camera.front.x, m_camera.front.y, m_camera.front.z);
    m_terrainShader->setVec3("playerLightPos", m_camera.position.x, m_camera.position.y, m_camera.position.z);
    m_terrainShader->setVec3("playerLightDir", playerLightDir.x, playerLightDir.y, playerLightDir.z);
    m_terrainShader->setVec3("playerLightColor", 0.9f, 0.85f, 0.7f);

    GLint terrainTimeLoc = glGetUniformLocation(m_terrainShader->ID, "time");
    if (terrainTimeLoc != -1) glUniform1f(terrainTimeLoc, m_lastFrame);

    glBindVertexArray(m_terrainVAO);
    glDrawElements(GL_TRIANGLES, static_cast<GLsizei>(m_terrainIndicesCount), GL_UNSIGNED_INT, 0);

    // 2. Alustan ja laatikon piirto
    m_padShader->use();
    m_padShader->setMat4("view", glm::value_ptr(view));
    m_padShader->setMat4("projection", glm::value_ptr(projection));
    m_padShader->setVec3("lightDir", -0.5f, -1.0f, -0.3f);
    m_padShader->setVec3("lightColor", 1.0f, 0.85f, 0.75f);
    m_padShader->setVec3("viewPos", m_camera.position.x, m_camera.position.y, m_camera.position.z);
    m_padShader->setVec3("playerLightPos", m_camera.position.x, m_camera.position.y, m_camera.position.z);
    m_padShader->setVec3("playerLightDir", playerLightDir.x, playerLightDir.y, playerLightDir.z);
    m_padShader->setVec3("playerLightColor", 0.9f, 0.85f, 0.7f);
    
    GLint padTimeLoc = glGetUniformLocation(m_padShader->ID, "time");
    if (padTimeLoc != -1) glUniform1f(padTimeLoc, m_lastFrame);

    m_landingPad->draw(*m_padShader, m_terrain);

    // 2.5 Rahtilaatikon piirto omalla shaderilla
    m_boxShader->use();
    m_boxShader->setMat4("view", glm::value_ptr(view));
    m_boxShader->setMat4("projection", glm::value_ptr(projection));
    m_boxShader->setVec3("lightDir", -0.5f, -1.0f, -0.3f);
    m_boxShader->setVec3("lightColor", 1.0f, 0.85f, 0.75f);
    m_boxShader->setVec3("viewPos", m_camera.position.x, m_camera.position.y, m_camera.position.z);
    
    // Aluksen valonheittimen tiedot laatikolle
    m_boxShader->setVec3("playerLightPos", m_camera.position.x, m_camera.position.y, m_camera.position.z);
    m_boxShader->setVec3("playerLightDir", playerLightDir.x, playerLightDir.y, playerLightDir.z);
    m_boxShader->setVec3("playerLightColor", 0.9f, 0.85f, 0.7f);
    
    // Välitetään aika vilkkumista varten ja tieto siitä, onko rahti kiinni aluksessa
    GLint boxTimeLoc = glGetUniformLocation(m_boxShader->ID, "time");
    if (boxTimeLoc != -1) glUniform1f(boxTimeLoc, m_lastFrame);
    m_boxShader->setInt("cargoAttached", m_cargoBox->isAttached() ? 1 : 0);

    // Kutsutaan dynaamista draw-metodia uudella shaderilla
    m_cargoBox->draw(*m_boxShader, m_camera.position);

    // 3. HUD / Tutka (Kaiken muun päälle)
    glDisable(GL_DEPTH_TEST);
    m_radarShader->use();
    
    GLint resLoc = glGetUniformLocation(m_radarShader->ID, "screenResolution");
    if (resLoc != -1) glUniform2f(resLoc, static_cast<float>(m_screenWidth), static_cast<float>(m_screenHeight));
    
    m_radarShader->setVec3("viewPos", m_camera.position.x, m_camera.position.y, m_camera.position.z);
    m_radarShader->setVec3("viewDir", m_camera.front.x, m_camera.front.y, m_camera.front.z);
    m_radarShader->setVec3("padPosition", 64.0f, m_startPadY, 64.0f);
    m_radarShader->setVec3("cargoPosition", m_cargoBox->getPosition().x, m_cargoBox->getPosition().y, m_cargoBox->getPosition().z);
    m_radarShader->setInt("cargoAttached", m_cargoBox->isAttached() ? 1 : 0);
    
    GLint radarTimeLoc = glGetUniformLocation(m_radarShader->ID, "time");
    if (radarTimeLoc != -1) glUniform1f(radarTimeLoc, m_lastFrame);

    glBindVertexArray(m_radarVAO);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArray(0);
    glEnable(GL_DEPTH_TEST);
}

void Engine::shutdown() {
    // Vapautetaan shaderit ja pelioliot
    delete m_terrainShader; m_terrainShader = nullptr;
    delete m_padShader;     m_padShader = nullptr;
    delete m_radarShader;   m_radarShader = nullptr;
    delete m_landingPad;    m_landingPad = nullptr;
    delete m_cargoBox;      m_cargoBox = nullptr;

    // Vapautetaan puskurit
    if (m_radarVAO) glDeleteVertexArrays(1, &m_radarVAO);
    if (m_radarVBO) glDeleteBuffers(1, &m_radarVBO);
    if (m_terrainVAO) glDeleteVertexArrays(1, &m_terrainVAO);
    if (m_terrainVBO) glDeleteBuffers(1, &m_terrainVBO);
    if (m_terrainEBO) glDeleteBuffers(1, &m_terrainEBO);

    // --- Sijoita tämä Engine::shutdown() -metodiin ---
    Mix_FreeChunk(m_sndThruster);
    Mix_FreeChunk(m_sndPickup);
    Mix_FreeChunk(m_sndDelivery);
    Mix_CloseAudio(); // Suljetaan mikseri

    // Suljetaan SDL-konteksti
    if (m_glContext) {
        SDL_GL_DeleteContext(m_glContext);
        m_glContext = nullptr;
    }
    if (m_window) {
        SDL_DestroyWindow(m_window);
        m_window = nullptr;
    }
    SDL_Quit();
}
