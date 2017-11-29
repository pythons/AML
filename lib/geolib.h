#include<iostream>
#include<cstdio>
#include<algorithm>
#include<cstring>
#include<cmath>
#include<cassert>
using namespace std;
typedef double Float;
class vec2f{
public:
    Float x,y;
    vec2f(){}
    vec2f(Float _x,Float _y):x(_x),y(_y){}
    vec2f operator + (const vec2f &b){return vec2f(x+b.x,y+b.y);}
    vec2f operator - (const vec2f &b){return vec2f(x-b.x,y-b.y);}
    Float operator * (const vec2f &b){return x*b.x+y*b.y;}
    vec2f operator * (Float b){return vec2f(x*b,y*b);}
    vec2f operator / (Float b){return vec2f(x/b,y/b);}
    Float _sqrlen(void){return x*x+y*y;}
    Float _crossprd(const vec2f &b){return x*b.y-b.x*y;}
};
class vec3f{
public:
    Float x,y,z;
    vec3f(){}
    vec3f(Float _x,Float _y,Float _z):x(_x),y(_y),z(_z){}
    vec3f operator + (const vec3f &b){return vec3f(x+b.x,y+b.y,z+b.z);}
    vec3f operator - (const vec3f &b){return vec3f(x-b.x,y-b.y,z-b.z);}
    Float operator * (const vec3f &b){return x*b.x+y*b.y+z*b.z;}
    vec3f operator * (Float b){return vec3f(x*b,y*b,z*b);}
    vec3f operator / (Float b){return vec3f(x/b,y/b,z/b);}
    Float _sqrlen(void){return x*x+y*y;}
    vec3f _crossprd(const vec3f &b){return vec3f(y*b.z-z*b.y,z*b.x-x*b.z,x*b.y-y*b.x);}
};
const Float _PI=acos(-1.0);
class angle{//[-PI,PI]
public:
    vec2f p;
    angle(){}
    angle(Float r){
        p=vec2f(cos(r),sin(r));
    }
    angle(Float _x,Float _y){
        p=vec2f(_x,_y);
    }
    angle operator + (Float d){
        //cos(a+b)=cos(a)cos(b)-sin(a)sin(b)
        //sin(a+b)=cos(a)sin(b)+sin(a)cos(b)
        return angle(p.x*cos(d)-p.y*sin(d),  p.x*sin(d)+p.y*cos(d));
    }
    angle operator - (Float d){
        //cos(a-b)=cos(a)cos(b)+sin(a)sin(b)
        //sin(a-b)=sin(a)cos(b)-cos(a)sin(b)
        return angle(p.x*cos(d)+p.y*sin(d), -p.x*sin(d)+p.y*cos(d));
    }
    angle operator * (Float d){
        Float r=atan2(p.y,p.x);
        return angle(r*d);
    }
    angle _approach(const angle &tgt,const angle &lw,const angle &hi){
        assert(p._crossprd(lw) * p._crossprd(hi) <= 0.0);
        //instead of approaching this angle to tgt, "approach" tgt to this angle
        vec2f ret1,ret2;//ret1: countercloskwise, ret2: clockwise
        if(p._crossprd(tgt)>=0){
            if(p._crossprd(lw)>=0&&lw._crossprd(tgt)>=0){
                ret1=lw;
                ret2=hi;
            }
            else if(p._crossprd(hi)>=0&&hi._crossprd(tgt)>=0){
                ret1=hi;
                ret2=lw;
            }
            else{
                return tgt;
            }
        }
        else{
            if(p._crossprd(lw)<=0&&lw._crossprd(tgt)<=0){
                ret1=lw;
                ret2=hi;
            }
            else if(p._crossprd(hi)<=0&&hi._crossprd(tgt)<=0){
                ret1=hi;
                ret2=lw;
            }
            else{
                return tgt;
            }
        }
        if(fabs(ret1._crossprd(tgt))<=fabs(ret2._crossprd(tgt))){
            return ret1;
        }
        else{
            return ret2;
        }
    }
};
