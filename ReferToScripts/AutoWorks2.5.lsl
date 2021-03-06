// Autoworks VOS 2.5b /////////////////////////////////////////////////
// A derivative script work from D> Concept Car by Damen Hax
// with ZMO Autoworks Engine Script Snipbits & Additions
// This is the result of 2 year LSL research (+ additional time from others)
// Offered to you Free without any warranty or service.
// That means "No Help" will be given from Any Staff of ZMO Autoworks.
// All Script writing including custom work requests will be ignored.
// So if you mess it up...good luck.
// Remember Always to keep an original and work off copies.
//
// ...and as always, do something creative and inspire other to do the same!
// Ed, Angie & Autoworks
//////////////////////////////////////////////////////////////////////

// S C R I P T B E G I N //

/////For Personal Settings
////////////////////////////// Engine Startup settings
START_UP(){
Access = "Owner"; //Owner or Public
Crash_Active=FALSE;
BankAngle = 2.5;
ActiveRallyAngle=2.6;//(Note: Can not be lower then Bank Angle.) Drift Goes Active at this banking Angle.
ActiveRally=FALSE;
Gear_Power=[-15,0,10,20,30,50,70,90,110,130,150,170];
NumGear_Power=12;// 15 is Max for Text hud display.
VLDE=0.990; //VEHICLE_LINEAR_DEFLECTION_EFFICIENCY //0.950
VLDT=0.250; //VEHICLE_LINEAR_DEFLECTION_TIMESCALE //stay as is
VADE=0.113; //VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY // 0.225 less turn for high speed tracks
VADT=0.232; //VEHICLE_ANGULAR_DEFLECTION_TIMESCALE // 0.225 less turn for high speed tracks
VAMT=0.100; //VEHICLE_ANGULAR_MOTOR_TIMESCALE //0.195 less turn for high speed tracks
VAMDT=0.100; //VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE //0.090 less turn for high speed tracks

//// VEHICLE_LINEAR_FRICTION_TIMESCALE
VLFT_X=15.00; VLFT_Y=0.010; VLFT_Z=100.0;
//// VEHICLE_ANGULAR_FRICTION_TIMESCALE
VAFT_X=0.400; VAFT_Y=20.000; VAFT_Z=15.00; // VAFT_Z=85.00 less turn for high speed tracks

VVAE=0.450;// VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY ///Suspension
VVAT=2.500;// VEHICLE_VERTICAL_ATTRACTION_TIMESCALE ///Vehicle Weight/Float High=More Low=Less
VLMT=0.250;// VEHICLE_LINEAR_MOTOR_TIMESCALE
VLMDT=0.001;// VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE ///Braking

//Gas
Pedal_Ratio=0.05;
Release_Ratio=0.0075;

//BRAKES
BrakePower=20;
Brake_Speed=5;

dead_zone=1.25;//Steering Deadzone
STR_Response=1.65;//Driver Steering Response //0.975 less turn for high speed tracks
Initial_Steer=15.0;//Speed in X axis
Peak_Steer=105.0;//Speed in X axis //195 Increase for high speed tracks
Max_Response=23.5;//Steering Parabolic Curve for Speed above Peak_Steer. //12.5 less turn for hight speed tracks

Burn_Boost=54;//Burnout Slip Max velocity at Y axis
Slip_Max=6.5;//Slip Dissipate Velocity in Y axis|SlipDriftOFF();
Slip_Fuel_CutOff=0.4;//Gas Off for Slip_Max Off

//VEHICLE_LINEAR_MOTOR_OFFSET //Center of Gravity
VLMO_X_init=0.0;
VLMO_Z=1.7;

//APPLIED DOWNFORCE
DownForce=22;

Set_Parameters();
}

GainAccess(){ //can also be configured for engine on/off with if/else statement with-in this sub routine
llTriggerSound(StartupSound, 1.0);
llSetPos(llGetPos() + <0,0,0.15>);
llSetStatus(STATUS_PHYSICS, TRUE);
SimName = llGetRegionName();
CurDir = DIR_STOP;
LastDir = DIR_STOP;
}

///Main Variables////////////////////////////////////////////////////////////////////////////////////////

///Owner/Driver Check
key Owner;
key sitting;
string Access;
string SitText = "Race"; //Text to show on pie menu
string NonOwnerMessage = "It's Locked Dude!"; //Message when someone other than owner tries to sit

///Motion Variables
vector SpeedVec; ////Speed in Vector
vector Linear;
vector Angular;

///Vehicle Location Variable
integer Active;
integer Moving;
string SimName;

////Vehicle Operations////////////////////////////////////////////////////////////////////////////////////////

//// Gas & Gear
/////////////Gear = 0 1 2 3 4 5 6 7 8 9 10
list Gear_Power;
integer NumGear_Power; //Identify Numbers of Gear
integer Gear = 0; //first of the list
string Current_Gear; //Hud Indicator

//integer Travel_Dir;
integer SayGear = FALSE; //Show Gear in Chat
integer Gas_On; //Foward Key Pressed | Released
integer Brake_On; //Backward Key Pressed | Released
float Pedal_Ratio; //Gas Pedal Down
float Release_Ratio; //Gas Pedal Release
float Fuel; //Fuel
float Power; //Forward power

