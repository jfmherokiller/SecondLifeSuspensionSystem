// ZMO VELOCITY SHOCK SYSTEM (V1.0)
// Written by Angie Xenga | Ed Zaurak | August 2012
// NOTE: Any script without this GNU title might not be free. Use at your own risk.
vector  V;
float   SP;
//depending on your vehicle script. you might need change this to fit your vehicle operation.
integer     DIR_RELEASE = 140;
integer     DIR_LEFT    = 150;
integer     DIR_RIGHT   = 160;
//integer     Steer_Compression = FALSE;
float POS_X =-1.23730;//Distance from Root Prim in y axis
float POS_Y = 0.70720;//Dynamically change via script
//Dynamically change via script
float POS_Z;
//Position when not moving
float UnCompressed  = -0.19060;
float CompRange = 0.03000;
float Hadjust;
float TransformZ;
vector original_distance;
default{
    state_entry()
    {
        //grab postion of base
        vector basepos = llList2Vector(llGetLinkPrimitiveParams(LINK_ROOT,[PRIM_POSITION]), 0);
        vector mypos = llGetPos();
        vector subpos = (basepos - mypos);
        original_distance = subpos;
        llSetTimerEvent(0.004);
    }
    collision_start(integer chargeval)
    {
        vector dObject = llDetectedPos(0);
        TransformZ = original_distance.z;
        TransformZ = original_distance.z - dObject.z;
        //POS_Z  = UnCompressed;
    }
    collision_end(integer total_number)
    {
        TransformZ = original_distance.z;
        //POS_Z = UnCompressed-CompRange;
    }
    land_collision_start(vector pos) 
    {
        TransformZ = original_distance.z;
        TransformZ = original_distance.z - pos.z;
    }
    land_collision_end( vector pos )
    {
                TransformZ = original_distance.z;
    }
    link_message(integer snd, integer num, string msg, key id)
    {

    }
    timer()
    {
        list results = llCastRay(llGetPos(), llGetPos()+<0.0, 0.0, -5.0>, [0, 0, 1, TRUE] );
        vector detectedP = llList2Vector(results,1);
        vector basepos = llList2Vector(llGetLinkPrimitiveParams(LINK_ROOT,[PRIM_POSITION]), 0);
        vector newpos = basepos + original_distance;
        if( newpos.z > original_distance.z) TransformZ = original_distance.z;
        /////////////////Shock FX/////////////////////
        //V=llGetVel();SP=llVecMag(V);
        //POS_Z  = (UnCompressed+Hadjust)+(SP*0.01)+(V.z*-0.1);       
        //if (SP <= 0 | V.x == 0 ) {POS_Z =  (UnCompressed+Hadjust);} //UnCompressed
        //else if (V.z > 5){POS_Z = (UnCompressed+Hadjust)-CompRange;} //when the car lifts up
        //Maximum Range    
        //else if (POS_Z > (UnCompressed+Hadjust)+CompRange)   {POS_Z = (UnCompressed+Hadjust)+CompRange;} //Compress
        //else if (POS_Z < (UnCompressed+Hadjust)-CompRange)   {POS_Z = (UnCompressed+Hadjust)-CompRange;} //Decompress 
        llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_POSITION, <newpos.x, newpos.y, detectedP.z>]);
    }
}