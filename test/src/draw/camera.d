module draw.camera;

import des.view;
import std.math;

import des.app.event;

class MCamera : Camera
{
protected:
    LookAtTransform look_tr;

    vec3 orb;
    vec2 rot;

    float y_angle_limit = PI_2 - 0.01;

public:

    PerspectiveTransform perspective;

    this()
    {
        super();
        look_tr = new LookAtTransform;
        orb = vec3(0,10,2);
        look_tr.target = vec3(0,0,0);
        look_tr.up = vec3(0,0,1);
        updatePos();
        transform = look_tr;
        perspective = new PerspectiveTransform; 
        perspective.near = 0.1;
        projection = perspective;
    }

    @property 
    {
        void target( in vec3 t )
        {
            look_tr.target = t;
            updatePos();
        }
        vec3 target() const { return look_tr.target; }
    }

    void addRotate( in vec2 angle )
    {
        rot = normRotate( rot + angle );
        orb = vec3( cos(rot.x) * cos(rot.y),
                    sin(rot.x) * cos(rot.y),
                    sin(rot.y) ) * orb.len;
        updatePos();
    }

    void moveFront( float dist )
    {
        orb += orb * dist;
        if( orb.len2 < 1 ) orb = orb.e;
        updatePos();
    }

    void moveCenter( in vec2 offset )
    {
        auto lo = (look_tr.matrix * vec4(offset,0,0)).xyz;
        look_tr.target += lo;
        updatePos();
    }

    void mouseControl( in MouseEvent ev )
    {
        if( ev.type == MouseEvent.Type.WHEEL )
            moveFront( -ev.whe.y * 0.1 );

        if( ev.type == ev.Type.MOTION )
        {
            if( ev.isPressed( ev.Button.LEFT ) )
            {
                auto frel = vec2( ev.rel ) * vec2(-1,1);
                auto angle = frel / 80.0;
                addRotate( angle );
            }
            if( ev.isPressed( ev.Button.MIDDLE ) )
            {
                auto frel = vec2( ev.rel ) * vec2(-1,1);
                auto offset = frel / 50.0 * sqrt( orb.len );
                moveCenter( offset );
            }
        }
    }

    void keyControl( in KeyboardEvent ev )
    {
        if( ev.scan == ev.Scan.NUMBER_0 )
        {
            look_tr.target = vec3(0,0,0);
            updatePos();
        }
    }

protected:

    vec2 normRotate( in vec2 r )
    {
        vec2 ret = r;
        if( ret.y > y_angle_limit ) ret.y = y_angle_limit;
        if( ret.y < -y_angle_limit ) ret.y = -y_angle_limit;
        return ret;
    }

    void updatePos()
    {
        look_tr.pos = orb + look_tr.target;
    }
}
