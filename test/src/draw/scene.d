module draw.scene;

import draw.camera;

import des.math.linear;
import des.space;

import des.util.logsys;

class Scene
{
private:
    vec4[] light_pos;
    static const max_lights = 10;
public:
    MCamera cam;

    this( vec3 light_pos = vec3(0) )
    { 
        this.light_pos ~= vec4( light_pos, 1 ); 
        cam = new MCamera;
    }

    void addLight( vec3 light_pos )
    { this.light_pos ~= vec4( light_pos, 1 ); }

    @property lights_transformed()
    { 
        vec3[10] lights;
        foreach( i, l; light_pos )
            lights[i] = ( cam.resolve( null ) * l ).xyz;
        return lights; 
    }

    mat4 camera_matrix( SpaceNode node )
    { return cam.projection.matrix * cam.resolve( node ); }

    mat4 camera_transform_matrix( SpaceNode node )
    { return cam.resolve( node ); }

    @property lights_count(){ return cast(int)light_pos.length; }
}
