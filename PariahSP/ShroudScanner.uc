class ShroudScanner extends ScanningDevice
	placeable;

enum ShroudScannerState
{
	SSS_Down,
	SSS_MovingUp,
	SSS_Up,
	SSS_MovingDown
};

var ShroudScannerState	ScannerState;

var() int				PitchCorrection;
var() float				PitchScanSpeed;
var int					PitchOffset;
var bool				bPitchTrackSound;

var() class<Actor>		ScannerClass;
var() vector			ScannerOffset[2];
var() float				ScannerPitchSpeed;
var() range				ScannerPitchRange;
var() int				ScannerPitchCenter;
var int					ScannerPitchOffset[2];
var int					ScannerPitchDir[2];
var() float				ScannerYawSpeed;
var() range				ScannerYawRange;
var() int				ScannerYawCenter;
var int					ScannerYawOffset[2];
var int					ScannerYawDir[2];

Auto state Scanning
{
	function AnimEnd(int Channel)
    {
		Notify();
    }

BEGIN:
	`log("BEGIN"@GetStateName());

	if ( ScannerState != SSS_Down )
	{
		ScannerState = SSS_MovingDown;
		PlayAnim( 'Down' );
		WaitForNotification();
		ScannerState = SSS_Down;
	}
}

state Alerted
{
	function AnimEnd(int Channel)
    {
		Notify();
    }

BEGIN:
	`log("BEGIN"@GetStateName());

	if ( ScannerState != SSS_Up )
	{
		ScannerState = SSS_MovingUp;
		PlayAnim( 'up' );
		WaitForNotification();
		ScannerState = SSS_Up;
	}
}

// All these yaw and pitch calculations are highly dependant on the layout of the Swivel and Head
// bones in the skeleton
//
function int GetDeviceYaw()
{
	local rotator	SwivelRot;
	local int		yaw;

	SwivelRot = GetBoneRotation( 'Swivel' );	// this returns global rotation

	// the X axis of the swivel bone points to the left, so compensate for that
	//
	yaw = SwivelRot.Yaw + 16384;
	return yaw;
}

function SetDeviceYaw( int yaw )
{
	local rotator	SwivelRot;

	SwivelRot.Yaw = 16384 - (yaw - Rotation.Yaw);
	SetBoneRotation( 'Swivel', SwivelRot );
}

function SetDevicePitch( int pitch )
{
	local rotator	r;

	r.Roll = pitch + PitchCorrection;
	r.Pitch = 0;
	r.Yaw = 0;
	SetBoneRotation( 'Head', r );
}

function int CalcScanOffset( out int ScanDir, int ScanOffset, range ScanRange, float ScanSpeed, float dt, optional bool bFlipRange )
{
	local int ScanTarget;

	if ( ScanDir == 1 )
	{
		if ( bFlipRange )
		{
			ScanTarget = -ScanRange.Min;
		}
		else
		{
			ScanTarget = ScanRange.Max;
		}
	}
	else
	{
		if ( bFlipRange )
		{
			ScanTarget = -ScanRange.Max;
		}
		else
		{	
			ScanTarget = ScanRange.Min;
		}
	}
	if( ScanOffset < ScanTarget )
	{
		ScanOffset = FMin( ScanOffset + dt * ScanSpeed, ScanTarget );
	}
	else 
	{
		ScanOffset = FMax( ScanOffset - dt * ScanSpeed, ScanTarget );
	}
	if ( ScanOffset == ScanTarget )
	{
		ScanDir *= -1;
	}
	return ScanOffset;
}

function DoScan( float dt, int TargetYaw ) 
{
	local coords	HeadCoords, ScannerCoords;
	local vector	v;
	local rotator	r;
	local int		OldPitch, TargetPitch;
	local int		s;
	local name		bn;

	OldPitch = PitchOffset;

	if ( ScannerState == SSS_Up )
	{
		Super.DoScan( dt, TargetYaw );
		if ( TargetInView() )
		{
			HeadCoords = GetBoneCoords( 'Head' );
			v = target.Location - HeadCoords.Origin;
			r = Rotator(v);
			TargetPitch = r.Pitch;

			if ( ScannerClass != None )
			{
				for ( s = 0; s < 2; s++ )
				{
					ScannerPitchOffset[s] = CalcScanOffset( ScannerPitchDir[s], ScannerPitchOffset[s], ScannerPitchRange, ScannerPitchSpeed, dt );
					ScannerYawOffset[s] = CalcScanOffset( ScannerYawDir[s], ScannerYawOffset[s], ScannerYawRange, ScannerYawSpeed, dt, s == 0 );
					r.Pitch = ScannerYawOffset[s];
					r.Yaw = ScannerPitchCenter + ScannerPitchOffset[s];
					r.Roll = 0;
					if ( s == 0 )
					{
						r.Pitch += ScannerYawCenter;
						bn = 'FX1';
					}
					else
					{
						r.Pitch -= ScannerYawCenter;
						bn = 'FX2';
					}
					SetBoneRotation( bn, r );
					ScannerCoords = GetBoneCoords( bn );
					v = ScannerCoords.Origin +
						HeadCoords.XAxis * ScannerOffset[s].X +
						HeadCoords.YAxis * ScannerOffset[s].Y +
						HeadCoords.ZAxis * ScannerOffset[s].Z;
					spawn( ScannerClass, self, , v, Rotator(ScannerCoords.XAxis) );
				}
			}
		}
	}
	else 
	{
		Super.DoScan( dt, 0 );
	}
	if( PitchOffset < TargetPitch )
	{
		PitchOffset = FMin(PitchOffset + dt * PitchScanSpeed, TargetPitch);
	}
	else 
	{
		PitchOffset = FMax(PitchOffset - dt * PitchScanSpeed, TargetPitch);
	}
	if ( PitchOffset == TargetPitch && bPitchTrackSound )
	{
		TrackSoundOff();
		bPitchTrackSound = false;
	}

	SetDevicePitch(PitchOffset);

	if( Abs(OldPitch - PitchOffset) > 10 && !bPitchTrackSound )
	{
		TrackSoundOn();
		bPitchTrackSound = true;
	}
	if ( bDebugging )
	{
		HeadCoords = GetBoneCoords( 'Head' );
		drawdebugline( HeadCoords.Origin, target.Location, 255, 255, 255 );	
		drawdebugline( HeadCoords.Origin, HeadCoords.Origin + HeadCoords.ZAxis * -ScanHalfDist, 0, 0, 255 );	
	}
}

defaultproperties
{
     PitchCorrection=1800
     ScannerPitchCenter=1500
     ScannerPitchDir(0)=1
     ScannerPitchDir(1)=1
     ScannerYawCenter=2500
     ScannerYawDir(0)=1
     ScannerYawDir(1)=-1
     PitchScanSpeed=4000.000000
     ScannerPitchSpeed=1000.000000
     ScannerYawSpeed=2000.000000
     ScannerClass=Class'VehicleEffects.SniperTrail'
     ScannerOffset(0)=(X=17.000000)
     ScannerOffset(1)=(X=-17.000000)
     ScannerPitchRange=(Min=-1000.000000,Max=1000.000000)
     ScannerYawRange=(Max=2000.000000)
     YawCenter=16384
     ScanMaxDist=1500.000000
     ScanHalfDist=750.000000
     YawRange=(Min=-8000.000000,Max=8000.000000)
     Mesh=SkeletalMesh'PariahGameplayDevices.Shroud_LightFixture'
     DrawType=DT_Mesh
}
