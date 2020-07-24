
integer NumberOfDetections;
key lastDetection;
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
ObjectDetected(list result) {
    llRegionSayTo(llGetOwner(),0,llDumpList2String(result,","));
    vector detectedP = ConvertGlobalToLocal(llList2Vector(result,1));
    vector basepos = llList2Vector(llGetLinkPrimitiveParams(LINK_ROOT,[PRIM_POS_LOCAL]), 0);
    if((lastDetection != llList2Key(result,0)) || (NumberOfDetections > 10)) {
        lastDetection = llList2Key(result,0);
        NumberOfDetections = 0;
        MoveWheel(detectedP,basepos);
    } else {
        TransformZ = original_distance.z;
        NumberOfDetections++;
    }
}
MoveWheel(vector detected,vector base) {
    //add one because starts inside
    TransformZ = detected.z+0.5;
}
TimerFunct() {
    vector basepos = llList2Vector(llGetLinkPrimitiveParams(2,[PRIM_POSITION]), 0);
    list result = llCastRay(basepos, basepos+<0.0,0.0,-0.5>, [RC_REJECT_TYPES, 0, RC_MAX_HITS, 1,RC_DETECT_PHANTOM,TRUE]);
    if(llList2Integer(result, -1)> 0) {
        ObjectDetected(result);
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
        original_distance = basepos;
        TransformZ = original_distance.z;
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
