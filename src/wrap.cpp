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
{ PxCreateCooking(PX_PHYSICS_VERSION, *foundation, PxCookingParams( PxTolerancesScale() )); }

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
                         bool isStatic )
{
    PxActor* actor;
    if( isStatic )
        actor = physics->createRigidStatic( *transform );
    else
        actor = physics->createRigidDynamic( *transform );

    ((PxRigidBody*)(actor))->createShape( *geometry, *material );

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
