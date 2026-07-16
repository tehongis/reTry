#include <GL/glew.h>

// Valitaan oikea ikkunointikirjasto käännösvaiheen asetuksen mukaan
#ifdef USE_SDL2
# include <SDL2/SDL.h>
# include <SDL2/SDL_opengl.h>
#else
# include <GLFW/glfw3.h>
#endif

#include <iostream>
#include <cmath> // Tarvitaan sin- ja cos-funktioita varten

#include <AL/al.h>
#include <AL/alc.h>
#include <AL/alut.h>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"


// Window dimensions
const GLint WIDTH = 1920, HEIGHT = 1280;

// Pallon pyörimismuuttujat
float rotationX = 0.0f;
float rotationY = 0.0f;
const float rotationSpeed = 2.0f; // Automaattinen pyörimisnopeus

// UUDET: Pallon fysiikkamuuttujat (Sijainti ja Nopeus)
float ballX = 0.0f;
float ballY = 0.0f;
float speedX = 0.025f; // Liikenopeus sivusuunnassa
float speedY = 0.02f;  // Liikenopeus pystysuunnassa

// Painovoima (lisää Amiga-tyylistä pomppua, aseta 0.0f jos haluat täysin suoran linjan)
const float gravity = -0.0008f; 

// Reunarajat (määritetty vastaamaan ikkunan ja ruudukon kokoa tässä syvyydessä)
const float LIMIT_X = 1.6f;
const float LIMIT_Y_TOP = 1.2f;
const float LIMIT_Y_BOTTOM = -0.8f; // Lattian taso

// Hiiriohjauksen muuttujat (pidetään akselipyöritystä varten)
bool isDragging = false;
double lastX = 0.0, lastY = 0.0;

// Äänimuuttujat
ALuint audioBuffer;
ALuint audioSource;

GLuint logoTexture;

#ifndef USE_SDL2
// Pidetään vanhat GLFW-callbackit olemassa vain silloin, kun kääntö tehdaan GLFW:lle
void mouseButtonCallback(GLFWwindow* window, int button, int action, int mods) {
    if (button == GLFW_MOUSE_BUTTON_LEFT) {
        if (action == GLFW_PRESS) {
            isDragging = true;
            glfwGetCursorPos(window, &lastX, &lastY);
        } else if (action == GLFW_RELEASE) {
            isDragging = false;
        }
    }
}

void cursorPosCallback(GLFWwindow* window, double xpos, double ypos) {
    if (isDragging) {
        float sensitivity = 0.5f;
        rotationY += (xpos - lastX) * sensitivity;
        rotationX += (ypos - lastY) * sensitivity;
        lastX = xpos;
        lastY = ypos;
    }
}
#endif

// Helper function to draw a simple multi-colored 3D cube
void drawCube() {
    glBegin(GL_QUADS);

    // Front Face (Red)
    glColor3f(1.0f, 0.0f, 0.0f);
    glVertex3f(-0.5f, -0.5f,  0.5f);
    glVertex3f( 0.5f, -0.5f,  0.5f);
    glVertex3f( 0.5f,  0.5f,  0.5f);
    glVertex3f(-0.5f,  0.5f,  0.5f);

    // Back Face (Green)
    glColor3f(0.0f, 1.0f, 0.0f);
    glVertex3f(-0.5f, -0.5f, -0.5f);
    glVertex3f(-0.5f,  0.5f, -0.5f);
    glVertex3f( 0.5f,  0.5f, -0.5f);
    glVertex3f( 0.5f, -0.5f, -0.5f);

    // Top Face (Blue)
    glColor3f(0.0f, 0.0f, 1.0f);
    glVertex3f(-0.5f,  0.5f, -0.5f);
    glVertex3f(-0.5f,  0.5f,  0.5f);
    glVertex3f( 0.5f,  0.5f,  0.5f);
    glVertex3f( 0.5f,  0.5f, -0.5f);

    // Bottom Face (Yellow)
    glColor3f(1.0f, 1.0f, 0.0f);
    glVertex3f(-0.5f, -0.5f, -0.5f);
    glVertex3f( 0.5f, -0.5f, -0.5f);
    glVertex3f( 0.5f, -0.5f,  0.5f);
    glVertex3f(-0.5f, -0.5f,  0.5f);

    // Right Face (Magenta)
    glColor3f(1.0f, 0.0f, 1.0f);
    glVertex3f( 0.5f, -0.5f, -0.5f);
    glVertex3f( 0.5f,  0.5f, -0.5f);
    glVertex3f( 0.5f,  0.5f,  0.5f);
    glVertex3f( 0.5f, -0.5f,  0.5f);

    // Left Face (Cyan)
    glColor3f(0.0f, 1.0f, 1.0f);
    glVertex3f(-0.5f, -0.5f, -0.5f);
    glVertex3f(-0.5f, -0.5f,  0.5f);
    glVertex3f(-0.5f,  0.5f,  0.5f);
    glVertex3f(-0.5f,  0.5f, -0.5f);

    glEnd();
}

