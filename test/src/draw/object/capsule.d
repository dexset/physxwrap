module draw.object.capsule;

import draw.object.base;

import des.math.linear;

import des.gl.base;

import draw.camera;

import std.math;

import physxwrap;

class Capsule : SceneObject
{
    uint restart_index = uint.max - 1;

    vec3[] cylinderVerts( float height, float radius, uint segs )
    {
        vec3[] vert_data;

        foreach( i; 0 .. segs + 1 )
        {
            auto a = cast( float )i / segs * 2 * PI;

            auto x = cos( a ) * radius;
            auto y = sin( a ) * radius;
            auto z = -height / 2.0;
            vert_data ~= vec3( x, y, z ); 
            vert_data ~= vec3( x, y, -z ); 
        }
        return vert_data;
    }

    uint[] cylinderIndices( uint count )
    {
        uint[] index_data;
        foreach( i; 0 .. count )
            index_data ~= cast(uint)i;
        return index_data;
    }

    vec3[] downHSphereVerts( float height, float radius, uint segs )
    {
        vec3[] vert_data;

        auto hsegs = segs / 2;

        foreach( lat; 0 .. hsegs + 1 )
            foreach( lon; 0 .. segs + 1 )
            {
                auto theta = cast(float)lat / hsegs * PI * 0.5;
                auto phi = cast(float)lon / segs * PI * 2;

                auto x = radius * sin( theta ) * cos( phi );
                auto y = radius * sin( theta ) * sin( phi );
                auto z = radius * cos( theta );
                vert_data ~= vec3( x, y, z ) + vec3( 0, 0, height );
            }
        return vert_data;
    }

    vec3[] upHSphereVerts( float height, float radius, uint segs )
    {
        auto verts = downHSphereVerts( height, radius, segs );

        auto q = quat.fromAngle( PI, vec3( 0, 1, 0 ) );
        foreach( ref v; verts )
            v = q.rot(v); 
        return verts;
    }

    uint[] hSphereIndices( uint segs, uint offset )
    {
        uint[] index_data;

        auto rsegs = segs + 1;
        auto hsegs = segs / 2;

        foreach( y; 0 .. hsegs )
        {
            index_data ~= [ y * rsegs + offset, ( y + 1 ) * rsegs + offset ];
            foreach( x; 1 .. rsegs ) 
            {
                index_data ~= y * rsegs + x + offset;
                index_data ~= ( y + 1 ) * rsegs + x + offset;
            }
            index_data ~= restart_index;
        }
        return index_data;
    }
public:
    this( float height, float radius, uint segs, PhysActor actor )
    {
        super( actor );

        auto cyl_verts = cylinderVerts( height, radius, segs );
        auto down_hsphere_verts = downHSphereVerts( height / 2.0, radius, segs );
        auto up_hsphere_verts = upHSphereVerts( height / 2.0, radius, segs );

        auto cyl_indices = cylinderIndices( cast(uint)cyl_verts.length );
        auto down_hsphere_indices = hSphereIndices( segs, cast(uint)( cyl_verts.length ) );
        auto up_hsphere_indices = hSphereIndices( segs, cast(uint)( cyl_verts.length + down_hsphere_verts.length ) );

        auto vert_data = cyl_verts ~ up_hsphere_verts ~ down_hsphere_verts;
        auto index_data = cyl_indices ~ restart_index ~
                            up_hsphere_indices ~ restart_index ~ 
                            down_hsphere_indices;

        auto q = quat.fromAngle( PI / 2.0, vec3( 0, 1, 0 ) );
        foreach( ref v; vert_data )
            v = q.rot( v );

        vert.setData( vert_data );
        index.setData( index_data );

        color = randomColor;
    }

    override void draw( MCamera cam )
    {
        glEnable( GL_PRIMITIVE_RESTART );
        glPrimitiveRestartIndex( restart_index );
        super.draw( cam );
        glDisable( GL_PRIMITIVE_RESTART );
    }
}
