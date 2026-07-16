#include "Shader.h"
#include <GL/glew.h>
#include <fstream>
#include <iostream>
#include <vector>

Shader::Shader(const char* vertexPath, const char* fragmentPath) {
    std::string vertexCode;
    std::string fragmentCode;

    // Luetaan Vertex Shader raakana sisään
    std::ifstream vShaderFile(vertexPath, std::ios::binary | std::ios::ate);
    if (vShaderFile.is_open()) {
        std::streamsize size = vShaderFile.tellg();
        vShaderFile.seekg(0, std::ios::beg);
        std::vector<char> buffer(size);
        if (vShaderFile.read(buffer.data(), size)) {
            vertexCode.assign(buffer.data(), size);
        }
        vShaderFile.close();
    } else {
        std::cerr << "VIRHE: Vertex shader -tiedostoa ei voitu avata: " << vertexPath << "\n";
    }

    // Luetaan Fragment Shader raakana sisään
    std::ifstream fShaderFile(fragmentPath, std::ios::binary | std::ios::ate);
    if (fShaderFile.is_open()) {
        std::streamsize size = fShaderFile.tellg();
        fShaderFile.seekg(0, std::ios::beg);
        std::vector<char> buffer(size);
        if (fShaderFile.read(buffer.data(), size)) {
            fragmentCode.assign(buffer.data(), size);
        }
        fShaderFile.close();
    } else {
        std::cerr << "VIRHE: Fragment shader -tiedostoa ei voitu avata: " << fragmentPath << "\n";
    }

    const char* vShaderCode = vertexCode.c_str();
    const char* fShaderCode = fragmentCode.c_str();

    unsigned int vertex, fragment;
    int success;
    char infoLog[512];

    vertex = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertex, 1, &vShaderCode, NULL);
    glCompileShader(vertex);
    glGetShaderiv(vertex, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(vertex, 512, NULL, infoLog);
        std::cerr << "VIRHE: Vertex shaderin käännös epäonnistui:\n" << infoLog << "\n";
    }

    fragment = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragment, 1, &fShaderCode, NULL);
    glCompileShader(fragment);
    glGetShaderiv(fragment, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(fragment, 512, NULL, infoLog);
        std::cerr << "VIRHE: Fragment shaderin käännös epäonnistui:\n" << infoLog << "\n";
    }

    ID = glCreateProgram();
    glAttachShader(ID, vertex);
    glAttachShader(ID, fragment);
    glLinkProgram(ID);
    glGetProgramiv(ID, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(ID, 512, NULL, infoLog);
        std::cerr << "VIRHE: Shader-ohjelman linkitys epäonnistui:\n" << infoLog << "\n";
    }
    glDeleteShader(vertex);
    glDeleteShader(fragment);
}

void Shader::use() { 
    glUseProgram(ID); 
}

void Shader::setVec3(const std::string &name, float x, float y, float z) const { 
    glUniform3f(glGetUniformLocation(ID, name.c_str()), x, y, z); 
}

void Shader::setMat4(const std::string &name, const float* matrixData) const {
    glUniformMatrix4fv(glGetUniformLocation(ID, name.c_str()), 1, GL_FALSE, matrixData);
}

void Shader::setInt(const std::string &name, int value) const {
    glUniform1i(glGetUniformLocation(ID, name.c_str()), value);
}
