module draw.window;

import des.app;

import des.gl;

import des.util.logsys;

import des.util.timer;

import draw.object;
import draw.scene;

import physxwrap;

class MainWindow : GLWindow
{
private:
    SceneObject[] objects;

    Plane plane;

    Scene scene;

    PhysScene phys_scene;

    PhysMaterial material;

    Timer timer;

    TextBox info_text;

    auto polygon_mode = GL_FILL;

    SceneObject addBox( vec3 pos, vec3 size )
    {
        auto transform = new PhysTransform( pos );
        auto geometry = PhysGeometry.boxGeometry( size );

        auto actor = phys_scene.createSimple( transform, geometry, material );

        objects ~= newEMM!Box( size, actor );
        import std.random;
        objects[$ - 1].actor.setDensity( uniform( 1.0, 10.0 ) );
        return objects[$ - 1];
    }

    SceneObject addSphere( vec3 pos, float radius )
    {
        auto transform = new PhysTransform( pos );
        auto geometry = PhysGeometry.sphereGeometry( radius );

        auto actor = phys_scene.createSimple( transform, geometry, material );

        objects ~= newEMM!Sphere( radius, 50, actor );
        import std.random;
        objects[$ - 1].actor.setDensity( uniform( 1.0, 10.0 ) );
        return objects[$ - 1];
    }

    SceneObject addPlane( vec3 pos, float angle )
    {
        auto transform = new PhysTransform( pos, vec3( 0, 1, 0 ), angle );
        auto geometry = PhysGeometry.planeGeometry();

        auto actor = phys_scene.createSimple( transform, geometry, material, true );

        objects ~= newEMM!Plane( 5000.0, actor );

        return objects[$-1];
    }

    struct CollisionModelData
    {
        vec3[] verts;
        uint[] indices;//TODO check if input is int
    }

    auto loadCollisionModel( string fname )
    {
        import std.stdio;
        auto f = File( fname, "rb" );

        int[1] vcount;
        int[1] icount;
        f.rawRead( vcount );
        f.rawRead( icount );

        CollisionModelData data;
        data.verts.length = vcount[0];
        data.indices.length = icount[0];

        float[] tvdata;
        tvdata.length = vcount[0] * 3;

        f.rawRead( tvdata );

        for( int i = 0; i < vcount[0] * 3; i+= 3 )
            data.verts ~= vec3( tvdata[i .. i + 3] );

        f.rawRead( data.indices );

        return data;
    }

    SceneObject addDefaultModel( vec3 pos )
    {
        auto transform = new PhysTransform( pos );

        import des.util.helpers;
        auto model = loadCollisionModel( appPath( "..", "data", "models", "model.des_collision" ) );
        auto geometry = PhysGeometry.convexMeshGeometry( model.verts );

        auto actor = phys_scene.createSimple( transform, geometry, material );

        objects ~= newEMM!Mesh( "model.des", actor );

        return objects[$-1];
    }

    SceneObject addCapsule( vec3 pos, float height, float radius )
    {
        import std.math;
        auto transform = new PhysTransform( pos, vec3( 0, 1, 0 ), PI / 2.0 );
        auto geometry = PhysGeometry.capsuleGeometry( height / 2.0, radius );

        auto actor = phys_scene.createSimple( transform, geometry, material );

        objects ~= newEMM!Capsule( height, radius, 50, actor );
        import std.random;
        objects[$ - 1].actor.setDensity( uniform( 1.0, 10.0 ) );
        return objects[$ - 1];
    }

    void makeScales()
    {
        addBox( vec3( 0, 0, 1 ), vec3( 0.1, 1, 1 ) );   
        addBox( vec3( 0, 0, 2.1 ), vec3( 6, 1, 0.1 ) );   

        auto first = addBox( vec3( -4, 0, 2.7 ), vec3( 0.5 ) );   
        auto second = addBox( vec3( 4, 0, 3.2 ), vec3( 1 ) );   

        first.actor.setDensity( 200.0 );
        second.actor.setDensity( 2.0 );
    }

