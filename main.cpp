#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include <iostream>

// Window dimensions
const GLint WIDTH = 800, HEIGHT = 600;

// Rotation and Inertia variables
float rotationX = 0.0f;
float rotationY = 0.0f;
float velocityX = 0.0f;  // UUSI: Pyörimisnopeus X-akselilla
float velocityY = 0.0f;  // UUSI: Pyörimisnopeus Y-akselilla
const float friction = 0.96f; // UUSI: Hidastuvuus (mitä lähempänä 1.0, sitä pidempään pyörii)

bool isDragging = false;
double lastX = 0.0, lastY = 0.0;



// Mouse button callback to detect clicks and drags
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

// Cursor position callback to track mouse movement   
void cursorPosCallback(GLFWwindow* window, double xpos, double ypos) {
    if (isDragging) {
        float sensitivity = 0.3f;
        
        // Lasketaan tämän hetkisen liikkeen nopeus
        velocityY = (xpos - lastX) * sensitivity;
        velocityX = (ypos - lastY) * sensitivity;
        
        lastX = xpos;
        lastY = ypos;
    }
}

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

        // INERTIA LOGIIKKA: Jos hiirtä raahataan, asento muuttuu suoraan hiiren mukana.
        // Jos hiiri vapautetaan, jatketaan pyörimistä nopeuden mukaan ja hidastetaan sitä.
        rotationY += velocityY;
        rotationX += velocityX;

        if (!isDragging) {
            velocityY *= friction; // Hidastetaan pyörimistä Y-akselilla
            velocityX *= friction; // Hidastetaan pyörimistä X-akselilla
        } else {
            // Jos raahaus on käynnissä mutta hiiri pysähtyy, nollataan nopeus 
            // jotta kuutio ei sinkoa vanhalla vauhdilla kun päästät irti.
            velocityY *= 0.1f;
            velocityX *= 0.1f;
        }

        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glLoadIdentity();
        glTranslatef(0.0f, 0.0f, -4.0f); 

        glRotatef(rotationX, 1.0f, 0.0f, 0.0f);
        glRotatef(rotationY, 0.0f, 1.0f, 0.0f);

        drawCube();

        glfwSwapBuffers(window);
    }

    // Safely destroy resources and exit
    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}
