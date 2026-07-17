#include "Engine.h"
#include <iostream>
#include <algorithm>

// KORJAUS: Kommentoidaan muuttujanimet pois, koska niitä ei käytetä main-funktion sisällä
int main(int /*argc*/, char* /*argv*/[]) {
    // Luodaan ja käynnistetään moottori
    Engine engine;
    if (!engine.init("Mars Simulator", 1280, 720)) {
        std::cerr << "Moottorin alustus epäonnistui!\n";
        return -1;
    }

    engine.run();

    return 0;
}