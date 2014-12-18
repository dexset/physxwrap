module draw.window;

import des.app;

import des.gl;

import des.util.logsys;

import des.util.timer;

import draw.object;
import draw.camera;

import physxwrap;

class MainWindow : GLWindow
{
private:
    SceneObject[] objects;

    Plane plane;

    MCamera cam;

    PhysScene scene;

    PhysMaterial material;

    Timer timer;

    SceneObject addBox( vec3 pos, vec3 size )
    {
        auto transform = new PhysTransform( pos );
        auto geometry = PhysGeometry.boxGeometry( size );

        auto actor = scene.createSimple( transform, geometry, material );

        objects ~= newEMM!Box( size, actor );
        import std.random;
        objects[$ - 1].actor.setDensity( uniform( 1.0, 10.0 ) );
        return objects[$ - 1];
    }

    SceneObject addSphere( vec3 pos, float radius )
    {
        auto transform = new PhysTransform( pos );
        auto geometry = PhysGeometry.sphereGeometry( radius );

        auto actor = scene.createSimple( transform, geometry, material );

        objects ~= newEMM!Sphere( radius, 50, actor );
        import std.random;
        objects[$ - 1].actor.setDensity( uniform( 1.0, 10.0 ) );
        return objects[$ - 1];
    }

    SceneObject addPlane( vec3 pos, float angle )
    {
        auto transform = new PhysTransform( pos, vec3( 0, 1, 0 ), angle );
        auto geometry = PhysGeometry.planeGeometry();

        auto actor = scene.createSimple( transform, geometry, material, true );

        objects ~= newEMM!Plane( 5000.0, actor );

        return objects[$-1];
    }

    SceneObject addCapsule( vec3 pos, float height, float radius )
    {
        import std.math;
        auto transform = new PhysTransform( pos, vec3( 0, 1, 0 ), PI / 2.0 );
        auto geometry = PhysGeometry.capsuleGeometry( height / 2.0, radius );

        auto actor = scene.createSimple( transform, geometry, material );

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
protected:
    override void prepare()
    {
        timer = new Timer;
        material = new PhysMaterial( 0.5, 0.5, 0.5 );

        scene = newEMM!PhysScene;
        scene.gravity = vec3( 0, 0, -9.8 );

        cam = new MCamera;

        import std.math;
        addPlane( vec3( 0, 0, 0 ), 3*PI/2.0 );

        makeScales();

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
                    case ev.Scan.NUMBER_1:
                        addBox( vec3( x, y, z ), vec3( 0.5 ) );
                        break;
                    case ev.Scan.NUMBER_2:
                        addSphere( vec3( x, y, z ), 0.5 );
                        break;
                    case ev.Scan.NUMBER_3:
                        addCapsule( vec3( x, y, z ), 2, 0.5 );
                        break;
                    case ev.Scan.G:
                        scene.gravity = -scene.gravity;
                        foreach( ref d; objects )
                            d.actor.wakeUp();
                        break;
                    case ev.Scan.F:
                        foreach( ref o; objects )
                            o.actor.addForce( -o.actor.position,
                                                PhysForceMode.IMPULSE,
                                                false );
                        break;
                    default: 
                        break;
                }
            }

            cam.keyControl( ev );
        });

        connect( mouse, (in MouseEvent ev)
        {  
            cam.mouseControl( ev );
        });

        connect( draw, 
        { 
            glEnable( GL_DEPTH_TEST );
            foreach( ref d; objects )
                d.draw(cam); 
        });

        connect( idle, 
        { 
            scene.process( timer.cycle() );
        });
    }
public:
    this( string title, ivec2 sz, bool fullscreen = false )
    { super( title, sz, fullscreen ); }
}
