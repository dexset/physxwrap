module physxwrap;
import des.math.linear;

extern(C)
{
    private
    {
        alias void* PxScene*;
        alias void* PxMaterial*;
        alias void* PxActor*;

        int addPlane( float*, float*, float );
        int addBox( float*, float* );
        int addCapsule( float*, float, float );
        void getTransform( uint, float* );
    }

    bool initializePhysx();
    void deinitPhysx();
    void physxStep( float dt );
}

class PhysXException : Exception
{
    @safe pure nothrow this( string msg, string file = __FILE__, size_t line = __LINE__ )
    { super( msg, file, line ); }
}

class PhysScene
{
    
}

class PhysPlane
{
private:
    uint _id;
public:
    this( vec3 pos, vec3 axis, float angle )
    { _id = addPlane( pos.data.ptr, axis.data.ptr, angle ); }
}

class PhysBox
{
private:
    uint _id;
    mat4 _transform;
public:
    this( vec3 pos, vec3 size )
    { _id = addBox( pos.data.ptr, size.data.ptr ); }

    void update()
    { getTransform( _id, cast(float*)(_transform.data.ptr) ); }

    @property mat4 transform() const
    { return _transform; }
}
