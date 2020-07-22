vector rezzer_pos =<122.56290, 177.22310, 1750.81200>;  
// the position of the rezzer when first you set it up -- read with llOwnerSay((string)llGetPos());in another script
rotation rezzer_rot  =<0.00000, 0.70711, 0.00000, 0.70711>; 
//rotation of the rezzer, ditto --  read with llOwnerSay((string)llGetRot());in another script
vector child_pos = <122.71410, 175.05910, 1750.81200>; 
// the position of the rezzed object at first set up
rotation child_rot= <0.00000, 1.00000, 0.00000, 0.00000>;
//rotation of rezzed object
vector offset;
default{    
    state_entry()    
    {        
        offset = child_pos-rezzer_pos;
        offset = offset/rezzer_rot;
    }    
    touch_start(integer total_number)    { 
        llRezAtRoot(llGetInventoryName(INVENTORY_OBJECT,0),llGetPos()+offset*llGetRot(),ZERO_VECTOR,(child_rot/rezzer_rot)*llGetRot(),99);    
    }
}