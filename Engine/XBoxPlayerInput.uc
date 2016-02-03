class XBoxPlayerInput extends PlayerInput
	config(User)
	transient;

const InputMax = 32768;
const RunThresh = 16384;
const DodgeThresh = 10000;

var() config float  HScale;
var() config float  HExponent;
var() config float  HLookRateMax;
var() config float  VScale;
var() config float  VExponent;
var() config float  VLookRateMax;
var() config bool   bInvertVLook;
var() config bool   bLookSpring;
var() float         HLook;
var() float         VLook;

const SENSITIVITY_SCALE = 100.f;

struct LookPreset
{
    var() localized string  PresetName;
    var() float             HScale;
    var() float             HExponent;
    var() float             VScale;
    var() float             VExponent;
};

const NumPresets=4;
var() config LookPreset     LookPresets[NumPresets];
var() config string         SelectedPresetName;
 
var() float                 VelScale;
var() float                 AccelScale;
var() float                 DampeningFactor;
var() float                 MinAccelComponent;

const MaxFilterEntries=4;
var() float                 ForwardFilter[MaxFilterEntries];
var() float                 StrafeFilter[MaxFilterEntries];

var	float					LastABaseX;
var() config float			LookRateX;
var() config float			InsideRateX;

var	float					LastABaseY;
var() config float			LookRateY;
var() config float			InsideRateY;

/*
accelRate 
*/
function float accelInput( float in, float lastIn, float ratemax, float accelRate, float dt)
{
	local float out;
	
	if( lastIn <= 0 && in > 0)
	{
		HLook = InsideRateX;
	}
	else if( lastIn >= 0 && in < 0)
	{
		HLook = -1 * InsideRateX;
	}
	else if (in == 0)
	{
		HLook = 0;
		return HLook;
	}
	
	in /= InputMax;
	

	if( abs(in) < 0.72)
	{
		if( in >= 0)
			return InsideRateX * (1 + sin( Lerp( in/0.72, 0.0, 1.571 ) - 1.571));
		else
			return -1 * InsideRateX * (1 + sin( Lerp( in/0.72, 0.0, 1.571 ) - 1.571));
	}

	//x = x0 + v0*t
	out = HLook + (in * accelRate) * dt;
	
	if(out < 0)
		return Max(out, -1 * rateMax);

	return Min(out, rateMax);

}

/*
accelRate 
*/
function float accelInputY( float in, float lastIn, float ratemax, float accelRate, float dt)
{
	local float out;
	
	if( lastIn <= 0 && in > 0)
	{
		VLook = InsideRateY;
	}
	else if( lastIn >= 0 && in < 0)
	{
		VLook = -1 * InsideRateY;
	}
	else if (in == 0)
	{
		VLook = 0;
		return VLook;
	}
	
	in /= InputMax;
	

	if( abs(in) < 0.72)
	{
		if( in >= 0)
			return InsideRateY * (1 + sin( Lerp( in/0.72, 0.0, 1.571 ) - 1.571));
		else
			return -1 * InsideRateY * (1 + sin( Lerp( in/0.72, 0.0, 1.571 ) - 1.571));
	}

	//x = x0 + v0*t
	out = VLook + (in * accelRate) * dt;
	
	if(out < 0)
		return Max(out, -1 * rateMax);

	return Min(out, rateMax);

}