//// Steering
float timing = 0.02; //script runtime speed
float dynamic_steering; //Dynamic_Steering
integer turn_direction; //Turn direction
float turning = 1.0; //turn speed 1.0 is Default.
float dead_zone; //Steering End Lowest Speed
float STR_Response; //Steering Response for Driver & Steering Ratio
float Initial_Steer; //Driver Initial Steering stages
float Peak_Steer; //Driver / Vehicle Steering Peak Performance
float Max_Response; //Overall Maximum Response above Peak Perfomance
integer BURN = 0; //Drift & Burn Logic // 2 = BURN 1 = Skid 0 = Off
float Brake_Speed; //Min Braking Speed for Smoke and Squeek
integer SKID = FALSE; //Brake Skid Logic
float Slip_Max;
float Slip_Fuel_CutOff;
float Burn_Boost;
float BrakePower; //Brake Padel Power
float DownForce; //Downforce

//Direction & Messaging
integer CurDir;
integer LastDir;
integer DIR_START = 100;
integer SHUT_DW = 110;
integer DIR_RELEASE = 140;
integer DIR_LEFT = 150;
integer DIR_RIGHT = 160;
integer DIR_FWD = 170;
integer DIR_BACK = 180;
integer DIR_STOP = 190;

//Sound
//Thematic Sound Original from ZMO
string CurSound;
string LastSound;
string OwnerName;
string      IdleSound   = "Feet_Abarth_Idle";           //"Idle";
string      Low_Sound   = "Fiat_Abarth_Low";            //Sound to play when RPM at Low
string      Med_Sound   = "Fiat_Abarth_Med";            //Sound to play when RPM at Med
string      Max_Sound_G1   = "Fiat_Abarth_Max3_G1";     //Sound to play when RPM at Max
string      Max_Sound_G2   = "Fiat_Abarth_Max3_G2";     //Sound to play when RPM at Max
string      Burn_Sound  = "Fiat_Abarth_Max3_G3";        //Sound to play when Burning Out
string      Skid_Sound  = "squeech105MonoLong";         //Sound to play when Braking
// Secondary Sound
string      Reverse_Sound   = "Reverse";                //Sound to play when in Reverse
string      Rev_Sound       = "Fiat_Abarth_Rev";        //Sound to play when reving in neutrual
string      Shift_Sound   = "Shift";                    //Sound to play when shifting
string      StartupSound    = "Fiat_Abarth_Start";      //Sound to play when driver sits
string      ShutdownSound   = "Dink";                   //Sound to play when shutting down

//Lighting
integer CurLight;
integer LastLight;
integer LITE_GASOFF = 200;
integer LITE_BRAKE_L = 210;
integer LITE_REV_L = 211;
integer LITE_OFF = 220;

SetGearName(){
///Set Gear Text
        if (Gear == 0){Current_Gear = "R1"; Reverse_Camera();}
        if (Gear == 1){Current_Gear = "N"; Default_Camera();}
        // First foward gear is 2. 2-1 = 1 for "Gear 1"
        else if (Gear >= 1) {Current_Gear = (string)(Gear - 1);}
        if(SayGear == TRUE)llOwnerSay(Current_Gear);
}

//Animations
//string startup_anim = " ";
string steer_straight = "Left Release";
string steer_right = "Right";
string steer_left = "Left";

StopLeftRight(){
    llStopAnimation(steer_left);
    llStopAnimation(steer_right);
    llStartAnimation(steer_straight);
}

////Anti Flight / Position Detector///
integer FlightWarning = FALSE;
integer FlightSafety = TRUE;
vector curPos_A; //Wait curPos_time then check position.
vector curPos_B; //Get current Position
integer curPos_time = 3; //Positon Detect Timer

////Vehicle Parameters////////////////////////////////////////////////////////////////////////////////////////
////No need to set the numbers here
////Please set it under "START_UP()" Sub-Routine

////Note: similar to force feedback. driver's reaction time vs gravity and motion
float VLDE; //// VEHICLE_LINEAR_DEFLECTION_EFFICIENCY
float VLDT; //// VEHICLE_LINEAR_DEFLECTION_TIMESCAL
float VADE; //// VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY
float VADT; //// VEHICLE_ANGULAR_DEFLECTION_TIMESCALE

float VLMT; //// VEHICLE_LINEAR_MOTOR_TIMESCALE, //// Fuel Flow
float VLMDT; //// VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE //// Stopping Power / Brakes Friction

float VAMT; //// VEHICLE_ANGULAR_MOTOR_TIMESCALE
float VAMDT; //// VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE

//// VEHICLE_LINEAR_FRICTION_TIMESCALE
float VLFT_X;
float VLFT_Y;
float VLFT_Z;

//// Tire LSD simulation
float Friction_Y;

//// VEHICLE_ANGULAR_FRICTION_TIMESCALE
float VAFT_X;
float VAFT_Y;
float VAFT_Z;

