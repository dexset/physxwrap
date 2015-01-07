#include "wrap.h"

PxErrorCallback* getDefaultErrorCallback()
{ return new PxDefaultErrorCallback(); }

PxAllocatorCallback* getDefaultAllocatorCallback()
{ return new PxDefaultAllocator(); }

PxFoundation* getFoundation( PxAllocatorCallback* allocator, PxErrorCallback* error )
{ return PxCreateFoundation( PX_PHYSICS_VERSION, *allocator, *error ); }

PxPhysics* getPhysics( PxFoundation* foundation )
{ return PxCreatePhysics( PX_PHYSICS_VERSION, *foundation, PxTolerancesScale() ); }

bool initExtensions( PxPhysics* physics )
{ return PxInitExtensions( *physics ); }

void closeExtensions()
{ PxCloseExtensions(); }

PxCooking* getDefaultCooking( PxFoundation* foundation )
{ 
    PxTolerancesScale scale = PxTolerancesScale();
    PxCookingParams params( scale );
    // disable mesh cleaning - perform mesh validation on development configurations
    params.meshPreprocessParams |= PxMeshPreprocessingFlag::eDISABLE_CLEAN_MESH;
    // disable edge precompute, edges are set for each triangle, slows contact generation
    //params.meshPreprocessParams |= PxMeshPreprocessingFlag::eDISABLE_ACTIVE_EDGES_PRECOMPUTE;
    // lower hierarchy for internal mesh
    params.meshCookingHint = PxMeshCookingHint::eCOOKING_PERFORMANCE;
    return PxCreateCooking( PX_PHYSICS_VERSION, *foundation, params ); 
}

PxScene* getScene( PxPhysics* physics )
{
    PxSceneDesc scene_desc( physics->getTolerancesScale() );
    scene_desc.cpuDispatcher = PxDefaultCpuDispatcherCreate(1);
    scene_desc.filterShader = PxDefaultSimulationFilterShader;
    return physics->createScene( scene_desc );
}

void setGravity( PxScene* scene, PxVec3* g )
{ 
    scene->setGravity( *g ); 
}

PxVec3* getGravity( PxScene* scene )
{ scene->getGravity(); }

PxMaterial* getMaterial( PxPhysics* physics, 
                         float static_friction, 
                         float dynamic_friction, 
                         float restitution )
{ return physics->createMaterial( static_friction, dynamic_friction, restitution ); }

PxTransform* getTransform( PxVec3* pos, PxVec3* axis, float angle )
{ return new PxTransform( *pos, PxQuat( angle, *axis ) ); }

PxGeometry* getPlaneGeometry()
{ return new PxPlaneGeometry(); }

PxGeometry* getBoxGeometry( PxVec3* size )
{ return new PxBoxGeometry( *size ); }

PxGeometry* getCapsuleGeometry( float half_height, float radius )
{ return new PxCapsuleGeometry( radius, half_height ); }

PxGeometry* getSphereGeometry( float radius )
{ return new PxSphereGeometry( radius ); }

PxGeometry* getConvexMeshGeometry( unsigned int pcount, unsigned int pstride, void* verts,
                                   PxCooking* cooking, PxPhysics* physics )
{
    PxConvexMeshDesc convex_desc;

    convex_desc.points.count = pcount;
    convex_desc.points.stride = pstride;
    convex_desc.points.data = verts;
    convex_desc.flags = PxConvexFlag::eCOMPUTE_CONVEX | PxConvexFlag::eINFLATE_CONVEX;

    PxDefaultMemoryOutputStream write_buffer;
    PxConvexMeshCookingResult::Enum result;
    bool status = cooking->cookConvexMesh(convex_desc, write_buffer, &result);
    if(!status)
        return NULL;
    PxDefaultMemoryInputData read_buffer(write_buffer.getData(), write_buffer.getSize());
    return new PxConvexMeshGeometry( physics->createConvexMesh(read_buffer) );
}

PxGeometry* getTriangleMeshGeometry( unsigned int pcount, unsigned int pstride, void* verts,
                                     unsigned int tcount, unsigned int tstride, void* indices, 
                                     PxCooking* cooking, PxPhysics* physics )
{
    PxTriangleMeshDesc mesh_desc;

    mesh_desc.points.count = pcount;
    mesh_desc.points.stride = pstride;
    mesh_desc.points.data = verts;

    mesh_desc.triangles.count = tcount;
    mesh_desc.triangles.stride = tstride;
    mesh_desc.triangles.data = indices;

    PxDefaultMemoryOutputStream write_buffer;
    bool status = cooking->cookTriangleMesh(mesh_desc, write_buffer);
    if(!status)
        return NULL;

    PxDefaultMemoryInputData read_buffer(write_buffer.getData(), write_buffer.getSize());

    return new PxTriangleMeshGeometry( physics->createTriangleMesh(read_buffer) );
}

void getSimplePose( PxActor* actor, float* data ) //TODO rework
{
    PxShape* shp[1];
    PxRigidDynamic* rigid = (PxRigidDynamic*)actor;
    rigid->getShapes( shp, PxU32(1) );
    PxMat44 shape_pose = rigid->getGlobalPose(); //(PxShapeExt::getGlobalPose(*shp[0], *rigid));
    for( int i = 0; i < 4; i++ )
        for( int j = 0; j < 4; j++ )
            data[i*4 + j] = shape_pose[j][i];
}

void actorWakeUp( PxActor* actor )
{
    PxRigidDynamic* rigid = (PxRigidDynamic*)actor;
    rigid->wakeUp();
}

void actorAddForce( PxActor* actor, PxVec3* force, PxForceMode::Enum mode, bool autowake )
{
    PxRigidDynamic* rigid = (PxRigidDynamic*)actor;
    rigid->addForce( *force, mode, autowake );
}

void actorSetDensity( PxActor* actor, float density, PxVec3* local_pos, bool include_non_sym )
{
    PxRigidDynamic* rigid = (PxRigidDynamic*)actor;
    PxRigidBodyExt::updateMassAndInertia( *rigid, density, local_pos, include_non_sym );
}

PxActor* addSimpleObject( PxScene* scene, 
                         PxPhysics* physics, 
                         PxTransform* transform, 
                         PxGeometry* geometry,
                         PxMaterial* material, 
                         bool isStatic, bool isKinematic )
{
    PxActor* actor;
    if( isStatic )
        actor = physics->createRigidStatic( *transform );
    else
    {
        actor = physics->createRigidDynamic( *transform );
        ((PxRigidDynamic*)(actor))->setRigidDynamicFlag(PxRigidDynamicFlag::eKINEMATIC, isKinematic);
    }

    PxShape* shape = ((PxRigidBody*)(actor))->createShape( *geometry, *material );

    if( isKinematic )
        shape->setFlag(PxShapeFlag::eSIMULATION_SHAPE, true);

    scene->addActor( *actor );
    return actor;
}

void removeSimpleObject( PxScene* scene, PxActor* actor )
{ scene->removeActor( *actor ); }

void simulate( PxScene* scene, float dt )
{
    scene->simulate( dt );
    scene->fetchResults( true );
}

void releaseFoundation( PxFoundation* foundation )
{ foundation->release(); }

void releasePhysics( PxPhysics* physics )
{ physics->release(); }

void releaseCooking( PxCooking* cooking )
{ cooking->release(); }

void releaseScene( PxScene* scene )
{ scene->release(); }
