#ifndef SHADER_H
#define SHADER_H

#include <string>

class Shader {
public:
    unsigned int ID;
    Shader(const char* vertexPath, const char* fragmentPath);
    void use();
    void setVec3(const std::string &name, float x, float y, float z) const;
    void setMat4(const std::string &name, const float* matrixData) const;
    void setInt(const std::string &name, int value) const;    
};

#endif
