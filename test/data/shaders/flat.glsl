//### vert
#version 330

in vec4 vert;
uniform mat4 all_camera_mat;
uniform mat4 transform_camera_mat;

out vec3 ex_pos_transformed;
out vec3 ex_pos_raw;

void main()
{ 
    gl_Position = all_camera_mat * vert; 
    ex_pos_raw = vert.xyz;
    ex_pos_transformed = ( transform_camera_mat * vert ).xyz;
}

//### geom
#version 330

layout( triangles ) in;
layout( triangle_strip, max_vertices = 12 ) out;

in vec3[] ex_pos_transformed;
in vec3[] ex_pos_raw;

uniform mat4 all_camera_mat;
uniform mat4 transform_camera_mat;
uniform int draw_norms;
uniform vec4 base_color;

out vec3 pos_transformed;
out vec3 norm_transformed;
flat out int is_norm_vec;

void main()
{
    vec3 a = ex_pos_raw[1] - ex_pos_raw[0];
    vec3 b = ex_pos_raw[2] - ex_pos_raw[0];

    vec3 norm = normalize( cross( a, b ) );
    vec3 drawable_norm = ( all_camera_mat * vec4( norm, 0 ) ).xyz;
    norm = ( transform_camera_mat * vec4( norm, 0 ) ).xyz;


    for( int i = 0; i < 3; i++ )
    {
        gl_Position = gl_in[i].gl_Position;
        pos_transformed = ex_pos_transformed[i];
        norm_transformed = norm;
        is_norm_vec = 0;
        EmitVertex();
    }
    EndPrimitive();

    if( draw_norms != 0 )//TODO BETTER DRAWING
        for( int i = 0; i < 3; i++ )
        {
            gl_Position = gl_in[i].gl_Position - 0.1;
            is_norm_vec = 1;
            EmitVertex();

            gl_Position = gl_in[i].gl_Position + 0.1;
            is_norm_vec = 1;
            EmitVertex();

            gl_Position = gl_in[i].gl_Position + vec4( drawable_norm, 0 );
            is_norm_vec = 1;
            EmitVertex();

            EndPrimitive();
        }
}
