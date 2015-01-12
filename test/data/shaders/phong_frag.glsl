//### frag
#version 330

in vec3 pos_transformed;
in vec3 norm_transformed;
flat in int is_norm_vec;

uniform vec3 camera_pos;
uniform vec3 light_pos_transformed[10];

uniform vec3 ambient;
uniform vec3 diffuse;
uniform vec3 specular;

uniform int lcount;

uniform int mode;
uniform int has_light;

out vec4 color;

void main()
{
    if( is_norm_vec != 0 )
    {
        color = vec4( 0, 0, 0.7, 1 );
        return;
    }
    if( has_light == 1 )
    {
        vec3 norm = norm_transformed;

        vec3 pos_cam_vec = normalize( camera_pos - pos_transformed );

        for( int i = 0; i < lcount; i++ )
        {
            vec3 pos_light_vec = normalize( light_pos_transformed[i] - pos_transformed );
            float lambertian = max( dot( pos_light_vec, norm ), 0.0 );

            float specular_coef = 0.0;

            if( lambertian > 0 )
            {
                //blinn phong
                vec3 half_dir = normalize( pos_light_vec + pos_cam_vec );
                float specular_angle = max( dot( half_dir, norm ), 0.0 );

                specular_coef = pow( specular_angle, 16.0 );

                //phong
                if( mode == 2 )
                {
                    vec3 reflect_dir = reflect(-pos_light_vec, norm);
                    specular_angle = max(dot(reflect_dir, pos_cam_vec), 0.0);
                    specular_coef = pow(specular_angle, 4.0);
                }
            }

            color += vec4( ambient + lambertian * diffuse + specular_coef * specular, 1.0 );
        }

        
    }
    else if( has_light == 0 )
        color = vec4( diffuse, 1.0 );

}
