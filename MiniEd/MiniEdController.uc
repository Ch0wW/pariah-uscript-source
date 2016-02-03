class MiniEdController extends PlayerController
    config(MiniEdUser)
    native
    exportstructs;

const MinHeight = 1000.0;
const CAMERA_PITCH = -8192;
const MAX_ROT_VELOCITY = 1250;
const MAX_ROT_LOCKEDON_VELOCITY = 1000;
const ROT_DRAG_COEFF = 350;
const ROT_LOCKEDON_DRAG_COEFF = 300;
const MOUSE_WHEEL_ZOOM_POWER = 250000;
const MOUSE_WHEEL_ZOOM_TIME = 0.3;
const MOUSE_WHEEL_ZOOM_MAX_SPEED = 10000;

var input byte bPressedA;
var input byte bPressedB;
var input byte bPressedX;
var input byte bPressedY;
var input byte bPressedLT;
var input byte bPressedRT;

var float RotSpeedFactor;
var float SlowdownFactor;	//Factor that determines how fast the camera slows down when the user lets go of a movement control

var vector	LookAtLocation;
var vector	SelectedMeshLocation;
var vector	SavedFront;
var vector	SavedRight;
var float	SavedHeight;
var float	CircleRadius;
var rotator AboutAxisRot;
var bool	bTurning;
var bool	bMovingAround;
var bool	IsAMenuUp;
var float	DistAboveGround;
var int		RotationalVelocity;

var() float CameraSpeed; // this should be config!

var() float MinAirSpeed;
var() float MaxAirSpeed;
var() float MinRotSpeed;
var() float MaxRotSpeed;
var bool bMouseControlledCamRot;

//Mouse wheeling for zooming
var int MouseScroll;
var int MouseWheel;
var int ZoomDir; //-1 back, 0 none, 1 front
var bool bWasWheeling;
var float AccelFromMouseWheelTimer;

const Scroll_Right = 1;
const Scroll_Top = 2;
const Scroll_Left = 4;
const Scroll_Bottom = 8;

function Possess( Pawn aPawn )
{
    SetRotation(aPawn.Rotation);
    aPawn.PossessedBy(self);
    Pawn = aPawn;
    Pawn.bStasis = false;
    SetCameraSpeed(CameraSpeed);
    Restart();
}


function Restart()
{
    ServerTimeStamp = 0;
    TimeMargin = 0;
    GotoState('Waiting');
    SetViewTarget(Pawn);
    ResetView();
    ClientRestart();
}


function ClientRestart()
{
    if ( Pawn == None )
    {
        GotoState('WaitingForPawn');
        return;
    }
    Pawn.ClientRestart();
    SetViewTarget(Pawn);
    ResetView();
    BeginState();
}

function EnterStartState()
{
}


state Waiting
{
ignores SeePlayer, HearNoise;

	function BeginState()
	{
	}
}


simulated event PlacementShake( vector shRotMag,    vector shRotRate,    float shRotTime, 
							    vector shOffsetMag, vector shOffsetRate, float shOffsetTime )
{
	ShakeView( shRotMag, shRotRate, shRotTime, shOffsetMag, shOffsetRate, shOffsetTime );
}


simulated event SetMenuUp( bool b )
{
	IsAMenuUp = b;
	if( b )
	{
		Pawn.Acceleration = vect(0,0,0);
		Pawn.Velocity = vect(0,0,0);
	}
}	


state FreeCamera
{
ignores SeePlayer, HearNoise;

    function PlayerMove(float DeltaTime)
    {
		if( IsAMenuUp )
			return;

		UpdateCameraLocation( DeltaTime );
		UpdateRotation( DeltaTime, 0 );
		UpdateMovementFlags();

		if ( VSize(Pawn.Acceleration) < 1.0 )
			Pawn.Acceleration = vect(0,0,0);
		if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
			Pawn.Velocity = vect(0,0,0);
	}
	
    function BeginState()
    {
    }
}


