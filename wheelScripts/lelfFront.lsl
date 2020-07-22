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
float POS_X = 1.05000;//Distance from Root Prim in y axis
float POS_Y = 0.70720;//Dynamically change via script
//Dynamically change via script
float POS_Z;
//Position when not moving
float UnCompressed  = -0.17080;
float CompRange = 0.03000;
float Hadjust;
default
{
    state_entry()
    {
        llSetTimerEvent(0.004);
    }
    collision_start(integer chargeval)
    {
        POS_Z  = UnCompressed;
    }
    collision_end(integer total_number)
    {
        POS_Z = UnCompressed-CompRange;
    }
    link_message(integer snd, integer num, string msg, key id)
    {
        if(num == DIR_RIGHT)POS_Z = (UnCompressed  + 0.5) + V.x*0.01;      
        if(num == DIR_LEFT)POS_Z  = UnCompressed - V.x*0.02;     
        if(num == DIR_RELEASE)POS_Z  = UnCompressed;
        if(msg == "Airborn")POS_Z = UnCompressed-CompRange;
        if(msg == "Land")POS_Z = UnCompressed;
        if(num == 888)Hadjust = (float)msg;
    }
    timer(){
    /////////////////Shock FX/////////////////////
    V=llGetVel();SP=llVecMag(V);
    POS_Z  = (UnCompressed+Hadjust)+(SP*0.01)+(V.z*-0.1);       
    if (SP <= 0 | V.x == 0 ) {POS_Z =  (UnCompressed+Hadjust);} //UnCompressed
    else if (V.z > 5){POS_Z = (UnCompressed+Hadjust)-CompRange;} //when the car lifts up
    //Maximum Range    
    else if (POS_Z > (UnCompressed+Hadjust)+CompRange)   {POS_Z = (UnCompressed+Hadjust)+CompRange;} //Compress
    else if (POS_Z < (UnCompressed+Hadjust)-CompRange)   {POS_Z = (UnCompressed+Hadjust)-CompRange;} //Decompress 
    llSetPrimitiveParams([PRIM_POSITION, <POS_X, POS_Y, POS_Z>]);
    }   
}