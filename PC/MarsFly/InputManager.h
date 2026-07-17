#ifndef INPUTMANAGER_H
#define INPUTMANAGER_H

#include <SDL2/SDL.h>
#include "Camera.h"
#include "Terrain.h"
#include "LandingPad.h"
#include "CargoBox.h"

class InputManager {
public:
    InputManager();
    ~InputManager();

    void processEvents(Camera& camera, bool& running);

    void updateFlightPhysics(Camera& camera, Terrain& terrain, LandingPad& landingPad, 
                             CargoBox& cargoBox, float deltaTime);

};

#endif