void drawBoingBall_old() {
    const int longitudes = 12; // 12 pystylohkoa (pituusasteet)
    const int latitudes = 6;   // 6 vaakalohkoa (leveysasteet)
    const float radius = 0.6f; // Pallon koko

    for (int i = 0; i < latitudes; i++) {
        // Lasketaan kulmat leveysasteille (-90 asteesta +90 asteeseen)
        float lat0 = M_PI * (-0.5f + (float)i / latitudes);
        float lat1 = M_PI * (-0.5f + (float)(i + 1) / latitudes);

        // KORJAUS: y-koordinaatti määrittää nyt korkeuden (laki ylös, pohja alas)
        float y0  = radius * sin(lat0);
        float r0  = radius * cos(lat0); // Säde tällä korkeudella

        float y1  = radius * sin(lat1);
        float r1  = radius * cos(lat1); // Säde seuraavalla korkeudella

        for (int j = 0; j < longitudes; j++) {
            // Lasketaan kulmat pituusasteille (ympyrä pystyakselin ympäri)
            float lng0 = 2.0f * M_PI * (float)j / longitudes;
            float lng1 = 2.0f * M_PI * (float)(j + 1) / longitudes;

            // X- ja Z-koordinaatit muodostavat ympyrän vaakatasossa
            float x0_0 = r0 * cos(lng0); float z0_0 = r0 * sin(lng0);
            float x1_0 = r0 * cos(lng1); float z1_0 = r0 * sin(lng1);
            
            float x0_1 = r1 * cos(lng0); float z0_1 = r1 * sin(lng0);
            float x1_1 = r1 * cos(lng1); float z1_1 = r1 * sin(lng1);

            // Shakkilautakuvion väri
            if ((i + j) % 2 == 0) {
                glColor3f(1.0f, 0.0f, 0.0f); // Punainen
            } else {
                glColor3f(1.0f, 1.0f, 1.0f); // Valkoinen
            }

            // Piirretään ruutu (Quad) oikeilla 3D-akseleilla (X, Y, Z)
            glBegin(GL_QUADS);
                glVertex3f(x0_0, y0, z0_0);
                glVertex3f(x1_0, y0, z1_0);
                glVertex3f(x1_1, y1, z1_1);
                glVertex3f(x0_1, y1, z0_1);
            glEnd();
        }
    }
}