state RotateAround
{
ignores SeePlayer, HearNoise;

    function PlayerMove(float DeltaTime)
    {
		if( IsAMenuUp )
			return;
			
		UpdateLockedOnRotation( DeltaTime );
		UpdateLockedCameraLocation( DeltaTime );
		UpdateMovementFlags();
		
		if ( VSize(Pawn.Acceleration) < 1.0 )
            Pawn.Acceleration = vect(0,0,0);
        if ( bCheatFlying && (Pawn.Acceleration == vect(0,0,0)) )
            Pawn.Velocity = vect(0,0,0);
    }
    
    // Save the front and right vectors
    function BeginState()
    {
		local vector up;
		local vector DistFromSelected;
		
		GetAxes( Rotation, SavedFront, SavedRight, up );
		
		SavedHeight = Location.Z;
		SavedFront.Z = 0; //take out the pitch from the front vector
		SavedRight.Z = 0; //take out the pitch from the right vector
		
		SavedFront = Normal(SavedFront);
		SavedRight = Normal(SavedRight);
		
		DistFromSelected = SelectedMeshLocation - Location;
		
		DistFromSelected.Z = 0;
		CircleRadius = VSize(DistFromSelected);
    }
    
    // Reset the saved front and right vectors
    function EndState()
    {
		SavedFront.X = 0;
		SavedFront.Y = 0;
		SavedFront.Z = 0;
		SavedRight.X = 0;
		SavedRight.Y = 0;
		SavedRight.Z = 0;
		SavedHeight = 0;
		AboutAxisRot.Yaw = 0;
    }
}


simulated function UpdateMovementFlags()
{
	if( aForward != 0 || aStrafe != 0 || aBaseZ != 0 )
		bMovingAround = true;
	else
		bMovingAround = false;

	if( aTurn != 0 )
		bTurning = true;
	else
		bTurning = false;
}


simulated function UpdateCameraLocation( float DeltaTime )
{
	local vector X,Y,Z;
	local rotator T;
	local vector front, up;		
	local float AccelerationReduction;
	local float Forward, Strafe;
	
	if( !MiniEdPawn(Pawn).bRebounding && !MiniEdPawn(Pawn).bAutoRaising )
	{
		GetAxes(Rotation,X,Y,Z);
		
		//Compute forward direction
		front.X = 1; // X is into the screen
		T.Yaw = Rotation.Yaw;
		front = front >> T;

		//Set the upwards direction
		up.Z = 1;

		//Acceleration reduces the closer we are to the terrain
		AccelerationReduction = (Pawn.Location.Z - LookAtLocation.Z) / 10000.0;

		Forward = aForward;
		if(Forward == 0.0)
		{
			if((MouseScroll & Scroll_Top) != 0)
				Forward = 24000.0;
			else if((MouseScroll & Scroll_Bottom) != 0)
				Forward = -24000.0;
		}

		Strafe = aStrafe;
		if(Strafe == 0.0)
		{
			if((MouseScroll & Scroll_Right) != 0)
				Strafe = 24000.0;
			else if((MouseScroll & Scroll_Left) != 0)
				Strafe = -24000.0;
		}


		//Set forward and side acceleration
        //note: don't cam to move around while the mouse wheel zoom is used, since we change the
        //      its speed
        if( AccelFromMouseWheelTimer == 0 )
        {
		    Pawn.Acceleration = AccelerationReduction * Forward * front + AccelerationReduction * Strafe * Y;
        }

		//Set vertical acceleration
		//Note: We move the camera along the front camera axis (ksue)
		//Warning: The pitch is -45 deg so the acceleration along X and Z is the same
		aBaseZ = -aBaseZ;

        if( aBaseZ == 0 )
        {
            if( MouseWheel == 0 )
            {
                if( bWasWheeling )
                    bWasWheeling = false;
            }
            else
            {

                AccelFromMouseWheelTimer = MOUSE_WHEEL_ZOOM_TIME;
                Pawn.AirSpeed = MOUSE_WHEEL_ZOOM_MAX_SPEED;
                bWasWheeling = true;
                if( MouseWheel > 0 )
                    ZoomDir = 1;
                else
                    ZoomDir = -1;
            }
        }
        else
        {
    		if( aBaseZ > 0 || (aBaseZ < 0 && DistAboveGround > MinHeight ) )
                Pawn.Acceleration += AccelerationReduction * aBaseZ * ( up - front );
        }
	}

    MouseWheel = 0;

    if( AccelFromMouseWheelTimer > 0 )
    {
        AccelFromMouseWheelTimer -= DeltaTime;
        if( AccelFromMouseWheelTimer <= 0 )
        {
            AccelFromMouseWheelTimer = 0;
            ZoomDir = 0;
            SetCameraSpeed( CameraSpeed );
        }

        Pawn.Acceleration = MOUSE_WHEEL_ZOOM_POWER * ZoomDir * ( front - up);
    }


	//Set the controller's location
	SetLocation( Pawn.Location );
}


