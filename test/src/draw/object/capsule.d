module draw.object.capsule;

import draw.object.base;

import des.math.linear;

import des.gl.base;

import draw.scene;

import std.math;

import physxwrap;

struct VertData
{
    vec3 pos;
    vec3 norm;

    void yRot( float angle )
    {
        auto rot_mat = mat4( cos( PI ),  0, sin( PI ), 0,
                             0,          1, 0,         0,
                             -sin( PI ), 0, cos( PI ), 0,
                             0,          0, 0,         1 );
        pos = ( rot_mat * vec4(pos,1) ).xyz; 
        norm = ( rot_mat * vec4(norm,0) ).xyz; 
    }
}

class Capsule : SceneObject
{
    GLBuffer norm;

    uint restart_index = uint.max - 1;

    VertData[] cylinderVerts( float height, float radius, uint segs )
    {
        VertData[] vert_data;

        foreach( i; 0 .. segs + 1 )
        {
            auto a = cast( float )i / segs * 2 * PI;

            auto x = cos( a ) * radius;
            auto y = sin( a ) * radius;
            auto z = -height / 2.0;
            auto norm = vec3( 0, x, y ).e;
            vert_data ~= VertData( vec3( -z, x, y ), norm ); 
            vert_data ~= VertData( vec3( z, x, y ), norm ); 
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

    VertData[] downHSphereVerts( float height, float radius, uint segs )
    {
        VertData[] vert_data;

        auto hsegs = segs / 2;

        foreach( lat; 0 .. hsegs + 1 )
            foreach( lon; 0 .. segs + 1 )
            {
                auto theta = cast(float)lat / hsegs * PI * 0.5;
                auto phi = cast(float)lon / segs * PI * 2;

                auto x = radius * sin( theta ) * cos( phi );
                auto y = radius * sin( theta ) * sin( phi );
                auto z = radius * cos( theta );
                auto norm = vec3( z, x, y );
                vert_data ~= VertData( norm + vec3( height, 0, 0 ), norm );
            }
        return vert_data;
    }

    VertData[] upHSphereVerts( float height, float radius, uint segs )
    {
        auto vert_data = downHSphereVerts( height, radius, segs );

        foreach( ref v; vert_data )
            v.yRot( PI );

        return vert_data;
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

    void prepareNormBuffer()
    {
        norm = createArrayBuffer();
        setAttribPointer( norm, shader.getAttribLocation( "norm" ), 3, GLType.FLOAT );
    }
public:
    this( float height, float radius, uint segs, PhysActor actor )
    {
        super( actor, true, "smooth.glsl" );

        prepareNormBuffer();

        import des.util.stdext.algorithm;

        auto cyl_vert_data = cylinderVerts( height, radius, segs );
        auto down_hsphere_vert_data = downHSphereVerts( height / 2.0, radius, segs );
        auto up_hsphere_vert_data = upHSphereVerts( height / 2.0, radius, segs );

        auto cyl_verts = amap!(a=>a.pos)(cyl_vert_data);
        auto down_hsphere_verts = amap!(a=>a.pos)(down_hsphere_vert_data);
        auto up_hsphere_verts = amap!(a=>a.pos)(up_hsphere_vert_data);

        auto cyl_norms = amap!(a=>a.norm)(cyl_vert_data);
        auto down_hsphere_norms = amap!(a=>a.norm)(down_hsphere_vert_data);
        auto up_hsphere_norms = amap!(a=>a.norm)(up_hsphere_vert_data);

        auto cyl_indices = cylinderIndices( cast(uint)cyl_verts.length );
        auto down_hsphere_indices = hSphereIndices( segs, cast(uint)( cyl_verts.length ) );
        auto up_hsphere_indices = hSphereIndices( segs, cast(uint)( cyl_verts.length + down_hsphere_verts.length ) );

        auto vert_data = cyl_verts ~ up_hsphere_verts ~ down_hsphere_verts;
        auto norm_data = cyl_norms ~ up_hsphere_norms ~ down_hsphere_norms;
        auto index_data = cyl_indices ~ restart_index ~
                            up_hsphere_indices ~ restart_index ~ 
                            down_hsphere_indices;

        vert.setData( vert_data );
        norm.setData( norm_data );
        index.setData( index_data );

        material.diffuse = randomColor;
    }

    override void draw( Scene scene )
    { baseDrawWithPrimitiveRestart( scene, restart_index ); }
}
