module draw.object.base;

import des.gl.simple;
import des.math.linear;

import des.util.logsys.base;
import des.util.helpers;

import draw.scene;

import physxwrap;

class SceneObject : GLSimpleObject
{
protected:
    GLBuffer vert, index;
    col4 color;

    col4 randomColor()
    {
        import std.random;
        auto r = uniform( 0, 1.0 );
        auto g = uniform( 0, 1.0 );
        auto b = uniform( 0, 1.0 );
        return col4( r, g, b, 1 );
    }

    void baseDraw( Scene scene )
    {
        actor.update();
        shader.setUniform!mat4( "all_camera_mat", scene.camera_matrix( actor ) );
        shader.setUniform!mat4( "transform_camera_mat", scene.camera_transform_matrix( actor ) );
        shader.setUniform!vec3( "light_pos_transformed", scene.light_transformed.xyz );

        shader.setUniform!vec3( "camera_pos", scene.cam.pos );

        shader.setUniform!col4( "base_color", color );
        shader.setUniform!col4( "light_color", col4(1) );
        shader.setUniform!int( "draw_norms", 0 );

        drawElements( DrawMode.TRIANGLE_STRIP );
    }

    void baseDrawWithPrimitiveRestart( Scene scene, uint restart_index )
    {
        glEnable( GL_PRIMITIVE_RESTART );
        glPrimitiveRestartIndex( restart_index );
        baseDraw( scene );
        glDisable( GL_PRIMITIVE_RESTART );
    }

public:
    PhysActor actor;
    this( PhysActor actor, string shader_file = "flat.glsl" )
    {
        this.actor = actor;
        import std.file;
        super( new CommonShaderProgram( parseShaderSource( readText( appPath( "..", "data", "shaders", shader_file ) ) ) ) );

        vert = createArrayBuffer();
        index = createIndexBuffer();

        setAttribPointer( vert, shader.getAttribLocation( "vert" ), 3, GLType.FLOAT );
    }

    void setColor( col4 c )
    { color = c; }

    abstract void draw( Scene scene );
}
