module draw.object.sphere;

import des.math.linear;

import des.util.logsys.base;

import draw.camera;
import draw.object.base;

import physxwrap;

import des.gl.base;

import std.math;

class Sphere : SceneObject
{
private:
    auto restart_index = uint.max;
public:
    this( float radius, uint segs, PhysActor actor )
    {
        super( actor );

        vec3[] vert_data;

        auto hsegs = segs / 2;

        foreach( lat; 0 .. hsegs + 1 )
            foreach( lon; 0 .. segs + 1 )
            {
                auto theta = cast(float)lat / hsegs * PI;
                auto phi = cast(float)lon / segs * PI * 2;

                auto x = radius * sin( theta ) * cos( phi );
                auto y = radius * sin( theta ) * sin( phi );
                auto z = radius * cos( theta );
                vert_data ~= vec3( x, y, z );
            }

        uint[] index_data;

        auto rsegs = segs + 1;
        foreach( y; 0 .. hsegs )
        {
            index_data ~= [ y * rsegs, ( y + 1 ) * rsegs ];
            foreach( x; 1 .. rsegs ) 
            {
                index_data ~= y * rsegs + x;
                index_data ~= ( y + 1 ) * rsegs + x;
            }
            index_data ~= restart_index;
        }

        vert.setData( vert_data );
        index.setData( index_data );

        color = randomColor();
    }

    override void draw( MCamera cam )
    {
        glEnable( GL_PRIMITIVE_RESTART );
        glPrimitiveRestartIndex( restart_index );
        super.draw( cam );
        glDisable( GL_PRIMITIVE_RESTART );
    }
}
