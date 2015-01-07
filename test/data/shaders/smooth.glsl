//### vert
#version 330

in vec4 vert;
in vec3 norm;

uniform mat4 all_camera_mat;
uniform mat4 transform_camera_mat;

out vec3 ex_pos_transformed;
out vec3 ex_norm;

void main()
{ 
    gl_Position = all_camera_mat * vert; 
    ex_pos_transformed = ( transform_camera_mat * vert ).xyz;
    ex_norm = norm;
}

//### geom
#version 330
layout( triangles ) in;
layout( triangle_strip, max_vertices = 12 ) out;

in vec3[] ex_pos_transformed;
in vec3[] ex_norm;

uniform mat4 all_camera_mat;
uniform mat4 transform_camera_mat;
uniform int draw_norms;

out vec3 pos_transformed;
out vec3 norm_transformed;
flat out int is_norm_vec;

void main()
{
    for( int i = 0; i < 3; i++ )
    {
        gl_Position = gl_in[i].gl_Position;
        pos_transformed = ex_pos_transformed[i];
        norm_transformed = normalize( ( transform_camera_mat * vec4( ex_norm[i], 0 ) ).xyz );
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

            gl_Position = gl_in[i].gl_Position + normalize( ( all_camera_mat * vec4( ex_norm[i], 0 ) ) );
            is_norm_vec = 1;
            EmitVertex();

            EndPrimitive();
        }
}