//// VEHICLE_LINEAR_MOTOR_OFFSET ////Center of Gravity
float VLMO_X;
float VLMO_X_init; /// Initial Starting Point
float VLMO_Y;
float VLMO_Z;
float VLMO_Z_M; /// Z multiplyer for Flight Suppression

float VVAE; //// VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY
float VVAT; //// VEHICLE_VERTICAL_ATTRACTION_TIMESCALE

///Hovering Variables
//float VHH; //// VEHICLE_HOVER_HEIGHT
//float VHE; //// VEHICLE_HOVER_EFFICIENCY
//float VHT; //// VEHICLE_HOVER_TIMESCALE
//float VB; //// VEHICLE_BUOYANCY


//Set Vehicle Parameters
Set_Parameters(){
        Linear=ZERO_VECTOR;Angular=ZERO_VECTOR;
        llSetVehicleType(VEHICLE_TYPE_CAR);
        
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_OFFSET, ZERO_VECTOR);
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, ZERO_VECTOR);
        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, ZERO_VECTOR);
        llSleep(0.01);
        llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, VLDE);
        llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, VLDT);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, VADE);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, VADT);
        llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, VLMT+Fuel);
        llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, VLMDT);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, VAMT);
        llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, VAMDT);
        llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <VAFT_X, VAFT_Y, VAFT_Z> );
        llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <VLFT_X,VLFT_Y, VLFT_Z>);
        llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, VVAE);
        llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, VVAT);
        llSetVehicleFloatParam(VEHICLE_BANKING_EFFICIENCY, -1);
        
        llSetTimerEvent(timing);

        llSetVehicleFlags(
          VEHICLE_FLAG_HOVER_UP_ONLY
        | VEHICLE_FLAG_LIMIT_ROLL_ONLY
        | VEHICLE_FLAG_NO_DEFLECTION_UP
        | VEHICLE_FLAG_LIMIT_MOTOR_UP
        );
        
        llRemoveVehicleFlags(
          VEHICLE_FLAG_HOVER_WATER_ONLY
        | VEHICLE_FLAG_HOVER_TERRAIN_ONLY
        | VEHICLE_FLAG_HOVER_GLOBAL_HEIGHT
// | VEHICLE_FLAG_LIMIT_ROLL_ONLY
// | VEHICLE_FLAG_NO_DEFLECTION_UP
// | VEHICLE_FLAG_LIMIT_MOTOR_UP
// | VEHICLE_FLAG_HOVER_UP_ONLY
        );
}
///Set Hud
SetHud(){
            vector text_color; string hud_text; string burn_text; string fuel_text; string gear_text;
            text_color = <Fuel, Fuel, Fuel>;
            if (BURN == 2){burn_text = "OOoo..⨀"; text_color = <1, 0, 0>;}
            if (BURN == 1){burn_text = "______⨀"; text_color = <1, 1, 0>;}
            if (BURN == 0){burn_text = " ⨂"; text_color = <Fuel, Fuel, Fuel>;}
            ////Gear Guage
            if (Current_Gear == "R1") gear_text=" R";
            if (Current_Gear == "N") gear_text=" N";
            if (Current_Gear == "1") gear_text=" 1";
            if (Current_Gear == "2") gear_text=" 2";
            if (Current_Gear == "3") gear_text=" 3";
            if (Current_Gear == "4") gear_text=" 4";
            if (Current_Gear == "5") gear_text=" 5";
            if (Current_Gear == "6") gear_text=" 6";
            if (Current_Gear == "7") gear_text=" 7";
            if (Current_Gear == "8") gear_text=" 8";
            if (Current_Gear == "9") gear_text=" 9";
            if (Current_Gear == "10") gear_text="10";
                        
            if (Crash_Logic == FALSE){
            hud_text =
            
            gear_text+" "+burn_text+"\n \n \n"+
            
            //////////////Debugging//////////////////
            //(string)(Angular.x)+"\n \n \n"+
            //Turn Ratio
            //(string)llRound(turning)+"\n"+
            
            //Round-off Speed in Vector for X, Y, Z
            //(string)llRound(SpeedVec.x)+" "+(string)llRound(SpeedVec.y)+" "+(string)llRound(SpeedVec.z)+" "+"\n"+
            
            //Extra Space to raise the text.
            "\n \n \n \n \n \n \n \n \n";
            }
            
            if (Active == 0){hud_text ="";}
            if (Crash_Logic == TRUE){
            text_color = <1,0,0>;
            hud_text = "C R A S H E D"+"\n\n"+"Left Mouse Click to Reset";
            }
            llSetText(hud_text,text_color,1);
            if(Active)llMessageLinked(LINK_ALL_CHILDREN, 900, (string)Fuel, NULL_KEY);
            
}
///////////////////CAMERA PARAMETERS ///////////////////
////Default Camera
Default_Camera(){
    cam_active = 1;
    cam_b_angle = 15.00;
    cam_b_lag = 0.010;
    cam_dist = 4.000;
    cam_focus_lag = 0.001;
    cam_focus_thr = 0.500;
    cam_pitch = 10.00;
    cam_pos_lag = 0.010;
    cam_pos_thr = 0.500;
    cam_focus_off = <2,0,0.5>;
    Set_Camera_Parameters();
}