simulated function UpdateLockedCameraLocation( float DeltaTime )
{
	local float theta;
	local vector NewLocation;
	
	theta = (AboutAxisRot.Yaw - 16384)*(PI/32768); //Start at -90 degrees on the circle since the camera is right behind the mesh
	
	NewLocation = SelectedMeshLocation + cos( theta ) * CircleRadius * SavedRight + sin( theta ) * CircleRadius * SavedFront;
	NewLocation.Z = SavedHeight;
	
	//Set the location of the pawn
	Pawn.Move( NewLocation - Location );
	
	//Fix the viewport to the pawn
	SetLocation( Pawn.Location );	
}


function UpdateRotation( float DeltaTime, float maxPitch )
{
	local rotator R, ViewRotation;

	// Tilt the view
    R = Rotation;
    R.Pitch = CAMERA_PITCH;
    SetRotation( R );
    
	ViewRotation = Rotation;
	DesiredRotation	= ViewRotation;	//save old rotation


    //Remove rotation contribution from mouse if the cam is not currently
    //under mouse control (when holding right mouse button down). Not pretty but,
    //but better than splitting PlayerInput to make a MiniEdInput (xmatt)
//    if( !bMouseControlledCamRot && bStrafe == 0 && aMouseX != 0 )
//    {
//		aTurn  -= aBaseX * FOVAngle * 0.01111 + aMouseX;
//    }

	if( aTurn != 0 )
	{        
		// if you want to change directions, your acceleration should be higher
		if ( RotationalVelocity * aTurn < 0.0 )
		{
			RotationalVelocity = 0;
		}
		else
			RotationalVelocity += aTurn * 0.25;

		if (RotationalVelocity > MAX_ROT_VELOCITY)
			RotationalVelocity = MAX_ROT_VELOCITY;
		else if (RotationalVelocity < -MAX_ROT_VELOCITY)
			RotationalVelocity = -MAX_ROT_VELOCITY;	
	}
	//When the rotational velocity is small enough make it stop
	else if (abs(RotationalVelocity) < 80)	
		RotationalVelocity = 0;
	//Simulate drag
	else if( RotationalVelocity > 0 )
	{
		RotationalVelocity -= ROT_DRAG_COEFF;
		if (RotationalVelocity < 0) RotationalVelocity = 0;
	}
	else if( RotationalVelocity < 0 )
	{
		RotationalVelocity += ROT_DRAG_COEFF;
		if (RotationalVelocity > 0) RotationalVelocity = 0;
	}
		
	ViewRotation.Yaw +=	32.0 * DeltaTime * RotSpeedFactor * RotationalVelocity;
	ViewShake(DeltaTime);

	//Set the rotation of the controller
	SetRotation( ViewRotation );
	
	//Set the rotation of the pawn
	Pawn.SetRotation( ViewRotation );
}


