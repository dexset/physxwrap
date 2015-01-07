module draw.object.plane;

import des.math.linear;

import des.util.logsys.base;

import draw.scene;
import draw.object.base;

import physxwrap;

class Plane : SceneObject
{
public:
    this( float size, PhysActor actor )
    {
        super( actor );

        auto vert_data = [ vec3( 0, -size, -size ), vec3( 0, size, -size ),
                           vec3( 0, -size, size ), vec3( 0, size, size ) ];

        index.setData( [ 0, 1, 2, 3 ] );
        vert.setData( vert_data );

        import std.random;
        auto r = uniform( 0, 1.0 );
        auto g = uniform( 0, 1.0 );
        auto b = uniform( 0, 1.0 );
        material.diffuse = randomColor;
    }

    override void draw( Scene scene )
    { baseDraw( scene ); }
}