void drawBoingBall(bool isShadow = false) {
    const int longitudes = 24; 
    const int latitudes = 12;  
    const float radius = 0.6f;  

    // Jos piirretään varjoa, otetaan valaistus pois käytöstä, jotta varjo pysyy tasaisen tummana
    if (isShadow) {
        glDisable(GL_LIGHTING);
    } else {
        glEnable(GL_LIGHTING);
    }

    for (int i = 0; i < latitudes; i++) {
        float lat0 = M_PI * (-0.5f + (float)i / latitudes);
        float lat1 = M_PI * (-0.5f + (float)(i + 1) / latitudes);

        float y0  = radius * sin(lat0); float r0  = radius * cos(lat0);
        float y1  = radius * sin(lat1); float r1  = radius * cos(lat1);

        for (int j = 0; j < longitudes; j++) {
            float lng0 = 2.0f * M_PI * (float)j / longitudes;
            float lng1 = 2.0f * M_PI * (float)(j + 1) / longitudes;

            // Lasketaan 4 pistettä ruutua varten
            float x0_0 = r0 * cos(lng0); float z0_0 = r0 * sin(lng0);
            float x1_0 = r0 * cos(lng1); float z1_0 = r0 * sin(lng1);
            float x0_1 = r1 * cos(lng0); float z0_1 = r1 * sin(lng0);
            float x1_1 = r1 * cos(lng1); float z1_1 = r1 * sin(lng1);

            if (isShadow) {
                glColor3f(0.15f, 0.15f, 0.15f); 
            } else {
                if ((i + j) % 2 == 0) {
                    glColor3f(1.0f, 0.0f, 0.0f); 
                } else {
                    glColor3f(1.0f, 1.0f, 1.0f); 
                }
            }

            glBegin(GL_QUADS);
                // Piste 1 ja sen normaali (jaetaan säteellä, jotta pituus on 1.0)
                glNormal3f(x0_0 / radius, y0 / radius, z0_0 / radius);
                glVertex3f(x0_0, y0, z0_0);

                // Piste 2 ja sen normaali
                glNormal3f(x1_0 / radius, y0 / radius, z1_0 / radius);
                glVertex3f(x1_0, y0, z1_0);

                // Piste 3 ja sen normaali
                glNormal3f(x1_1 / radius, y1 / radius, z1_1 / radius);
                glVertex3f(x1_1, y1, z1_1);

                // Piste 4 ja sen normaali
                glNormal3f(x0_1 / radius, y1 / radius, z0_1 / radius);
                glVertex3f(x0_1, y1, z0_1);
            glEnd();
        }
    }

    // Varmistetaan, että valaistus jää päälle, jos se kytkettiin varjossa pois
    glEnable(GL_LIGHTING);
}


void drawShadow(float x, float y) {
    // Kytketään valot tai tekstuurit pois, jos sellaisia olisi, 
    // ja piirretään pelkkää tasaisen harmaata geometriaa
    glDisable(GL_DEPTH_TEST); 

    glLoadIdentity();
    
    // Varjo sijoitetaan takaseinän lähelle (Z = -4.9f, kun seinä on -5.0f)
    // Varjoa siirretään hieman oikealle ja alas (esim. +0.2f, -0.2f) valonlähteen simuloimiseksi
    glTranslatef(x + 0.2f, y - 0.2f, -4.9f);

    // Alkuperäinen Amiga-kallistus, jotta varjon muoto vastaa palloa
    glRotatef(-20.0f, 0.0f, 0.0f, 1.0f);
    glRotatef(rotationX, 1.0f, 0.0f, 0.0f);
    glRotatef(rotationY, 0.0f, 1.0f, 0.0f);

    // Pakotetaan väri tummanharmaaksi riippumatta pallon omista väreistä
    // Käytetään glColor-kutsun korvausta drawBoingBall-funktion sisällä olevien sijaan
    // Koska drawBoingBall vaihtaa värejä lennosta, piirretään varjolle oma muoto 
    // tai huijataan OpenGL:ää ottamaan vain harmaa väri käyttöön:
    glEnable(GL_COLOR_LOGIC_OP);
    glLogicOp(GL_COPY_INVERTED); // Vaihtoehtoisesti piirretään vain tumma pallo:
    
    // Yksinkertaisuuden vuoksi piirretään pallo, mutta pakotetaan sen päälle tumma sävy.
    // Koska drawBoingBall asettaa värit itse, teemme pienen kikan: kytkemme värikirjoituksen
    // sellaiseksi, että se piirtää vain harmaata, tai luomme minimaalisen varjopallon.
    // Helpoin tapa ilman koodisotkua on muuttaa drawBoingBall ottamaan vastaan 'isShadow' argumentti.
}