    void switchPolygonMode()
    {
        if( polygon_mode == GL_LINE )
            glPolygonMode( GL_FRONT_AND_BACK, polygon_mode = GL_FILL );
        else if( polygon_mode == GL_FILL )
            glPolygonMode( GL_FRONT_AND_BACK, polygon_mode = GL_POINT );
        else
            glPolygonMode( GL_FRONT_AND_BACK, polygon_mode = GL_LINE );
    }

    void prepareInfoText()
    {
        import des.util.helpers;
        import des.il;
        auto font_name = appPath( "..", "data", "fonts", "default.ttf" );
        info_text = newEMM!TextBox( font_name );
        info_text.setRect( fRegion2( 10, 10, 1, 1 ) ); 
        info_text.setColor( col4( 0.8, 0.8, 0.8, 1 ) );

        info_text.text = 
`1 - Box
2 - Sphere
3 - Capsule
4 - model.des
G - Gravity
F - Force to center
W - Polygon mode
P - Blin-phong/phong shading
N - Draw norms
L - Lightning
`;

    }

    void prepareScene()
    {
        glCullFace( GL_FRONT );
        glPointSize( 4.0 );
        glPolygonMode( GL_FRONT_AND_BACK, polygon_mode );
        timer = new Timer;
        material = new PhysMaterial( 0.5, 0.5, 0.5 );

        phys_scene = newEMM!PhysScene;
        phys_scene.gravity = vec3( 0, 0, -9.8 );

        scene = new Scene( vec3( 10, 10, 10 ) );

        import std.math;
        addPlane( vec3( 0, 0, 0 ), 3*PI/2.0 );

        makeScales();

    }
protected:
    override void prepare()
    {
        prepareScene();
        prepareInfoText();
        connect( key, ( in KeyboardEvent ev )
        {  
            import std.random;
            float x = uniform( -20.0, 20.0 );
            float y = uniform( -20.0, 20.0 );
            float z = uniform( 1.0, 20.0 );
            if( ev.pressed )
            {
                switch( ev.scan )
                {
                    case ev.Scan.P:
                        SceneObject.switchPhongMode();
                        break;
                    case ev.Scan.N:
                        SceneObject.switchNormDrawing();
                        break;
                    case ev.Scan.L:
                        SceneObject.switchLightning();
                        break;
                    case ev.Scan.NUMBER_1:
                        addBox( vec3( x, y, z ), vec3( 0.5 ) );
                        break;
                    case ev.Scan.NUMBER_2:
                        addSphere( vec3( x, y, z ), 0.5 );
                        break;
                    case ev.Scan.NUMBER_3:
                        addCapsule( vec3( x, y, z ), 2, 0.5 );
                        break;
                    case ev.Scan.NUMBER_4:
                        addDefaultModel( vec3( x, y, z ) );
                        break;
                    case ev.Scan.G:
                        phys_scene.gravity = -phys_scene.gravity;
                        foreach( ref d; objects )
                            d.actor.wakeUp();
                        break;
                    case ev.Scan.F:
                        foreach( ref o; objects )
                            o.actor.addForce( -o.actor.position,
                                                PhysForceMode.IMPULSE,
                                                false );
                        break;
                    case ev.Scan.W:
                        switchPolygonMode();
                        break;
                    default: 
                        break;
                }
            }

            scene.cam.keyControl( ev );
        });

        connect( mouse, (in MouseEvent ev)
        {  
           scene.cam.mouseControl( ev );
        });

        connect( draw, 
        { 
            glEnable( GL_DEPTH_TEST );
            foreach( ref d; objects )
                d.draw(scene); 
            glDisable( GL_DEPTH_TEST );
            glPolygonMode( GL_FRONT_AND_BACK, GL_FILL );
            info_text.draw( size );
            glPolygonMode( GL_FRONT_AND_BACK, polygon_mode );
        });

        connect( idle, 
        { 
            if( timer.time <= 1.0 )
            {
                timer.cycle();
                return;
            }
            phys_scene.process( timer.cycle() );
        });
    }
public:
    this( string title, ivec2 sz, bool fullscreen = false )
    { super( title, sz, fullscreen ); }
}
