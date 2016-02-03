//=============================================================================
// PlayerInput
// Object within playercontroller that manages player input.
// only spawned on client
//=============================================================================

class PlayerInput extends Object within PlayerController
	config(User)
	native
	transient;

var globalconfig	bool	bInvertMouse;

var bool		bWasForward;	// used for doubleclick move 
var bool		bWasBack;
var bool		bWasLeft;
var bool		bWasRight;
var bool		bEdgeForward;
var bool		bEdgeBack;
var bool		bEdgeLeft;
var bool 		bEdgeRight;
var	bool		bAdjustSampling;
var bool        bDodgeHack;

// Mouse smoothing
var globalconfig byte   MouseSmoothingMode;
var globalconfig float  MouseSmoothingStrength;
var globalconfig float	MouseSensitivityX;
var globalconfig float	MouseSensitivityY;
var globalconfig float  MouseSamplingTime;
var float SmoothedMouse[2], ZeroTime[2], SamplingTime[2], MaybeTime[2], OldSamples[4];
var int MouseSamples[2];

var	float DoubleClickTimer; // max double click interval for double click move
var globalconfig float	DoubleClickTime;
var bool bEnableDodging; // gam


var float FilterMouseInput; //cmr for minied hurrrr

//=============================================================================
// Input related functions.

function bool InvertLook()
{
    bInvertMouse = !bInvertMouse;
    return bInvertMouse;
}

function bool GetInvertLook()
{
    return(bInvertMouse);
}

function SetInvertLook(bool invert)
{
    bInvertMouse = invert;
}

simulated function float GetSensitivityX()
{
    return(MouseSensitivityX);
}

simulated function float GetSensitivityY()
{
    return(MouseSensitivityY);
}

simulated function SetSensitivityX( float Sensitivity )
{
    MouseSensitivityX = FMax( 0.f, Sensitivity );
    default.MouseSensitivityX = MouseSensitivityX; 
	SaveConfig();
}

simulated function SetSensitivityY( float Sensitivity )
{
    MouseSensitivityY = FMax( 0.f, Sensitivity );
    default.MouseSensitivityY = MouseSensitivityY; 
	SaveConfig();
}

// Postprocess the player's input.
event PlayerInput( float DeltaTime )
{
	local float FOVScale;

	// Ignore input if we're playing back a client-side demo.
	if( Outer.bDemoOwner && !Outer.default.bDemoOwner )
		return;
				
	// Check for Double click move
	// flag transitions
	bEdgeForward = (bWasForward ^^ (aBaseY > 0));
	bEdgeBack = (bWasBack ^^ (aBaseY < 0));
	bEdgeLeft = (bWasLeft ^^ (aStrafe < 0));
	bEdgeRight = (bWasRight ^^ (aStrafe > 0));
	bWasForward = (aBaseY > 0);
	bWasBack = (aBaseY < 0);
	bWasLeft = (aStrafe < 0);
	bWasRight = (aStrafe > 0);

	// Smooth and amplify mouse movement
	FOVScale = FOVAngle * 0.01111; // 0.01111 = 1/90
	aMouseX = FilterMouseInput*SmoothMouse(aMouseX * MouseSensitivityX * FOVScale, DeltaTime,bXAxis,0);
	aMouseY = FilterMouseInput*SmoothMouse(aMouseY * MouseSensitivityY * FOVScale, DeltaTime,bYAxis,1);

	// adjust keyboard and joystick movements
	aLookUp *= FOVScale;
	aTurn   *= FOVScale;

	// Remap raw x-axis movement.
	if( bStrafe!=0 ) // strafe
		aStrafe += aBaseX + aMouseX;
	else // forward
		aTurn  += aBaseX * FOVScale + aMouseX;
	aBaseX = 0;

	// Remap mouse y-axis movement.
	if( (bStrafe == 0) && (bAlwaysMouseLook || (bLook!=0)) )
	{
		// Look up/down.
		if ( bInvertMouse )
			aLookUp -= aMouseY;
		else
			aLookUp += aMouseY;
	}
	else // Move forward/backward.
		aForward += aMouseY;

	if ( bSnapLevel != 0 )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}
	else if (aLookUp != 0)
	{
		bCenterView = false;
		bKeyboardLook = true;
	}
	else if ( bSnapToLevel && !bAlwaysMouseLook )
	{
		bCenterView = true;
		bKeyboardLook = false;
	}

	// Remap other y-axis movement.
	if ( bFreeLook != 0 )
	{
		bKeyboardLook = true;
		aLookUp += 0.5 * aBaseY * FOVScale;
	}
	else
		aForward += aBaseY;
	aBaseY = 0;

	// Handle walking.
	HandleWalking();
}

exec function SetSmoothingMode(byte B)
{
	MouseSmoothingMode = B;
	log("Smoothing mode "$MouseSmoothingMode);
}

exec function SetSmoothingStrength(float F)
{
	MouseSmoothingStrength = FClamp(F,0,1);
}