function UpdateLockedOnRotation( float DeltaTime )
{
	local rotator ViewRotation;
	local rotator NewRotation;
	local float DeltaYaw;

	ViewRotation = Rotation;
	DesiredRotation	= ViewRotation;	//save old rotation

    if( aTurn != 0 )
    {
        // if you want to change directions, your acceleration should be higher
		if ( RotationalVelocity * aTurn < 0.0 )
			RotationalVelocity += aTurn * 0.12;
		else
			RotationalVelocity += aTurn * 0.25;
		
		if (RotationalVelocity > MAX_ROT_LOCKEDON_VELOCITY)
			RotationalVelocity = MAX_ROT_LOCKEDON_VELOCITY;
		else if (RotationalVelocity < -MAX_ROT_LOCKEDON_VELOCITY)
			RotationalVelocity = -MAX_ROT_LOCKEDON_VELOCITY;	
	}
	
	//When the rotational velocity is small enough make it stop
	else if (abs(RotationalVelocity) < 50)	
		RotationalVelocity = 0;
	//Simulate drag
	else if( RotationalVelocity > 0 )
	{
		RotationalVelocity -= ROT_LOCKEDON_DRAG_COEFF;
		if (RotationalVelocity < 0) RotationalVelocity = 0;
	}
	else if( RotationalVelocity < 0 )
	{
		RotationalVelocity += ROT_LOCKEDON_DRAG_COEFF;
		if (RotationalVelocity > 0) RotationalVelocity = 0;
	}
		
	DeltaYaw -=	32.0 * DeltaTime * RotSpeedFactor * RotationalVelocity;

	//Update the total yaw angle of the camera
	ViewRotation.Yaw -=	DeltaYaw;
	
	//Update the total yaw angle since the mesh was selected
	AboutAxisRot.Yaw +=	DeltaYaw;

	ViewShake(DeltaTime);
	
	//Set the rotation of the controller
	SetRotation(ViewRotation);
	
	//Set the rotation of the pawn
	if( Pawn != None )
	{
		Pawn.FaceRotation(NewRotation, deltatime);
	}
}

// To change the MiniEd camera movement speed (SpeedPercent = [0.f, 1.f])
simulated function SetCameraSpeed( float Speed )
{
    Speed = FClamp(Speed, 0.f, 1.f);
    CameraSpeed = Speed;

	Pawn.AirSpeed = Lerp( CameraSpeed, MinAirSpeed, MaxAirSpeed );
	RotSpeedFactor = Lerp( CameraSpeed, MinRotSpeed, MaxRotSpeed );

	SlowdownFactor = 6.0;
}

simulated function float GetCameraSpeed()
{
    return(CameraSpeed);
}

simulated event SetupCamera()
{
    Pawn.SetPhysics( PHYS_Manual );
}


state TerrainEdit
{
ignores SeePlayer, HearNoise;

    function PlayerMove(float DeltaTime)
    {
		// Freeze the camera		
        Pawn.Acceleration = vect(0,0,0);
        Pawn.Velocity = vect(0,0,0);
    }
    
    function BeginState()
    {
    }
}


event PostBeginPlay()
{
    Super.PostBeginPlay();


    SpawnDefaultHUD();
    if (Level.LevelEnterText != "" )
        ClientMessage(Level.LevelEnterText);

    DesiredFOV = DefaultFOV;
    SetViewTarget(self);  // MUST have a view target!
}

event InitInputSystem() // if client, ensure player mem limit will allow me locally
{
	Super.InitInputSystem();

	if(PlayerInput != None)
	{
		PlayerInput.FilterMouseInput = 0.0;
	}

}

simulated event UpdatePlayer(string newName, string newChar)
{
    if (GetCurrentGameProfile() != None)
        return;

    ChangeName(newName);
    SetPawnClass(string(PawnClass), newChar);
}


function SetPawnClass(string inClass, string inCharacter, optional string DefaultClass)
{	
	local class<xPawn> pClass;
	pClass = class<xPawn>(DynamicLoadObject(inClass, class'Class'));
	assert(pClass != None);
	PawnClass = pClass;
}


function SpawnDefaultHUD()
{
    local class<HUD> HudClass;

    if ( myHUD != None )
        myHUD.Destroy();

    //HudClass = class<HUD>(DynamicLoadObject( "XInterface.HudBase", class'Class'));
    HudClass = class<HUD>(DynamicLoadObject( "MiniEd.MiniEdHud", class'Class'));
    assert( HudClass != None );
    myHUD = Spawn(HudClass,self);
    assert( myHUD != None );
}

//msp_todo: take out "ServerStopForceFeedback()"
event PreClientTravel()
{
	//ConsoleCommand( "FULLSCREENVIEWPORT 0" );
    //ServerStopForceFeedback();  // jdf
}

defaultproperties
{
     CameraSpeed=0.500000
     MinAirSpeed=1000.000000
     MaxAirSpeed=6000.000000
     MinRotSpeed=0.050000
     MaxRotSpeed=1.000000
     TeamBeaconMaxDist=10000.000000
     bNoVoiceTaunts=False
     bNoAutoTaunts=False
     bEnableGUIForceFeedback=False
}
