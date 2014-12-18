module physxwrap;
import des.math.linear;
import des.view;
import des.util.arch.emm;

class PhysXException : Exception
{
    @safe pure nothrow this( string msg, string file = __FILE__, size_t line = __LINE__ )
    { super( msg, file, line ); }
}

private
{
    alias void* PxFoundation;
    alias void* PxPhysics;
    alias void* PxScene;
    alias void* PxMaterial;
    alias void* PxTransform;
    alias void* PxGeometry;
    alias void* PxActor;
    alias void* PxErrorCallback;
    alias void* PxAllocatorCallback;
    alias float* PxVec3;

    extern(C)
    {

        PxErrorCallback getDefaultErrorCallback();
        PxAllocatorCallback getDefaultAllocatorCallback();

        PxFoundation getFoundation( PxAllocatorCallback, PxErrorCallback );

        PxPhysics getPhysics( PxFoundation );
        bool initExtensions( PxPhysics );
        void closeExtensions();

        PxMaterial getMaterial( PxPhysics, float, float, float );

        PxTransform getTransform( PxVec3, PxVec3, float );

        PxGeometry getPlaneGeometry();
        PxGeometry getBoxGeometry( PxVec3 );
        PxGeometry getCapsuleGeometry( float, float );
        PxGeometry getSphereGeometry( float );

        void getSimplePose( PxActor, float* );
        void actorWakeUp( PxActor );
        void actorAddForce( PxActor, float*, PhysForceMode, bool );
        void actorSetDensity( PxActor, float, float*, bool );

        PxScene getScene( PxPhysics );
        void setGravity( PxScene, PxVec3 );
        PxVec3 getGravity( PxScene );
        PxActor addSimpleObject( PxScene, PxPhysics, PxTransform, PxGeometry, PxMaterial, bool );
        void removeSimpleObject( PxScene, PxActor );

        void simulate( PxScene, float dt );

        void releaseFoundation( PxFoundation );
        void releasePhysics( PxPhysics );
        void releaseScene( PxScene );
    }

    static PxErrorCallback error_callback = null;
    static PxAllocatorCallback allocator_callback = null;
    static PhysFoundation foundation = null;
    static PhysPhysics physics = null;
}

enum PhysForceMode 
{ 
    FORCE, 
    IMPULSE, 
    VELOCITY_CHANGE, 
    ACCELERATION 
}

static this()
{ 
    error_callback = getDefaultErrorCallback();
    allocator_callback = getDefaultAllocatorCallback();

    foundation = new PhysFoundation( allocator_callback, error_callback );
    physics = new PhysPhysics( foundation );
    if( !initExtensions( physics.ptr ) )
        throw new PhysXException( "Error initializing extensions." );
}

static ~this()
{
    closeExtensions();
    releasePhysics( physics.ptr );
    releaseFoundation( foundation.ptr );
}

class PhysBaseObject
{
    invariant()
    { assert( ptr !is null ); }
private:
    void* ptr;
}

class PhysFoundation : PhysBaseObject
{
private:
    this( PxAllocatorCallback allocator, PxErrorCallback error )
    { ptr = getFoundation( allocator, error ); }
}

class PhysPhysics : PhysBaseObject
{
private:
    this( PhysFoundation foundation )
    { ptr = getPhysics( foundation.ptr ); }
}

class PhysMaterial : PhysBaseObject
{
public:
    this( float static_friction, float dynamic_friction, float restitution )
    { ptr = getMaterial( physics.ptr, static_friction, dynamic_friction, restitution ); }
}

class PhysTransform : PhysBaseObject
{
public:
    this( vec3 pos, vec3 axis = vec3( 0, 0, 1 ), float angle = 0.0f )
    { ptr = getTransform( pos.data.ptr, axis.data.ptr, angle );  }
}

class PhysGeometry : PhysBaseObject
{
private:
    this( PxGeometry geometry )
    { ptr = geometry; }
public:
    static PhysGeometry planeGeometry()
    { return new PhysGeometry( getPlaneGeometry() ); }

    static PhysGeometry boxGeometry( vec3 size )
    { return new PhysGeometry( getBoxGeometry( size.data.ptr ) ); }

    static PhysGeometry capsuleGeometry( float half_height, float radius )
    { return new PhysGeometry( getCapsuleGeometry( half_height, radius ) ); }

    static PhysGeometry sphereGeometry( float radius )
    { return new PhysGeometry( getSphereGeometry( radius ) ); }
}

class PhysActor : PhysBaseObject, SpaceNode
{
    mixin SpaceNodeHelper!(true);
private:
    this( PxActor actor, bool is_static )
    { 
        ptr = actor; 
        this.is_static = is_static;
    }

    bool is_static;
public:
    void update()
    { getSimplePose( ptr, cast( float* )self_mtr.data.ptr ); }

    void wakeUp()
    { 
        if( is_static )
            return;
        actorWakeUp( ptr ); 
    }

    void addForce( vec3 force, PhysForceMode mode, bool autowake )
    { actorAddForce( ptr, force.data.ptr, mode, autowake ); }

    void setDensity( float dens, vec3 local_pos = vec3(float.nan), bool include_non_sym = false )
    {
        float* local_pos_data;
        if( !!local_pos )
            local_pos_data = local_pos.data.ptr;
        else
            local_pos_data = null;
        actorSetDensity( ptr, dens, local_pos_data, include_non_sym );
    }
    @property
    {
        bool isStatic() const { return is_static; }
        vec3 position() const { return vec3( matrix.col(3)[0 .. 3] ); }
    }
}

class PhysScene : PhysBaseObject, ExternalMemoryManager
{
    mixin EMM;

protected:
    void selfDestroy()
    { releaseScene( ptr ); }

public:
    this()
    { ptr = getScene( physics.ptr ); }
    @property void gravity( vec3 g )
    { setGravity( ptr, g.data.ptr ); }
    @property vec3 gravity()
    { 
        auto rvec = getGravity( ptr );
        return vec3( rvec[0], rvec[1], rvec[2] ); 
    }

    PhysActor createSimple( PhysTransform transform, PhysGeometry geometry, PhysMaterial material, bool is_static = false )
    { 
        auto actor_ptr = addSimpleObject( ptr, physics.ptr, transform.ptr, geometry.ptr, material.ptr, is_static ); 
        return new PhysActor( actor_ptr, is_static );
    }

    void removeSimple( PhysActor actor )
    { removeSimpleObject( ptr, actor.ptr ); }

    void process( float step )
    { simulate( ptr, step ); }
}