function float SmoothMouse(float aMouse, float DeltaTime, out byte SampleCount, int Index)
{
	local int i, sum;

	if ( MouseSmoothingMode == 0 )
		return aMouse;

	if ( aMouse == 0 )
{
		ZeroTime[Index] += DeltaTime;
		if ( ZeroTime[Index] < MouseSamplingTime )
	{
			SamplingTime[Index] += DeltaTime; 
			MaybeTime[Index] += DeltaTime;
			aMouse = SmoothedMouse[Index];
	}
	else
	{
			if ( bAdjustSampling && (MouseSamples[Index] > 9) )
		{
				SamplingTime[Index] -= MaybeTime[Index];
				MouseSamplingTime = 0.9 * MouseSamplingTime + 0.1 * SamplingTime[Index]/MouseSamples[Index];
			}
			SamplingTime[Index] = 0;
			SmoothedMouse[Index] = 0;
			MouseSamples[Index] = 0;
		}
		}
		else
		{
		MaybeTime[Index] = 0;

		if ( SmoothedMouse[Index] != 0 )
			{
			MouseSamples[Index] += SampleCount;
			if ( DeltaTime > MouseSamplingTime * (SampleCount + 1) )
				SamplingTime[Index] += MouseSamplingTime * SampleCount; 
				else
			{
				SamplingTime[Index] += DeltaTime; 
				aMouse = aMouse * DeltaTime/(MouseSamplingTime * SampleCount);
			} 
		}
		else
			SamplingTime[Index] = 0.5 * MouseSamplingTime;

		SmoothedMouse[Index] = aMouse/SampleCount;
		ZeroTime[Index] = 0;
	}
	SampleCount = 0;

	if ( MouseSmoothingMode > 1 )
	{
		if ( aMouse == 0 )
		{
			// stop in next tick
			for ( i=0; i<3; i++ )
			{
				sum += (i+1) * 0.1;
				aMouse += sum * OldSamples[i];
				OldSamples[i] = 0;
			}
			OldSamples[3] = 0;
		}
		else
		{
			aMouse = 0.4 * aMouse;
			OldSamples[3] = aMouse;
			for ( i=0; i<3; i++ )
			{
				aMouse += (i+1) * 0.1 * OldSamples[i];
				OldSamples[i] = OldSamples[i+1];
			}

		}
	}
	return aMouse;
}

// gam ---
function UpdateSmoothing( int Mode )
{
    MouseSmoothingMode = Mode;
    default.MouseSmoothingMode = MouseSmoothingMode;
	SaveConfig();
} 
// --- gam

function ChangeSnapView( bool B )
{
	bSnapToLevel = B;
}

// check for double click move
function Actor.eDoubleClickDir CheckForDoubleClickMove(float DeltaTime)
{
	local Actor.eDoubleClickDir DoubleClickMove, OldDoubleClick;

    if (!bEnableDodging)
    {
        DoubleClickMove = DCLICK_None;
        return DoubleClickMove;
    }

    if ( DoubleClickDir == DCLICK_Active )
		DoubleClickMove = DCLICK_Active;
	else
		DoubleClickMove = DCLICK_None;
	if (DoubleClickTime > 0.0)
	{
		if ( DoubleClickDir < DCLICK_Active )
		{
			OldDoubleClick = DoubleClickDir;
			DoubleClickDir = DCLICK_None;

			if (bEdgeForward && bWasForward)
				DoubleClickDir = DCLICK_Forward;
			else if (bEdgeBack && bWasBack)
				DoubleClickDir = DCLICK_Back;
			else if (bEdgeLeft && bWasLeft)
				DoubleClickDir = DCLICK_Left;
			else if (bEdgeRight && bWasRight)
				DoubleClickDir = DCLICK_Right;

			if ( DoubleClickDir == DCLICK_None)
				DoubleClickDir = OldDoubleClick;
			else if ( DoubleClickDir != OldDoubleClick )
				DoubleClickTimer = DoubleClickTime + 0.5 * DeltaTime;
            else
				DoubleClickMove = DoubleClickDir;
			/*else if ( bDodgeHack )
            {
				DoubleClickMove = DoubleClickDir;
                bDodgeHack = false;
            }*/
		}

		if (DoubleClickDir == DCLICK_Done)
		{
			DoubleClickTimer -= DeltaTime;
			if (DoubleClickTimer < -0.35) 
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
			}
		}		
		else if ((DoubleClickDir != DCLICK_None) && (DoubleClickDir != DCLICK_Active))
		{
			DoubleClickTimer -= DeltaTime;			
			if (DoubleClickTimer < 0)
			{
				DoubleClickDir = DCLICK_None;
				DoubleClickTimer = DoubleClickTime;
			}
		}
	}
	return DoubleClickMove;
}

function Dodge()
{
    if (Pawn == None)
        return;

    if (DoubleClickTimer >= DoubleClickTime)
    {
        Jump();
    }
    else if (bWasForward)
    {
        bWasForward = false;
        bDodgeHack = true;
    }
    else if (bWasBack)
    {
        bWasBack = false;
        bDodgeHack = true;
    }
    else if (bWasRight)
    {
        bWasRight = false;
        bDodgeHack = true;
    }
    else if (bWasLeft)
    {
        bWasLeft = false;
        bDodgeHack = true;
    }
    else
    {
        Jump();
    }
}

defaultproperties
{
     MouseSmoothingStrength=0.300000
     MouseSensitivityX=1.000000
     MouseSensitivityY=1.000000
     MouseSamplingTime=0.012116
     DoubleClickTime=0.250000
     FilterMouseInput=1.000000
     bAdjustSampling=True
}
