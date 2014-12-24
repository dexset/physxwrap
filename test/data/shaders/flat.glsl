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

//### frag
#version 330

in vec3 pos_transformed;
in vec3 norm_transformed;
flat in int is_norm_vec;

uniform vec4 base_color;
uniform vec4 light_color;
uniform vec3 camera_pos;
uniform vec3 light_pos_transformed;

out vec4 color;

vec3 rot( vec3 vv, vec3 axis, float cosa )
{
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;
    if( cosa > 1 ) cosa = 1;
    float sina = sqrt( 1.0 - cosa*cosa );
    float omca = 1.0 - cosa;
    mat3 rr = mat3( cosa + omca*x*x, omca*x*y - sina*z, omca*x*z + sina*y,
                    omca*y*x + sina*z, cosa + omca*y*y, omca*y*z - sina*x,
                    omca*z*x - sina*y, omca*z*y + sina*x, cosa + omca*z*z );
    return rr * vv;
}

void main()
{
    if( is_norm_vec != 0 )
    {
        color = vec4( 0, 0, 0.7, 1 );
        return;
    }

    vec3 norm = norm_transformed;

    vec3 pos_light_vec = normalize( light_pos_transformed - pos_transformed );
    vec3 pos_cam_vec = normalize( camera_pos - pos_transformed );

    float cosa = dot( pos_cam_vec, norm );
    float cos2a = 2 * cosa * cosa - 1;

    vec3 cam_vec_reflect = rot( pos_cam_vec, cross( pos_cam_vec, norm ), cos2a );

    float coef = dot( pos_light_vec, cam_vec_reflect );

    vec3 target_color = light_color.xyz;

    if( cosa < 0 ) target_color = vec3( 0, 0, 0 );

    float dist = length( cam_vec_reflect.xy );
    float t = dist * dist;
    float k = 0.01;
    float diff_coef = 0.2;
    float cos_coef = 0.8;
    color = vec4( target_color * k/(t+k) + base_color.xyz * ( diff_coef + cosa * cosa * cos_coef ), 1);
}
