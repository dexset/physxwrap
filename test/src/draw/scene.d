module draw.scene;

import draw.camera;

import des.math.linear;
import des.space;

import des.util.logsys;

class Scene
{
private:
    vec4 light_pos;
public:
    MCamera cam;

    this( vec3 light_pos = vec3(0) )
    { 
        this.light_pos = vec4( light_pos, 1 ); 
        cam = new MCamera;
    }

    @property light_transformed()
    { return cam.resolve(null) * light_pos; }

    mat4 camera_matrix( SpaceNode node )
    { return cam.projection.matrix * cam.resolve( node ); }

    mat4 camera_transform_matrix( SpaceNode node )
    { return cam.resolve( node ); }
}
