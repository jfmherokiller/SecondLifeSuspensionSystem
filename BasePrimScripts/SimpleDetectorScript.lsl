
TimerFunct() {
    list result = llCastRay(llGetPos(), llGetPos()+<0.0,0.0,-0.4>, [RC_REJECT_TYPES, 0, RC_MAX_HITS, 4]);
    if(llList2Integer(result, -1)> 0) {
        llRegionSayTo(llGetOwner(),0,llDumpList2String(result,","));
    }
}

default{
    state_entry()
    {
         llSetTimerEvent(2);
    }
    collision_start(integer chargeval)
    {
        vector dObject = llDetectedPos(0);
        llRegionSayTo(llGetOwner(),0, (string)dObject);
    }
    collision_end(integer total_number)
    {
        
    }
    land_collision_start(vector pos) 
    {
        llRegionSayTo(llGetOwner(),0, (string)pos);
    }
    land_collision_end( vector pos )
    {

    }
    timer()
    {
        TimerFunct();
    }
}