void drawBackgroundGrid() {

    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING); // UUSI: Otetaan valot pois ruudukolta
    
    glLoadIdentity();
    glTranslatef(0.0f, 0.0f, -5.0f);
    
    // Työnnetään huone sopivaan syvyyteen
    glTranslatef(0.0f, 0.0f, -5.0f);

    // Amiga-tyylinen purppura/harmaa väri viivoille
    glColor3f(0.4f, 0.3f, 0.4f); 
    glLineWidth(2.0f);

    glBegin(GL_LINES);
    
    float size = 4.0f;     // Ruudukon leveys ja korkeus
    float step = 0.4f;     // Yhden ruudun koko
    float z_back = -5.0f;  // Takaseinän sijainti Z-akselilla
    float z_front = 2.0f;  // Lattian etureuna kameraa kohti

    // --- 1. LATTIARUUDUKKO ---
    // Lattian pystyviivat (menevät syvyyssuunnassa)
    for (float x = -size; x <= size; x += step) {
        glVertex3f(x, -size, z_front);
        glVertex3f(x, -size, z_back);
    }
    // Lattian vaakaviivat (vasemmalta oikealle)
    for (float z = z_back; z <= z_front; z += step) {
        glVertex3f(-size, -size, z);
        glVertex3f(size, -size, z);
    }

    // --- 2. TAKASEINÄRUUDUKKO ---
    // Takaseinän pystyviivat (nousevat lattiasta ylös)
    for (float x = -size; x <= size; x += step) {
        glVertex3f(x, -size, z_back);
        glVertex3f(x, size, z_back);
    }
    // Takaseinän vaakaviivat (korkeussuunnassa)
    for (float y = -size; y <= size; y += step) {
        glVertex3f(-size, y, z_back);
        glVertex3f(size, y, z_back);
    }

    glEnd();
    glEnable(GL_LIGHTING);   // UUSI: Palautetaan valot päälle palloa varten
    glEnable(GL_DEPTH_TEST);
}

void initAudio() {
    // Alustetaan ALUT ja OpenAL-äänilaite
    alutInit(NULL, NULL);

    // KORJAUS: Ladataan ääni kiinteän aallon sijaan suoraan tiedostosta
    audioBuffer = alutCreateBufferFromFile("boing.wav");

    // Varmistetaan, että tiedoston lataus onnistui
    if (audioBuffer == AL_NONE) {
        std::cerr << "Virhe: Tiedostoa boing.wav ei voitu ladata! " 
                  << alutGetErrorString(alutGetError()) << std::endl;
        // Voit jättää alustuksen kesken tai antaa ohjelman jatkaa ilman ääntä
    }

    // Luodaan äänilähde (Source) ja sidotaan ladattu puskuri siihen
    alGenSources(1, &audioSource);
    alSourcei(audioSource, AL_BUFFER, audioBuffer);
    
    // Perusasetukset äänelle (1.0f = normaali voimakkuus ja alkuperäinen korkeus)
    alSourcef(audioSource, AL_GAIN, 1.0f);
    alSourcef(audioSource, AL_PITCH, 1.0f); 
}

void loadTexture() {
    int width, height, nrChannels;
    
    stbi_set_flip_vertically_on_load(true); 
    
    // Pakotetaan STBI_rgb_alpha (arvo 4), jotta saadaan aina 4 kanavaa (RGBA)
    unsigned char* data = stbi_load("amiga.png", &width, &height, &nrChannels, STBI_rgb_alpha); 

    if (data) {
        glGenTextures(1, &logoTexture);
        glBindTexture(GL_TEXTURE_2D, logoTexture);

        // Asetetaan suodatukset
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        // FIX: Lisätään nämä kaksi riviä, jotta 751x170 kokoinen kuva ei bugita (Non-Power-of-Two tuki)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
        glBindTexture(GL_TEXTURE_2D, 0);

        stbi_image_free(data);
        std::cout << "Kuva ladattu onnistuneesti! Koko: " << width << "x" << height << std::endl;
    } else {
        std::cerr << "Virhe: Tiedostoa amiga.png ei voitu ladata! Syy: " << stbi_failure_reason() << std::endl;
    }
}