Burn_Camera(){ llSetCameraParams([CAMERA_BEHINDNESS_ANGLE, 50.00]);}

Speed_Camera(){ llSetCameraParams([CAMERA_BEHINDNESS_ANGLE, 15.00]);}

////Reverse Camera
Reverse_Camera(){
    cam_b_angle = 180.00;
    cam_b_lag = 0.200;
    cam_dist = 4.000;
    cam_focus_lag = 0.200;
    cam_pitch = 1.000;
    Set_Camera_Parameters();
}

integer cam_active;
float cam_b_angle;
float b_angle_add;
float cam_b_lag;
float b_lag_add;
float cam_dist;
float cam_focus_lag;
float cam_focus_thr;
float cam_pitch;
float cam_pos_lag;
float cam_pos_thr;
vector cam_focus_off;

Set_Camera_Parameters(){
    llClearCameraParams(); // reset camera to null
    llSetCameraParams([
    CAMERA_ACTIVE, cam_active, // 1 is active, 0 is inactive
    CAMERA_BEHINDNESS_ANGLE, cam_b_angle, // (0 to 180) degrees
    CAMERA_BEHINDNESS_LAG, cam_b_lag, // (0 to 3) seconds
    CAMERA_DISTANCE, cam_dist, // ( 0.5 to 10) meters
    // CAMERA_FOCUS, <0,0,0>, // region-relative position
    CAMERA_FOCUS_LAG, cam_focus_lag, // (0 to 3) seconds
    CAMERA_FOCUS_LOCKED, FALSE, // (TRUE or FALSE)
    CAMERA_FOCUS_THRESHOLD, cam_focus_thr, // (0 to 4) meters
    CAMERA_PITCH, cam_pitch, // (-45 to 80) degrees
    //CAMERA_POSITION, <0,0,0>, // region-relative position
    CAMERA_POSITION_LAG, cam_pos_lag, // (0 to 3) seconds
    CAMERA_POSITION_LOCKED, FALSE, // (TRUE or FALSE)
    CAMERA_POSITION_THRESHOLD, cam_pos_thr, // (0 to 4) meters
    CAMERA_FOCUS_OFFSET, cam_focus_off // <-10,-10,-10> to <10,10,10> meters
    ]);
}

////BURNOUT EQUATION
//Note: can be used as SlIP logic with less linear push on axis Y
float BankAngle;
integer ActiveRally;
float ActiveRallyAngle; //Drift Goes Active at this banking Angle.

Burnout(){
    Gas_On = TRUE;
    if(Gear > 1)Burn_Camera();
    float VMT_EQ = llFabs(SpeedVec.y/SpeedVec.x)*(Fuel*300);
    float LSD_EQ = -Angular.z*Fuel*(llFabs(SpeedVec.y)*20/llFabs(SpeedVec.x));
    float Slip_EQ_X = 100*Fuel*llFabs(SpeedVec.x);
    float Slip_EQ_Y = 100*Fuel*( llFabs(SpeedVec.x)/llFabs(SpeedVec.y) );
    llMessageLinked(LINK_ALL_CHILDREN, 0, "Burn", NULL_KEY);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_OFFSET, <100,VLMO_Y*llFabs(Angular.z), VLMO_Z*VLMO_Z_M>); ////Center of Gravity
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, VLMT+VMT_EQ);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <Linear.x,LSD_EQ,Linear.z>);
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <Slip_EQ_X, Slip_EQ_Y, 1000>); //VLFT_X*( 0.1 * (1+llFabs(Gear)) )
}

Burnout2(){
    Gas_On = TRUE;
    if(Gear > 1)Burn_Camera();
    float VMT_EQ = Fuel*30;
    float Slip_EQ_X = 100*Fuel*llFabs(SpeedVec.x);
    float Slip_EQ_Y = 100*Fuel*( llFabs(SpeedVec.x)/(1+llFabs(SpeedVec.y)) );
    llMessageLinked(LINK_ALL_CHILDREN, 0, "Burn", NULL_KEY);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <Linear.x,Linear.y,Linear.z>);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_OFFSET, <100,VLMO_Y*llFabs(Angular.z), VLMO_Z*VLMO_Z_M>); ////Center of Gravity
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, VLMT+VMT_EQ);
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <Slip_EQ_X, Slip_EQ_Y, 1000>); //VLFT_X*( 0.1 * (1+llFabs(Gear)) )
}

Burn2OFF(){
    BURN = 0;
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, VLMT+Fuel);
    llMessageLinked(LINK_ALL_CHILDREN, 0, "SmokeOff", NULL_KEY);
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <VLFT_X, 0, VLFT_Z>);
    llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <VAFT_X, VAFT_Y, VAFT_Z>);
}
    
