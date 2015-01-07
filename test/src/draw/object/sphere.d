module draw.object.sphere;

import des.math.linear;

import des.util.logsys.base;

import draw.scene;
import draw.object.base;

import physxwrap;

import des.gl.base;

import std.math;

class Sphere : SceneObject
{
private:
    GLBuffer norm;
    auto restart_index = uint.max;

    void prepareVertsAndNorms( float radius, uint segs )
    {
        norm = createArrayBuffer();
        setAttribPointer( norm, shader.getAttribLocation( "norm" ), 3, GLType.FLOAT );

        vec3[] norm_data;
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
                norm_data ~= vec3( x, y, z );
                vert_data ~= vec3( x, y, z );
            }
        norm.setData( norm_data );
        vert.setData( vert_data );
    }

    void prepareIndices( uint segs )
    {
        uint[] index_data;


        auto hsegs = segs / 2;

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
        index.setData( index_data );
    }
public:
    this( float radius, uint segs, PhysActor actor )
    {
        super( actor, true, "smooth.glsl" );

        prepareVertsAndNorms( radius, segs );
        prepareIndices( segs );

        material.diffuse = randomColor();
    }

    override void draw( Scene scene )
    { baseDrawWithPrimitiveRestart( scene, restart_index ); }
}
