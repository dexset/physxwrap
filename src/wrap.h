#ifndef H_WRAP
#define H_WRAP
#include <PxPhysicsAPI.h>

using namespace physx;

extern "C"
{
    PxErrorCallback* getDefaultErrorCallback();
    PxAllocatorCallback* getDefaultAllocatorCallback();

    PxFoundation* getFoundation( PxAllocatorCallback*, PxErrorCallback* );

    PxPhysics* getPhysics( PxFoundation* );

    bool initExtensions( PxPhysics* );
    void closeExtensions();

    PxCooking* getDefaultCooking( PxFoundation* foundation );

    PxScene* getScene( PxPhysics* );

    PxMaterial* getMaterial( PxPhysics*, float, float, float );

    PxTransform* getTransform( PxVec3*, PxVec3*, float );

    PxGeometry* getPlaneGeometry();
    PxGeometry* getBoxGeometry( PxVec3* );
    PxGeometry* getCapsuleGeometry( float, float );
    PxGeometry* getSphereGeometry( float );

    PxGeometry* getConvexMeshGeometry( unsigned int pcount, unsigned int pstride, void* verts,
                                     PxCooking* cooking, PxPhysics* physics );
    PxGeometry* getTriangleMeshGeometry( unsigned int pcount, unsigned int pstride, void* verts,
                                     unsigned int tcount, unsigned int tstride, void* indices, 
                                     PxCooking* cooking, PxPhysics* physics );

    void actorWakeUp( PxActor* );
    void getSimplePose( PxActor*, float* );
    void actorAddForce( PxActor*, PxVec3*, PxForceMode::Enum, bool );
    void actorSetDensity( PxActor*, float, PxVec3*, bool );

    void setGravity( PxScene*, PxVec3* );
    PxVec3* getGravity( PxScene* );
    PxActor* addSimpleObject( PxScene*, PxPhysics*, PxTransform*, PxGeometry*, PxMaterial*, bool, bool );
    void removeSimpleObject( PxScene*, PxActor* );

    void simulate( PxScene*, float dt );

    void releaseFoundation( PxFoundation* );
    void releasePhysics( PxPhysics* );
    void releaseCooking( PxCooking* );
    void releaseScene( PxScene* );
}
#endif
