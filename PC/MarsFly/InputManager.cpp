#include "InputManager.h"
#include <algorithm>

InputManager::InputManager() {}
InputManager::~InputManager() {}

void InputManager::processEvents(Camera& camera, bool& running) {
    // Siirretty luokan ulkopuolelle tai pidetään static-muuttujana muistisuojausta varten
    static SDL_Event event; 
    
    while (SDL_PollEvent(&event)) {
        if (event.type == SDL_QUIT) {
            running = false;
        }
        
        if (event.type == SDL_KEYDOWN) {
            if (event.key.keysym.sym == SDLK_ESCAPE) {
                running = false;
            }
            // UUSI TOIMINTO: Jos painetaan Space-näppäintä, katkaistaan köysi ja heitetään laatikko dynaamisesti
            if (event.key.keysym.sym == SDLK_SPACE) {
                // Tarvitsemme viitteen CargoBoxiin. Koska processEvents ei ota sitä vastaan, 
                // tämä suoritetaan helpoiten joko tässä (jos välitetään olio) tai alla updateFlightPhysics-metodissa.
                // Säästetään tämä dynaamisen keystaten puolelle tai käsitellään se suoraan fysiikkapäivityksessä!
            }
        }
        
        if (event.type == SDL_MOUSEMOTION) {
            camera.updateDirection(static_cast<float>(event.motion.xrel), static_cast<float>(event.motion.yrel));
        }
    }
}

void InputManager::updateFlightPhysics(Camera& camera, Terrain& terrain, LandingPad& landingPad, 
                                      CargoBox& cargoBox, float deltaTime) {
    const Uint8* keystate = SDL_GetKeyboardState(NULL);

    // KORJAUS & UUSI TOIMINTO: Jos painetaan Space-näppäintä, katkaistaan köysi välittömästi
    if (keystate[SDL_SCANCODE_SPACE]) {
        cargoBox.cutRope();
    }

    // 1. INPUT-KIIHTYVYYDET
    camera.moveForward(keystate[SDL_SCANCODE_W],  1.0f, deltaTime);
    camera.moveForward(keystate[SDL_SCANCODE_S], -1.0f, deltaTime);
    camera.moveStrafe(keystate[SDL_SCANCODE_D],   1.0f, deltaTime);
    camera.moveStrafe(keystate[SDL_SCANCODE_A],  -1.0f, deltaTime);
    
    // KORJAUS: Vaihdettu SDL_SCANCODE_SPACE -> SDL_SCANCODE_LSHIFT nostoteholle
    camera.moveUp(keystate[SDL_SCANCODE_LSHIFT], 1.0f, deltaTime);
    camera.moveUp(keystate[SDL_SCANCODE_LCTRL], -1.0f, deltaTime);

    // Sovelletaan Marsin painovoimaa aluksen pystynopeuteen
    const float MARS_GRAVITY = 3.7f;
    camera.velocityUp -= MARS_GRAVITY * deltaTime;

    // 2. LINEAARINEN KITKA (DRAG)
    const float frictionCoefficient = camera.DRAG * camera.ACCELERATION * deltaTime;
    
    if (camera.velocityForward > 0.0f) camera.velocityForward = std::max(0.0f, camera.velocityForward - frictionCoefficient);
    else if (camera.velocityForward < 0.0f) camera.velocityForward = std::min(0.0f, camera.velocityForward + frictionCoefficient);

    if (camera.velocityStrafe > 0.0f) camera.velocityStrafe = std::max(0.0f, camera.velocityStrafe - frictionCoefficient);
    else if (camera.velocityStrafe < 0.0f) camera.velocityStrafe = std::min(0.0f, camera.velocityStrafe + frictionCoefficient);

    if (camera.velocityUp > 0.0f) camera.velocityUp = std::max(0.0f, camera.velocityUp - frictionCoefficient);
    else if (camera.velocityUp < 0.0f) camera.velocityUp = std::min(0.0f, camera.velocityUp + frictionCoefficient);

    // 3. LAATIKON PAINON JA KÖYDEN VOIMAVAIKUTUS (Newton III)
    glm::vec3 horizontalFront = glm::normalize(glm::vec3(camera.front.x, 0.0f, camera.front.z));
    glm::vec3 playerVelocityVec = (horizontalFront * camera.velocityForward) + 
                                  (camera.right * camera.velocityStrafe) + 
                                  glm::vec3(0.0f, camera.velocityUp, 0.0f);

    // Päivitetään rahtilaatikon heilunta
    cargoBox.update(camera.position, playerVelocityVec, deltaTime, terrain);

    // Puretaan laatikon muuttama todellinen nopeus takaisin aluksen muuttujille
    if (glm::length(horizontalFront) > 0.0f) {
        camera.velocityForward = glm::dot(playerVelocityVec, horizontalFront);
        camera.velocityStrafe  = glm::dot(playerVelocityVec, camera.right);
        camera.velocityUp      = playerVelocityVec.y; 
    }

    // 4. LIIKUTETAAN ALUSTA LOPULLISEN MUUTTUNEEN NOPEUDEN MUKAAN
    camera.position += horizontalFront * camera.velocityForward * deltaTime;
    camera.position += camera.right * camera.velocityStrafe * deltaTime;
    camera.position.y += camera.velocityUp * deltaTime;

    // 5. DYNAAMINEN TÖRMÄYKSTARKISTUS (Maasto vs Laskeutumisalusta)
    float terrainHeight = terrain.getHeightAt(camera.position.x, camera.position.z);
    float padHeight = landingPad.getSurfaceHeight(camera.position.x, camera.position.z);
    float finalSurfaceHeight = (padHeight > -9000.0f) ? padHeight : terrainHeight;

    const float HOVER_HEIGHT = 2.0f;
    float minAllowedHeight = finalSurfaceHeight + HOVER_HEIGHT;
    
    if (camera.position.y < minAllowedHeight) {
        camera.position.y = minAllowedHeight;

        if (camera.velocityUp < 0.0f) {
            camera.velocityUp = 0.0f;
        }

        camera.velocityForward *= (1.0f - 4.0f * deltaTime);
        camera.velocityStrafe  *= (1.0f - 4.0f * deltaTime);
    }
}
