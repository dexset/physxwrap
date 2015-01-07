module draw.object.mesh;

import des.math.linear;

import des.util.logsys.base;
import des.util.helpers;

import des.gl.base;

import draw.object.base;

import physxwrap;

import draw.scene;

enum Shading
{
    FLAT,
    SMOOTH
}

struct ModelData
{
private:
    Shading _sh = Shading.FLAT;

    void makeFlat()
    {
        for( int i = 0; i < verts.length; i+=3 )
        {
            auto v1 = verts[i];
            auto v2 = verts[i+1];
            auto v3 = verts[i+2];

            norms[i] = cross( v2 - v1, v3 - v1 ).e;
            norms[i+1] = cross( v3 - v2, v1 - v2 ).e;
            norms[i+2] = cross( v1 - v3, v2 - v3 ).e;
        }
    }

    vec3 sumed_norms( size_t[] indices )//TODO find in std
    {
        vec3 s;
        foreach( i; indices )
            s += norms[i];

        return s.e;
    }

    void makeSmooth()//TODO optimize
    {
        import des.util.stdext.algorithm;
        vec3[] tmp_norms;
        tmp_norms.length = norms.length;
        foreach( v; verts )
        {
            size_t[] all_indices;
            foreach( i, nv; verts )
            {
                if( nv == v )
                    all_indices ~= i;
            }
            auto sum = sumed_norms( all_indices );
            foreach( i; all_indices )
                tmp_norms[i] = sum;
        }
        norms = tmp_norms.dup;
    }
public:
    vec3[] verts;
    vec3[] norms;

    @property shading( Shading s )
    {
        if( _sh == s )
            return;
        _sh = s;
        if( s == Shading.FLAT )
            makeFlat();
        else if( s == Shading.SMOOTH )
            makeSmooth();
    }

    @property shading(){ return _sh; }
}

ModelData loadModel( string fname )
{
    import std.stdio;
    auto f = File( fname, "rb" );

    int[1] vcount;
    f.rawRead( vcount );

    ModelData data;
    data.verts.length = vcount[0];
    data.norms.length = vcount[0];

    float[] tvdata;
    tvdata.length = vcount[0] * 3;
    float[] tndata;
    tndata.length = vcount[0] * 3;

    f.rawRead( tvdata );
    f.rawRead( tndata );

    for( int i = 0; i < vcount[0] * 3; i+= 3 )
    {
        data.verts ~= vec3( tvdata[i .. i + 3] );
        data.norms ~= vec3( tndata[i .. i + 3] );
    }

    return data;
}

class Mesh : SceneObject
{
protected:
    GLBuffer norm;

    void prepareNormBuffer()
    {
        norm = createArrayBuffer();
        setAttribPointer( norm, shader.getAttribLocation( "norm" ), 3, GLType.FLOAT );
    }
public:
    this( string fname, PhysActor actor )
    {
        super( actor, false, "smooth.glsl" );
        prepareNormBuffer();

        auto model = loadModel( appPath( "..", "data", "models", fname ) );

        vert.setData( model.verts );
        norm.setData( model.norms );
        
        material.diffuse = randomColor();
    }

    override void draw( Scene scene )
    { baseDraw( scene, DrawMode.TRIANGLES ); }
}
