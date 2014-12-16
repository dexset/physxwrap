#include "wrap.h"

PxFoundation* foundation;
PxPhysics* physics;
PxScene* scene;
PxMaterial* material;
PxActor** actors;
unsigned int num_actors;

PxDefaultErrorCallback error_callback;
PxDefaultAllocator allocator_callback;

bool initializePhysx()
{
    foundation = PxCreateFoundation( PX_PHYSICS_VERSION, allocator_callback, 
                                                         error_callback );
    if( !foundation )
        return false;

    physics = PxCreatePhysics( PX_PHYSICS_VERSION, *foundation, PxTolerancesScale() );
    if( !physics )
        return false;

    PxSceneDesc scene_desc( physics->getTolerancesScale() );
    scene_desc.gravity = PxVec3( 0, 0, -9.8 );
    scene_desc.cpuDispatcher = PxDefaultCpuDispatcherCreate(1);
    scene_desc.filterShader = PxDefaultSimulationFilterShader;

    scene = physics->createScene(scene_desc);
    if( !scene )
        return false;

    material = physics->createMaterial( 0.5, 0.5, 0.5 );
    if( !material )
        return false;

    return true;
}

void addAndReallocActors()
{
    PxActor** tmp_actors;
    tmp_actors = new PxActor*[num_actors];
    for( int i = 0; i < num_actors; i++ )
        tmp_actors[i] = actors[i];
    actors = new PxActor*[num_actors + 1];
    for( int i = 0; i < num_actors; i++ )
        actors[i] = tmp_actors[i];
    num_actors++;
}

int addActor( PxTransform t, PxGeometry g, bool isStatic = false )
{
    addAndReallocActors(); 

    unsigned int cur_actor = num_actors - 1;
    if( isStatic )
        actors[cur_actor] = physics->createRigidStatic( t );
    else
        actors[cur_actor] = physics->createRigidDynamic( t );

    ((PxRigidBody*)(actors[cur_actor]))->createShape( g, *material );

    if( !actors[num_actors-1] )
        return -1;

    scene->addActor( *actors[num_actors-1] );
    return num_actors - 1;
}

int addPlane( PxVec3* pos, PxVec3* axis, float angle )
{
    PxTransform t = PxTransform( *pos, PxQuat( angle, *axis ) );
    PxGeometry g = PxPlaneGeometry();
    return addActor( t, g, true );
}

int addBox( PxVec3* pos, PxVec3* size )
{
    PxTransform t = PxTransform( *pos );
    PxGeometry g = PxBoxGeometry( *size );
    return addActor( t, g );
}

int addCapsule( PxVec3* pos, float hheight, float radius )
{
    PxTransform t = PxTransform( *pos );
    PxGeometry g = PxCapsuleGeometry( radius, hheight );
    return addActor( t, g );
}

void getTransform( unsigned int id, float* data )
{
    if( id >= num_actors )
        throw "getTransform";

    PxShape* shp[1];

    ((PxRigidDynamic*)(actors[id]))->getShapes( shp, PxU32(1) );

    PxMat44 shape_pose(PxShapeExt::getGlobalPose(*shp[0], *(PxRigidActor*)(actors[id])));

    for( int i = 0; i < 4; i++ )
        for( int j = 0; j < 4; j++ )
            data[i*4 + j] = shape_pose[j][i];
}

void physxStep( float dt )
{
    scene->simulate( dt );
    scene->fetchResults( true );
}

void deinitPhysx()
{
    scene->release();
    physics->release();
    foundation->release();
}