SlipMin(){
    llMessageLinked(LINK_ALL_CHILDREN, 0, "Smoke", NULL_KEY);
    llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <0,VAFT_Y,200>);
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <VLFT_X*0.3,11000,VLFT_Z>);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <Linear.x*0.8,-Angular.z*0.0001*(llFabs(SpeedVec.y)/llFabs(SpeedVec.x)),Linear.z>);
}

SlipDriftOFF(){
    Gas_On = FALSE;
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, VLMT+Fuel);
    llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_OFFSET, ZERO_VECTOR);
    
    if (llFabs(SpeedVec.y) > Slip_Max && BURN != 0)
    {
        llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <VLFT_X*0.3, 45*llFabs(SpeedVec.y), VLFT_Z>);
        llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0, -Angular.z*llFabs(Linear.y)*10, Linear.z>);
    }
    
    if (llFabs(SpeedVec.y) < Slip_Max | SKID == FALSE)
    {
        if(Gear > 1)Speed_Camera();
        BURN = 0;
        llMessageLinked(LINK_ALL_CHILDREN, 0, "SmokeOff", NULL_KEY);
        llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <VLFT_X, 0, VLFT_Z>);
        llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <VAFT_X, VAFT_Y, VAFT_Z>);
    }
}
////BURNOUT EQUATION

//// CRASH
integer Crash_Active;
integer Crash_Logic = FALSE;

Crash(){
        BURN = 0;
        Gas_On = FALSE;
        llSetVehicleType(VEHICLE_TYPE_NONE);
        llMessageLinked(LINK_SET, 0, "Crashed", NULL_KEY);
}
    
Recover(){
        //-- convert our rotation to x/y/z radians
        vector vRadBase = llRot2Euler( llGetRot() );
        //-- round the z-axis to the nearest 90deg (PI_BY_TWO = 90deg in radians)
        llRotLookAt( llEuler2Rot( <0.0, 0.0, llRound( vRadBase.z / PI_BY_TWO ) * PI_BY_TWO > ),0.1, 3);
        Set_Parameters();
        llSetText("wait one sec...",<1,1,1>,1);
        llSleep(1.0);
        llRotLookAt(llEuler2Rot(ZERO_VECTOR), 0, 0);
        llSleep(1.0);
        llMessageLinked(LINK_SET, 0, "CrashReset", NULL_KEY);
}
//// CRASH

default
{
    //One of the most important part of the script.
    //If used correcctly "Timer" events can improve vehicle performance.
    
    timer()
    {
//// Motion
            SpeedVec = llGetVel() / llGetRot(); ////Speed in Vector

            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, Linear); ////Linear Motion

            llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, Angular); ////Angular Motion

            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_OFFSET, <VLMO_X, VLMO_Y, VLMO_Z*VLMO_Z_M>); ////Center of Gravity
            
            if (llFabs(SpeedVec.x) < 10){ // Vehicle comes to a stop the Center of Gravity will be zero.
                llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_OFFSET, ZERO_VECTOR);
            }

            //To ensure full stop
            if (llFabs(SpeedVec.x) < 2.0 && Gas_On == FALSE && BURN == 0){
                llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_OFFSET, ZERO_VECTOR);
                llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, ZERO_VECTOR);
                llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, ZERO_VECTOR);
                Linear.z = 0;
            }
            
            //Neutural will not move when press Gas.
            if (Gear == 1){Linear = ZERO_VECTOR;}

//// Gas Padel
        if (Gas_On == TRUE) {
                if (Fuel < 0.1) Fuel += 0.035*Pedal_Ratio;
                if (Fuel > 0.1 && Fuel < 0.4) Fuel += 0.05*Pedal_Ratio;
                if (Fuel > 0.4 && Fuel < 0.9) Fuel += Pedal_Ratio;
                if (Fuel > 0.9) Fuel += 0.005*Pedal_Ratio;
        }
        if (Gas_On == FALSE){
            if (Brake_On == TRUE){Fuel -= 4*Release_Ratio;}
            else Fuel -= Release_Ratio;
            }
            
        if (Fuel >= 1.0) Fuel = 1.0;
        if (Fuel <= 0) Fuel = 0;
        // Forward Reverse Motion = Current Gear Power * Fuel Flow
        Linear.x = Power*( Fuel + (0.001*llFabs(SpeedVec.x)) );

