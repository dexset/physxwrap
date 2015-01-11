module draw.object.base;

import des.gl.simple;
import des.math.linear;

import des.util.logsys.base;
import des.util.helpers;

import draw.scene;

import physxwrap;

struct ObjectMaterial
{
    vec3 ambient = vec3( 0, 0, 0 );
    vec3 diffuse = vec3( 1, 0, 0 );
    vec3 specular = vec3( 1, 1, 1 );
}

class SceneObject : GLSimpleObject
{
protected:
    GLBuffer vert, index;
    ObjectMaterial material;

    bool with_index;

    static int phong_mode = 2;
    static int draw_norms = 0;
    static int has_light = 1;

    col3 randomColor()
    {
        import std.random;
        auto r = uniform( 0, 1.0 );
        auto g = uniform( 0, 1.0 );
        auto b = uniform( 0, 1.0 );
        return col3( r, g, b );
    }

    void baseDraw( Scene scene, DrawMode mode = DrawMode.TRIANGLE_STRIP )
    {
        actor.update();
        shader.setUniform!mat4( "all_camera_mat", scene.camera_matrix( actor ) );
        shader.setUniform!mat4( "transform_camera_mat", scene.camera_transform_matrix( actor ) );
        shader.setUniform!vec3( "light_pos_transformed", vec3( scene.light_transformed.xyz ) );//TODO not good

        shader.setUniform!vec3( "ambient", material.ambient );
        shader.setUniform!vec3( "diffuse", material.diffuse );
        shader.setUniform!vec3( "specular", material.specular );

        shader.setUniform!vec3( "camera_pos", scene.cam.pos );
        shader.setUniform!int( "draw_norms", draw_norms );

        shader.setUniform!int( "mode", phong_mode );

        shader.setUniform!int( "has_light", has_light );

        if( with_index )
            drawElements( mode );
        else
            drawArrays( mode );
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
    this( PhysActor actor, bool with_index = true, string shader_file = "flat.glsl" )
    {
        this.actor = actor;
        import std.file;

        auto base_shaders = parseShaderSource( readText( appPath( "..", "data", "shaders", shader_file ) ) );
        auto phong_frag_shader = parseShaderSource( readText( appPath( "..", "data", "shaders", "phong_frag.glsl" ) ) )[0];
        super( new CommonShaderProgram( base_shaders ~ phong_frag_shader ) );

        vert = createArrayBuffer();
        this.with_index = with_index;
        if( with_index )
            index = createIndexBuffer();

        setAttribPointer( vert, shader.getAttribLocation( "vert" ), 3, GLType.FLOAT );
    }

    void setColor( col3 c )
    { material.diffuse = c; }

    static void switchPhongMode()
    { phong_mode = phong_mode==1?2:1; }

    static void switchNormDrawing()
    { draw_norms = draw_norms==1?0:1; }

    static void switchLightning()
    { has_light = has_light==1?0:1; }

    abstract void draw( Scene scene );
}