void draw2DLogo() {
    if (logoTexture == 0) return;

    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, logoTexture);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    glMatrixMode(GL_PROJECTION);
    glPushMatrix(); 
    glLoadIdentity();
    glOrtho(0, WIDTH, 0, HEIGHT, -1, 1); 

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);

    // 1. Määritetään logon koko kuvasuhteen (751x170) mukaan
    float logoWidth = 751.0f; 
    float logoHeight = logoWidth * (170.0f / 751.0f); 

    // 2. KORJAUS: Lasketaan X-koordinaatti keskelle ja jätetään Y-akselille pieni marginaali pohjasta
    float startX = (WIDTH - logoWidth) / 2.0f;
    float startY = 20.0f; // Etäisyys ruudun alareunasta pikseleinä

    glBegin(GL_QUADS);
        // Piirretään suorakulmio keskelle käyttäen startX-muuttujaa marginaalin sijaan
        glTexCoord2f(0.0f, 0.0f); glVertex2f(startX, startY);
        glTexCoord2f(1.0f, 0.0f); glVertex2f(startX + logoWidth, startY);
        glTexCoord2f(1.0f, 1.0f); glVertex2f(startX + logoWidth, startY + logoHeight);
        glTexCoord2f(0.0f, 1.0f); glVertex2f(startX, startY + logoHeight);
    glEnd();

    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);

    glMatrixMode(GL_PROJECTION);
    glPopMatrix(); 
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
}

void draw2DLogoColors() {
    if (logoTexture == 0) return;

    glDisable(GL_LIGHTING);
    glDisable(GL_DEPTH_TEST);
    
    // --- 1. PIIRETÄÄN SATEENKAARIRAITA LOGON ALLE ---
    // Sateenkaari ei tarvitse tekstuureja, vaan se tehdään pelkillä OpenGL-väreillä
    glDisable(GL_TEXTURE_2D);
    
    glMatrixMode(GL_PROJECTION);
    glPushMatrix(); 
    glLoadIdentity();
    glOrtho(0, WIDTH, 0, HEIGHT, -1, 1); 

    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();

    // Lasketaan samat keskityskoordinaatit kuin logolle
    float logoWidth = 751.0f; 
    float logoHeight = logoWidth * (170.0f / 751.0f); 
    float startX = (WIDTH - logoWidth) / 2.0f;
    float startY = 20.0f; 

    // Määritetään sateenkaariraidan paksuus ja sijainti juuri logon alareunaan
    float rainbowHeight = 6.0f; // Raidan paksuus pikseleinä
    float rainbowY = startY - 2.0f; // 2 pikseliä logon tekstin alapuolella

    glBegin(GL_QUADS);
        // Vasen reuna alkaa Amiga-sinisellä
        glColor4f(0.0f, 0.3f, 1.0f, 1.0f); // Sininen
        glVertex2f(startX, rainbowY);
        
        // Liukuväri vaihtuu matkalla vihreän ja keltaisen kautta punaiseksi oikeaan reunaan
        glColor4f(1.0f, 0.0f, 0.0f, 1.0f); // Punainen
        glVertex2f(startX + logoWidth, rainbowY);
        
        glColor4f(1.0f, 0.5f, 0.0f, 1.0f); // Oranssi/Keltainen yläreunassa
        glVertex2f(startX + logoWidth, rainbowY + rainbowHeight);
        
        glColor4f(0.0f, 0.8f, 0.2f, 1.0f); // Vihreä vasemmassa yläreunassa
        glVertex2f(startX, rainbowY + rainbowHeight);
    glEnd();

    // --- 2. PIIRETÄÄN VARSINAINEN AMIGA-TEKSTILOGO ---
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, logoTexture);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // Pakotetaan väri puhtaaksi valkoiseksi, jotta tekstuuri näkyy oikein
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);

    glBegin(GL_QUADS);
        glTexCoord2f(0.0f, 0.0f); glVertex2f(startX, startY);
        glTexCoord2f(1.0f, 0.0f); glVertex2f(startX + logoWidth, startY);
        glTexCoord2f(1.0f, 1.0f); glVertex2f(startX + logoWidth, startY + logoHeight);
        glTexCoord2f(0.0f, 1.0f); glVertex2f(startX, startY + logoHeight);
    glEnd();

    // Siivous
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_BLEND);
    glDisable(GL_TEXTURE_2D);

    glMatrixMode(GL_PROJECTION);
    glPopMatrix(); 
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();

    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
}