////Flight Launch Safty
        curPos_B = llGetLocalPos();
    
        if (curPos_time){curPos_time--;}

        if (curPos_time <= 0){
            curPos_A = llGetLocalPos();
            curPos_time = 3;
        }

        if (curPos_B.z > (curPos_A.z+4.5)+(llFabs(SpeedVec.x)*0.015) && FlightSafety == TRUE){
            if ( llFabs(SpeedVec.x) > 10){
                FlightWarning = TRUE;
                VLMO_Z_M = 100;
                llApplyImpulse(llGetMass()*<-0.2,0,-0.2>,FALSE);
                Linear.x = 0;
                Fuel = 0;
                Gas_On = FALSE;
                }
            if ( llFabs(SpeedVec.x) < 10){
                VLMO_Z_M = 1;
                Linear = ZERO_VECTOR;
                Angular = ZERO_VECTOR;
                }
        }

        //Velocity Downforce
        if(llFabs(SpeedVec.x) > 1 && Gear != 1)//Neutural will turn off
        {Linear.z = -DownForce+( -0.001*llFabs(SpeedVec.x) );}
        ///Steering Direction Send
        if(CurDir != LastDir){llMessageLinked(LINK_ALL_CHILDREN, CurDir, "", NULL_KEY);LastDir = CurDir;}
        ///Play Current Sound
        if(CurSound != LastSound){llLoopSound (CurSound, 1.0);LastSound = CurSound;}
        ///Lighting Send
        if(CurLight != LastLight){llMessageLinked(LINK_ALL_CHILDREN, CurLight, "", NULL_KEY);LastLight = CurLight;}

        ///Hud Text
        SetHud();
}//End Timer Event
    
    ////Tied into Flight Launch Safty
    collision (integer total_number){FlightWarning = FALSE;}

    ////When Vehicle Stop Motion (Set None Physical)
    moving_end(){if(llGetRegionName() == SimName){CurDir = DIR_STOP;Moving = 0;llSetStatus(STATUS_PHYSICS, FALSE);}
                else{SimName = llGetRegionName();}}

////AV Entry Point
    state_entry()
    {
        Owner = llGetOwner();
        OwnerName = llKey2Name(Owner);
        Power = llList2Integer(Gear_Power, 0);
        //NumGear_Power = llGetListLength(Gear_Power);
        llSetSitText(SitText);
        llCollisionSound("", 0.0);
        llStopSound();
        llMessageLinked(LINK_ALL_CHILDREN, 0, "SmokeOff", NULL_KEY);
        if(!Active){llSetStatus(STATUS_PHYSICS, FALSE);CurDir = DIR_STOP;llUnSit(llAvatarOnSitTarget());}
        else{SimName = llGetRegionName();CurDir = DIR_STOP;Linear = <0,0,-2>;}
        //Set Current Gear to Netural //Zero Fuel Flow //Set Startup Parameters
        Gear = 1; Current_Gear = "N";Power = 0;START_UP();
    }// End of State of Entry
    
    on_rez(integer param){llResetScript();}
