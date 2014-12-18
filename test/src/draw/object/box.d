module draw.object.box;

import des.math.linear;

import des.util.logsys.base;

import draw.object.base;

import physxwrap;

class Box : SceneObject
{
public:
    this( vec3 sz, PhysActor actor )
    {
        super( actor );
        auto vert_data = [ vec3( -sz.x, -sz.y,  sz.z ), vec3( sz.x, -sz.y,  sz.z ),
                           vec3( -sz.x,  sz.y,  sz.z ), vec3( sz.x,  sz.y,  sz.z ),
                           vec3( -sz.x, -sz.y, -sz.z ), vec3( sz.x, -sz.y, -sz.z ),
                           vec3( -sz.x,  sz.y, -sz.z ), vec3( sz.x,  sz.y, -sz.z ) ];

        vert.setData( vert_data );

        uint[] indices = [ 0, 1, 2, 3, 7, 1, 5, 4, 7, 6, 2, 4, 0, 1 ];
        index.setData( indices );

        import std.random;
        auto r = uniform( 0, 1.0 );
        auto g = uniform( 0, 1.0 );
        auto b = uniform( 0, 1.0 );
        color = col4( r, g, b, 1 );
    }
}