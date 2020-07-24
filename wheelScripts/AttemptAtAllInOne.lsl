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
llSetLocalPos(vector offset)
{
    vector save = offset;
    if(offset.x < 0.0) offset.x -= 1;
    else offset.x += 1;
    if(offset.y < 0.0) offset.y -= 1;
    else offset.y += 1;
    if(offset.z < 0.0) offset.z -= 1;
    else offset.z += 1;
    llSetPos(offset);
    llSetPos(save);    
}
vector ConvertGlobalToLocal(vector gpos) {
    list resets = llGetLinkPrimitiveParams(LINK_ROOT,[PRIM_POSITION,PRIM_ROTATION]);
    vector rpPOS = llList2Vector(resets, 0);
    rotation rpROT = llList2Rot(resets, 1);
    return ((gpos - rpPOS)/rpROT);
}

TimerFunct() {
    vector basepos = llList2Vector(llGetLinkPrimitiveParams(2,[PRIM_POSITION]), 0);
    list result = llCastRay(basepos+<0.0,0.0,-0.4>, basepos+<0.0,0.0,-0.8>, [RC_REJECT_TYPES, 0, RC_MAX_HITS, 4]);
    if(llList2Integer(result, -1)> 0) {
        llRegionSayTo(llGetOwner(),0,llDumpList2String(result,","));
        vector detectedP = ConvertGlobalToLocal(llList2Vector(result,1));
        vector newpos = basepos + original_distance;
        if( newpos.z > original_distance.z) TransformZ = newpos.z;
        if(newpos.z < original_distance.z) TransformZ = original_distance.z - basepos.z;
        /////////////////Shock FX/////////////////////
        //V=llGetVel();SP=llVecMag(V);
        //POS_Z  = (UnCompressed+Hadjust)+(SP*0.01)+(V.z*-0.1);       
        //if (SP <= 0 | V.x == 0 ) {POS_Z =  (UnCompressed+Hadjust);} //UnCompressed
        //else if (V.z > 5){POS_Z = (UnCompressed+Hadjust)-CompRange;} //when the car lifts up
        //Maximum Range    
        //else if (POS_Z > (UnCompressed+Hadjust)+CompRange)   {POS_Z = (UnCompressed+Hadjust)+CompRange;} //Compress
        //else if (POS_Z < (UnCompressed+Hadjust)-CompRange)   {POS_Z = (UnCompressed+Hadjust)-CompRange;} //Decompress 
        //llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_POS_LOCAL, <5, 5, detectedP.z>]);
        //llSay(0,(string)<newpos.x, newpos.y, detectedP.z>);
    } else {
        TransformZ = original_distance.z;
    }
        llSetLinkPrimitiveParamsFast(2,[PRIM_POS_LOCAL,<original_distance.x, original_distance.y, TransformZ>]);
}
default{
    state_entry()
    {
        //grab postion of wheel
        vector basepos = llList2Vector(llGetLinkPrimitiveParams(2,[PRIM_POS_LOCAL]), 0);
        vector mypos = llGetLocalPos();
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
        TimerFunct();
    }
}