/* SDL alt init.
int main() {

    // --- SIIVOUS ---
    alDeleteSources(1, &audioSource);
    alDeleteBuffers(1, &audioBuffer);
    alutExit();

#ifdef USE_SDL2
    SDL_GL_DeleteContext(glContext);
    SDL_DestroyWindow(window);
    SDL_Quit();
#else
    glfwDestroyWindow(window);
    glfwTerminate();
#endif
    return 0;
}
}
*/

int main() {
    
    // Initialize GLFW
    if (!glfwInit()) {
        std::cerr << "Failed to initialize GLFW" << std::endl;
        return -1;
    }

    // Create a windowed mode window and its OpenGL context
    GLFWwindow* window = glfwCreateWindow(WIDTH, HEIGHT, "Interactive OpenGL Cube", NULL, NULL);
    if (!window) {
        std::cerr << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }

    initAudio(); // Alustetaan boing-ääni
 
    // Make the window's context current
    glfwMakeContextCurrent(window);

    // Initialize GLEW
    glewExperimental = GL_TRUE; 
    GLenum err = glewInit();
    
    // Fix: Check the error string to bypass the Wayland GLX display crash safely
    if (err != GLEW_OK) {
        std::string errorStr = (const char*)glewGetErrorString(err);
        if (errorStr != "Unknown error") { 
            std::cerr << "Failed to initialize GLEW: " << errorStr << std::endl;
            return -1;
        }
    }
    

    // Fix: Allow compilation on Wayland systems by ignoring the missing GLX display check
    if (err != GLEW_OK && err != GLEW_ERROR_NO_GLX_DISPLAY) {
        std::cerr << "Failed to initialize GLEW: " << glewGetErrorString(err) << std::endl;
        return -1;
    }

    // Configure viewport and enable depth testing for proper 3D rendering
    glViewport(0, 0, WIDTH, HEIGHT);
    glEnable(GL_DEPTH_TEST);

    loadTexture();

    // --- UUSI: VALAISTUSASETUKSET ---
    glEnable(GL_LIGHTING);     // Otetaan valaistus käyttöön
    glEnable(GL_LIGHT0);        // Otetaan käyttöön valonlähde 0
    glEnable(GL_COLOR_MATERIAL); // Sallitaan glColor3f-kutsujen määrittää pinnan perusväri

    // Määritetään valon sijainti (vasemmalla, ylhäällä, hieman katsojan puolella)
    GLfloat lightPos[] = { -2.0f, 3.0f, 2.0f, 1.0f };
    glLightfv(GL_LIGHT0, GL_POSITION, lightPos);

    // Määritetään valon kirkkaudet ja värit (ambient = yleisvalo, diffuse = kohdistettu valo)
    GLfloat ambientLight[] = { 0.3f, 0.3f, 0.3f, 1.0f };
    GLfloat diffuseLight[] = { 0.8f, 0.8f, 0.8f, 1.0f };
    GLfloat specularLight[] = { 0.6f, 0.6f, 0.6f, 1.0f }; // Kiiltoheijastus

    glLightfv(GL_LIGHT0, GL_AMBIENT, ambientLight);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuseLight);
    glLightfv(GL_LIGHT0, GL_SPECULAR, specularLight);

    // Määritetään materiaalin kiilto (shininess), joka luo pallon pintaan valopisteen
    glMaterialf(GL_FRONT, GL_SHININESS, 32.0f); 

    // FIX 1: Set up 3D Perspective Projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
   
    // arguments: Field of View (45 deg), Aspect Ratio, Near clipping plane, Far clipping plane
    gluPerspective(45.0, (double)WIDTH / (double)HEIGHT, 0.1, 100.0);
    
    // Switch back to Modelview matrix for drawing objects
    glMatrixMode(GL_MODELVIEW);

    // Set up mouse interaction callbacks
    glfwSetMouseButtonCallback(window, mouseButtonCallback);
    glfwSetCursorPosCallback(window, cursorPosCallback);

    // Main rendering loop
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();

        // --- FYSIIKKALASKENNAn PÄIVITYS ---
        
        // 1. Sovelletaan painovoimaa pystynopeuteen
        speedY += gravity;

        // 2. Päivitetään pallon sijainti nopeuden mukaan
        ballX += speedX;
        ballY += speedY;

        // 3. Automaattinen pyöriminen akselin ympäri (kuten alkuperäisessä demossa)
        if (!isDragging) {
            rotationY += rotationSpeed;
        }

        // 4. Törmäystarkistus: Vasen ja oikea seinä
        if (ballX > LIMIT_X) {
            ballX = LIMIT_X;
            speedX = -speedX; // Käännetään suunta
            alSourcePlay(audioSource); // ÄÄNI!            
        } else if (ballX < -LIMIT_X) {
            ballX = -LIMIT_X;
            speedX = -speedX;
            alSourcePlay(audioSource); // ÄÄNI!            
        }

        // 5. Törmäystarkistus: Lattia ja katto
        if (ballY < LIMIT_Y_BOTTOM) {
            ballY = LIMIT_Y_BOTTOM;
            speedY = -speedY; // Kimpautetaan ylös lattiasta
            alSourcePlay(audioSource); // ÄÄNI!
            // Amiga-efekti: Jos pallo menettää energiaa, annetaan sille pieni lisäpotku 
            // jotta se pomppii ikuisesti samalla tavalla
            if (fabs(speedY) < 0.02f) speedY = 0.025f; 
        } else if (ballY > LIMIT_Y_TOP) {
            ballY = LIMIT_Y_TOP;
            speedY = -speedY;
            alSourcePlay(audioSource); // ÄÄNI!
        }

        // --- RENDEROINTI ---
        glClearColor(0.6f, 0.6f, 0.6f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // 1. Piirretään taustahuone (pysyy paikallaan)
        drawBackgroundGrid();

        // 2. UUSI: Piirretään harmaa varjo takaseinälle ennen palloa
        glDisable(GL_DEPTH_TEST); // Varjo piirretään taustan päälle ilman syvyystestiä
        glLoadIdentity();
        // Varjo siirretään hieman pallon koordinaateista (ballX+0.3, ballY-0.2) ja litistetään takaseinälle (-4.8f)
        glTranslatef(ballX + 0.25f, ballY - 0.2f, -4.8f); 
        glRotatef(-20.0f, 0.0f, 0.0f, 1.0f);
        glRotatef(rotationX, 1.0f, 0.0f, 0.0f);
        glRotatef(rotationY, 0.0f, 1.0f, 0.0f);
        drawBoingBall(true); // true = piirretään harmaana varjona
        glEnable(GL_DEPTH_TEST); // Palautetaan syvyystesti palloa varten

        // 2. Piirretään liikkuva ja pomppiva pallo
        glLoadIdentity();
        
        // KORJAUS: Siirretään palloa fysiikkakoordinaattien (ballX, ballY) mukaan
        glTranslatef(ballX, ballY, -4.0f); 

        // Alkuperäinen Amiga-kallistus oikealle (-20 astetta Z-akselilla)
        glRotatef(-20.0f, 0.0f, 0.0f, 1.0f);

        // Pyöritys oman akselin ympäri (automaattinen + hiiren hienosäätö)
        glRotatef(rotationX, 1.0f, 0.0f, 0.0f);
        glRotatef(rotationY, 0.0f, 1.0f, 0.0f);

        drawBoingBall();

        // UUSI: Piirretään 2D-logo päällimmäiseksi ennen kuvan vaihtoa katselijalle
        draw2DLogoColors();

        glfwSwapBuffers(window);
    }

    // Siivotaan ääniresurssit ennen sulkemista
    alDeleteSources(1, &audioSource);
    alDeleteBuffers(1, &audioBuffer);
    alutExit();

    // Safely destroy resources and exit
    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}
