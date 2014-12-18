//### vert
#version 330

in vec4 vert;

uniform vec4 col;

uniform mat4 prj;

void main()
{ 
    gl_Position = prj * vert; 
    gl_FrontColor = col;
}
