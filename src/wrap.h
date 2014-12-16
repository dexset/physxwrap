#ifndef H_WRAP
#define H_WRAP
#include <PxPhysicsAPI.h>

using namespace physx;

extern "C"
{
    bool initializePhysx();
    void deinitPhysx();

    int addPlane( PxVec3* pos, PxVec3* axis, float angle );

    int addBox( PxVec3* pos, PxVec3* size );

    int addCapsule( PxVec3* pos, PxVec3* size );

    void physxStep( float dt );

    void getTransform( unsigned int id, float* data );
}
#endif