// Postprocess the player's input.
function PlayerInput( float DeltaTime )
{
    local float FOVScale;

    if (bSnapLevel != 0)
        bCenterView = true;
    else if (aBaseZ != 0)
        bCenterView = false;

    if (bInvertVLook)
        aBaseZ *= -1.f;

    FOVScale = FOVAngle / DefaultFOV; //should be 1/defaultFOV

    // Remap the turn inputs to an exponential curve
	//HLook = Remap(aBaseX, HScale, HExponent, HLookRateMax);

	//mh ---
	HLook = accelInput( aBaseX, LastABaseX, HLookRateMax, LookRateX, DeltaTime);
	LastABaseX = aBaseX;
	//if(aBaseX != 0)
	//{
	//	log("MIKEH:  HLook:" @ HLook @ "aBaseX" @ aBaseX @ "HLookRateMax" @HLookRateMax@ "Accel" @ LookRate);
	//}
	// --- mh

    if (bSnapToLevel)
        VLook += (aBaseZ*0.45 - VLook) * DeltaTime * (VLookRateMax/500.0*FOVScale);
    else
	{
		//VLook = Remap(aBaseZ, VScale, VExponent, VLookRateMax) * FOVScale;
		VLook = accelInputY( aBaseZ, LastABaseY, VLookRateMax, LookRateY, DeltaTime);
		LastABaseY = aBaseZ;
	}

	// Check for Double click move
	// flag transitions
    if (Abs(aStrafe) > InputMax || Abs(aBaseY) > InputMax) // d-pad inputs are always 2 x inputmax
    {
	    bEdgeForward    = (bWasForward  ^^ (aBaseY  > DodgeThresh));
	    bEdgeBack       = (bWasBack     ^^ (aBaseY  < -DodgeThresh));
	    bEdgeRight      = (bWasRight    ^^ (aStrafe > DodgeThresh));
	    bEdgeLeft       = (bWasLeft     ^^ (aStrafe < -DodgeThresh));
	    bWasForward     = (aBaseY  > DodgeThresh);
	    bWasBack        = (aBaseY  < -DodgeThresh);
	    bWasRight       = (aStrafe > DodgeThresh);
	    bWasLeft        = (aStrafe < -DodgeThresh);
    }
    else // don't allow dodging with analog stick (it sucks)
    {
	    bEdgeForward    = false;
	    bEdgeBack       = false;
	    bEdgeRight      = false;
	    bEdgeLeft       = false;
	    bWasForward     = false;
	    bWasBack        = false;
	    bWasRight       = false;
	    bWasLeft        = false;
    }

    // Map to other input axes
    aForward = aBaseY;
    aTurn    = HLook * FOVScale;
    aLookUp  = VLook * FOVScale;

    if (Abs(aBaseY) > RunThresh || Abs(aStrafe) > RunThresh)
        bRun = 0; 
    else
        bRun = 1; // bRun=1 means walking obviously
    
	// Handle walking.
	HandleWalking();
}

// exp remap + linear remap
static function float Remap(float in, float scale, float exp, float ratemax)
{
    local float out;
    local bool bNeg;

    in /= InputMax;

    if (in < 0)
    {
        bNeg = true;
        in *= -1.f;
    }

    out = (in * scale) + (in**exp);

    if (bNeg)
        out *= -1.f;

    out *= ratemax/(1.f + scale);

    return out;
}

function bool InvertLook()
{
    bInvertVLook = !bInvertVLook;
    return bInvertVLook;
}

function bool GetInvertLook()
{
    return(bInvertVLook);
}

function SetInvertLook(bool invert)
{
    bInvertVLook = invert;
}

simulated function float GetSensitivityX()
{
    return(LookRateX / SENSITIVITY_SCALE);
}

simulated function float GetSensitivityY()
{
    return(LookRateY / SENSITIVITY_SCALE);
}

simulated function SetSensitivityX( float Sensitivity )
{
    LookRateX = FMax( 0.f, Sensitivity * SENSITIVITY_SCALE );
    default.LookRateX = LookRateX; 
	SaveConfig();
}

simulated function SetSensitivityY( float Sensitivity )
{
    LookRateY = FMax( 0.f, Sensitivity * SENSITIVITY_SCALE );
    default.LookRateY = LookRateY; 
	SaveConfig();
}

defaultproperties
{
     HExponent=1.000000
     HLookRateMax=3000.000000
     VExponent=1.000000
     VLookRateMax=1500.000000
     VelScale=0.013400
     AccelScale=4.655000
     DampeningFactor=30.000000
     MinAccelComponent=0.100000
     LookRateX=1500.000000
     InsideRateX=250.000000
     LookRateY=2000.000000
     InsideRateY=250.000000
     LookPresets(0)=(PresetName="Linear",HExponent=1.000000,VExponent=1.000000)
     LookPresets(1)=(PresetName="Exponential",HExponent=2.000000,VExponent=2.000000)
     LookPresets(2)=(PresetName="Hybrid",HScale=0.500000,HExponent=4.000000,VScale=0.500000,VExponent=4.000000)
     LookPresets(3)=(PresetName="Custom",HScale=0.500000,HExponent=4.000000,VScale=0.500000,VExponent=4.000000)
     SelectedPresetName="Hybrid"
}
