#version 330 core
layout (location = 0) in vec2 aPos;

out vec2 TexCoords;

void main() {
    // Muunnetaan -1...1 koordinaatit 0...1 UV-koordinaateiksi
    TexCoords = aPos * 0.5f + 0.5f;
    gl_Position = vec4(aPos, 0.0f, 1.0f);
}
