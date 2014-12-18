module draw.object.base;

import des.gl.simple;
import des.math.linear;

import des.util.logsys.base;
import des.util.helpers;

import draw.camera;

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

public:
    PhysActor actor;
    this( PhysActor actor )
    {
        glPointSize(3);
        this.actor = actor;
        import std.file;
        super( new CommonShaderProgram( parseShaderSource( readText( appPath( "..", "data", "shaders", "object.glsl" ) ) ) ) );

        vert = createArrayBuffer();
        index = createIndexBuffer();

        setAttribPointer( vert, shader.getAttribLocation( "vert" ), 3, GLType.FLOAT );
    }

    void setColor( col4 c )
    { color = c; }

    void draw( MCamera cam )
    {
        actor.update();
        shader.setUniform!mat4( "prj", cam.projection.matrix * cam.resolve(actor) );
        shader.setUniform!col4( "col", color );

        //glPolygonMode( GL_FRONT_AND_BACK, GL_LINE );
        drawElements( DrawMode.TRIANGLE_STRIP );
    }
}