////Avatar Permissions //Owner Only
    changed(integer change){
    if((change & CHANGED_LINK) == CHANGED_LINK){
            sitting = llAvatarOnSitTarget();
            if((sitting != NULL_KEY) && !Active)
                {
                if(Access == "Owner"){
                    if (sitting != llGetOwner()){llWhisper(0, NonOwnerMessage);llUnSit(sitting);}
                    if (sitting == llGetOwner()){
                        llRequestPermissions(Owner, PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
                        GainAccess();
                        }
                    }
                 if (Access == "Public"){
                        llRequestPermissions(sitting, PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA);
                        GainAccess();
                        }
            }
            else if((sitting == NULL_KEY) && Active)
            {
                llStopAnimation(steer_straight);
                Active = 0;
                llStopSound();
                llSetStatus(STATUS_PHYSICS, FALSE);
                llReleaseControls();
                CurLight = LITE_OFF;
                CurDir = SHUT_DW;
                llTriggerSound(ShutdownSound ,1.0);
            }
        }
    }//End of Change State

    run_time_permissions(integer perms)
    {
        if(perms == (PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS | PERMISSION_CONTROL_CAMERA))
        {
            Active = 1;
            llStopAnimation("sit");
            llStartAnimation(steer_straight);
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_DOWN | CONTROL_UP | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT | CONTROL_LBUTTON, TRUE, FALSE);
            Default_Camera();
            CurLight = LITE_BRAKE_L;
            Fuel = 0;
            VLMO_X = 0;
            VLMO_Y = 0;
            Linear.x = 0;
            CurDir = DIR_START;
            llLoopSound(IdleSound, 1.0);
            //check memory
            integer free_memory = llGetFreeMemory();
            llOwnerSay ((string) free_memory + "K of free memory");
        }
    }// End of Run time permission
    
    control(key id, integer levels, integer edges)
    {
        Angular = ZERO_VECTOR;
        integer Pressed = levels & edges;
        integer Down = levels & ~edges;
        integer Released = ~levels & edges;
        integer Inactive = ~levels & ~edges;
        integer Shift = levels;
        integer Unshift = edges;
    
        if(!Moving)
        {
            Moving = 1;
            llSetStatus(STATUS_PHYSICS, TRUE);
        }

///Gear Shift
        if(Pressed & CONTROL_UP){
            if((Gear + 1) != NumGear_Power){++Gear; Power = llList2Float(Gear_Power, Gear); llTriggerSound(Shift_Sound, 1.0);SetGearName();
                if (Fuel > 0.5) llMessageLinked(LINK_ALL_CHILDREN, 0, "Shift_Pop", NULL_KEY);}}
        
        else if(Pressed & CONTROL_DOWN){
            if((Gear - 1) != -1){--Gear;Power = llList2Float(Gear_Power, Gear);llTriggerSound(Shift_Sound, 1.0);SetGearName();
                if (Fuel > 0.5) llMessageLinked(LINK_ALL_CHILDREN, 0, "Shift_Pop", NULL_KEY);}}
///Forward Active
        if(Down & CONTROL_FWD){
            Gas_On = TRUE; Brake_On = FALSE; CurDir = DIR_FWD; CurLight = LITE_OFF;
            llSetStatus(STATUS_PHYSICS, TRUE);if (Gear > 2){VLMO_X = VLMO_X_init+0.001*llFabs(SpeedVec.x);}
///For Reverse Gears
            if (Gear < 1){CurDir = DIR_BACK;CurLight = LITE_REV_L;VLMO_X = 1;VLMO_Y = 0;}
////Gas Sound // RPM Version
            if(Gear >= 2){
            if(Fuel > 0.0 && Fuel < 0.4) CurSound = Low_Sound;
            if(Fuel > 0.4 && Fuel < 0.7) CurSound = Med_Sound;
            if(Fuel > 0.7){
                    if(Gear >= 2 && Gear < 6) CurSound = Med_Sound;
                    if(Gear >= 6 && Gear < 8) CurSound = Max_Sound_G1;
                    if(Gear >= 8) CurSound = Max_Sound_G2;
                }
            }
            if (Gear == 1) CurSound = Rev_Sound; // N
            if (Gear < 1) CurSound = Reverse_Sound; // R
        }

////Forward Inactive
        else if(Released & CONTROL_FWD)
        {
            Gas_On = FALSE;
            CurLight = LITE_GASOFF;
            VLMO_X = VLMO_X_init-0.001*llFabs(SpeedVec.x);
            VLMO_Y = 0;
            CurSound = IdleSound;
        }
            
////Reverse Active
        if(Down & CONTROL_BACK)//&& Released & CONTROL_FWD)
        {
            
            if(Inactive & CONTROL_FWD){
            Gas_On = FALSE;
            Brake_On = TRUE;
            CurLight = LITE_BRAKE_L;
            VLMO_X = VLMO_X_init-0.001*llFabs(SpeedVec.x);
            //VLMO_X = 0;
            VLMO_Y = 0;
            Linear.x = 0;
            }
            
            if(llFabs(SpeedVec.x) > Brake_Speed)
            {
                SKID = TRUE;
                SlipMin();
                BURN = 1;
                CurSound = Skid_Sound;
            }
                
            if(llFabs(SpeedVec.x) < Brake_Speed)
            {
                SKID = FALSE;
                SlipDriftOFF();
                CurSound = IdleSound;
            }

        }

////Reverse Inactive
        else if(Released & CONTROL_BACK)
        {
// llMessageLinked(LINK_ALL_CHILDREN, 0, "SmokeOff", NULL_KEY);
            CurLight = LITE_OFF;
            CurSound = IdleSound;
            Brake_On = FALSE;
            VLMO_X = VLMO_X_init+0.001*llFabs(SpeedVec.x);
        }
        
///// STEERING
/////ZMO Autoworks Steering Equation Based on RL Driving/Racing Experience
        /// dead_zone is to turn steering off at or close to zero
        /// initial_turn is for Low Speed steering
        /// Turn_Peak is for optimal steering speed
        
        //Dead Zone
        if(llFabs(SpeedVec.x)< dead_zone ){turn_direction = 0;}

        //Initial
        if( (llFabs(SpeedVec.x) > dead_zone) && (llFabs(SpeedVec.x)<Initial_Steer) | (llFabs(SpeedVec.x)<-1) ) {
            dynamic_steering = 0.55+( turning*0.005*llFabs(SpeedVec.x) );
            }
        //PEAK
        if( (llFabs(SpeedVec.x) > Initial_Steer) && (llFabs(SpeedVec.x)<= Peak_Steer) ) {
            dynamic_steering = 0.42+( turning*0.005*llFabs(SpeedVec.x) );
            }
        
        //MAXIMUM
        if( llFabs(SpeedVec.x) > Peak_Steer) {
            dynamic_steering = turning*( Max_Response/llFabs(SpeedVec.x) );
            }
        
        //Driver Response Simulation
        if( llFabs(SpeedVec.x) > 0 ) {turning = STR_Response+( llFabs(SpeedVec.x)*0.03*STR_Response );}

        float SLIP_M = 1.0;
        float angular_EQ_z = turn_direction*PI*dynamic_steering;
        float angular_EQ_Burn = turn_direction*PI*SLIP_M*dynamic_steering;
        float Offest_EQ_Y = 0.001*llFabs(SpeedVec.y);

        ////Set Steering Driection
        if (SpeedVec.x > 0) {turn_direction = 1;}
        if (SpeedVec.x == 0) {turn_direction = 0;}
        if (SpeedVec.x < 0) {turn_direction = -1;}

            
       if(Down & (CONTROL_RIGHT|CONTROL_ROT_RIGHT)){
            if (BURN == 0 | BURN == 1) Angular.z -= angular_EQ_z;
        
            if (BURN == 2) {
                Angular.z -= angular_EQ_Burn;
                llRotLookAt(llGetLocalRot()*llEuler2Rot(<0,0, -19*turn_direction> * DEG_TO_RAD), 0.1, 3);
                }
            Angular.x = -BankAngle+(-0.05*llFabs(SpeedVec.y));
            
            if (llFabs(SpeedVec.x) > 1){VLMO_Y = -Offest_EQ_Y;}
            CurDir = DIR_RIGHT;
            ///Animation
            StopLeftRight();
            llStartAnimation(steer_right);
        }
        if(Down & (CONTROL_LEFT|CONTROL_ROT_LEFT)){
            if (BURN == 0 | BURN == 1) Angular.z += angular_EQ_z;
            if (BURN == 2) {
                Angular.z += angular_EQ_Burn;
                llRotLookAt(llGetLocalRot()*llEuler2Rot(<0,0, 19*turn_direction> * DEG_TO_RAD), 0.1, 3);
                }
            Angular.x = BankAngle+(0.05*llFabs(SpeedVec.y));
            
            if (llFabs(SpeedVec.x) > 1){VLMO_Y = Offest_EQ_Y;}
            CurDir = DIR_LEFT;
            ///Animation
            StopLeftRight();
            llStartAnimation(steer_left);
        }

        if ( Released & (CONTROL_LEFT|CONTROL_ROT_LEFT) | Released & (CONTROL_RIGHT|CONTROL_ROT_RIGHT) ){
            VLMO_X = 0;
            VLMO_Y = 0;
            SLIP_M = 1.0;
            CurDir = DIR_RELEASE;
            Angular.x = 0;
            llRotLookAt(llEuler2Rot(ZERO_VECTOR), 0, 0);
        if (llFabs(SpeedVec.x) < 15*Brake_Speed | Fuel < Slip_Fuel_CutOff) {SlipDriftOFF();} //llFabs(SpeedVec.x) < 9*Brake_Speed |
            ///Animation
            StopLeftRight();
        }
            
        if( llFabs(SpeedVec.x) > 0.5 && Gear != 1 && Shift & CONTROL_RIGHT | Shift & CONTROL_LEFT ){
            //Fuel = 1.5;
            BURN = 2;
            SKID = TRUE;
            SLIP_M = Burn_Boost*60;
            CurSound = Burn_Sound;
            Burnout();
        }

//Forward & Backward Key Burnout

         if(Gear != 1 && Down&CONTROL_FWD){
                
            if (Down&CONTROL_BACK){
                BURN = 2;
                SKID = TRUE;
                CurSound = Burn_Sound;
                Burnout2();
            }

            if (Released&CONTROL_BACK){
                Fuel = 1;
                Burn2OFF();
            }
        }

if (ActiveRally == TRUE && llFabs(Angular.x) > ActiveRallyAngle){BURN = 2;SKID = TRUE;SLIP_M = Burn_Boost*60;SlipMin();}

if (Pressed & CONTROL_LBUTTON){Recover(); Crash_Logic = FALSE;}

}//End Control

link_message(integer sender, integer num, string message, key id)
{
if(message == "Crash" && Crash_Logic == FALSE && Crash_Active == TRUE){Crash(); Crash_Logic = TRUE;}

        if(message == "CrashActive") {Crash_Active = TRUE; llSetText("Crash is Active\n\n\n",<1,0,0>,1); llSleep(1.0); SetHud();}

        if(message == "CrashNotActive") {Crash_Active = FALSE; Crash_Logic = FALSE; llMessageLinked(LINK_SET, 0, "CrashReset", NULL_KEY);
llSetText("Crash is Off\n\n\n",<1,0,0>,1); llSleep(1.0); SetHud();}

        if(message == "ActiveRallyON") {ActiveRally = TRUE; llSetText("ActiveRally ON",<0,1,0>,1); llSleep(1.0); SetHud();}

        if(message == "ActiveRallyOFF") {ActiveRally = FALSE; llSetText("ActiveRally OFF",<0,1,0>,1); llSleep(1.0); SetHud();}

        if(message == "Owner") {Access="Owner"; llSetText("Owner\n\n\n",<1,1,0>,1);llSleep(1.0);SetHud();}

        if(message == "Public") {Access="Public"; llSetText("Public\n\n\n",<1,1,0>,1);llSleep(1.0);SetHud();}
}
}//End default

// Additional Info ////////////////////////////////////////////////////
//////Sculpts, Textures, Animations, Sounds///////////////////////////
// Add your info
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// This script is a "Gas and Brakes" Operation vehicle.
// That means when you press the "S" key or "Down Arrow" key the car will Brake.
// You have to shift to go Reverse via "C" key or "PageDown" key
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// Copyright (C) 2012 & Beyond by All Intelligence in the Universe.
//////////////////////////////////////////////////////////////////////

// NOTE: /////////////////////////////////////////////////////////////
//
// Any script without this GNU title might not be free. Use at your own risk.
//
// Once in a while Math Error will show up with certain key combination.
// Once you are in the vehicle, Press the Forward key, the error will disappear.
// Have a feeling it's in the VEHICLE_LINEAR_MOTOR_TIMESCALE.
// Hopefully that will be resolved in the future versions.
//
//////////////////////////////////////////////////////////////////////