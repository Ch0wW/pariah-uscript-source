class ScanningDevice extends GameplayDevices
	notplaceable;

var() Range		YawRange;
var() int		YawCenter;
var int			AdjYawCenter;

var int			YawOffset;

var int			ScanDir;
var float		ScanSpeed;

var() float		BaseScanSpeed, AlertScanSpeed, ScanPause;

var bool		bPause;

var Actor		Target;

var() Name		AlertEvent, AlarmEvent, NoAlarmEvent;
var() float		AlertEventRepeat, AlarmEventRepeat, NoAlarmEventRepeat;

var() float		AlertCooldown;
var() float		AlarmCooldown;

var() Sound		TrackSound, DetectSound;
var int			TrackSoundCount;
var bool		bYawTrackSound;

var() bool		bDebugging;

var() float		ScanMaxDist;
var float		ScanHalfDist;

function bool	IsValidPawnTarget(Pawn p);
function		FoundPawnTarget(Actor NewTarget);

function int	GetDeviceYaw();
function		SetDeviceYaw( int yaw );

event PostBeginPlay()
{
	Super.PostBeginPlay();
	ScanHalfDist = ScanMaxDist / 2;
	AdjYawCenter = YawCenter + Rotation.Yaw;
}

function bool IsValidHavokTarget(HavokActor h)
{
	if(VSize(h.Velocity) > 10.0 )
		return true;
	else
		return false;
}

function FoundHavokTarget(Actor NewTarget)
{
	Target = NewTarget;
	GotoState('Alerted');
}

function float GetStateCooldown();

function TrackSoundOn()
{
	if ( TrackSoundCount == 0 )
	{
		AmbientSound = TrackSound;
	}
	TrackSoundCount++;
}

function TrackSoundOff()
{
	if ( TrackSoundCount > 0 )
	{
		TrackSoundCount--;
		if ( TrackSoundCount == 0 )
		{
			AmbientSound = None;
		}
	}
}

Auto state Scanning
{
	function SetDeviceMaterials()
	{
	}

	function BeginState()
	{
		ScanDir = -1;
		ScanSpeed = BaseScanSpeed;
		SetMultiTimer(0, 0.33, true);
		Target = None;
		bPause = false;

		SetDeviceMaterials();

		if(AlertEvent != '')
			TriggerEvent(NoAlarmEvent, self, Pawn(Target));

		
		if(NoAlarmEventRepeat != 0 && NoAlarmEvent != '')
			SetMultiTimer(2, NoAlarmEventRepeat, true);
	}

	function Tick(float dt)
	{
		local float TargetYaw;

		if(!bPause)
		{
			if(ScanDir == 1)
				TargetYaw = YawRange.Max;
			else 
				TargetYaw = YawRange.Min;

			DoScan(dt, TargetYaw);
		}
	}

	function EndScan()
	{
		SetMultiTimer(1, ScanPause, false);
		ScanDir *= -1;
		bPause = true;
	}

	function bool IsValidPawnTarget(Pawn P)
	{
		if(	P.IsA('SPPlayerPawn') || (P.IsA('SPPawn') && SPPawn(P).race == R_NPC) )
			return true;
		else return false;
	}

	function FoundPawnTarget(Actor NewTarget)
	{
		Target = NewTarget;
		GotoState('Alerted');
	}

	function MultiTimer(int slot)
	{
		switch(slot)
		{
		case 0:
			CheckView();
			break;
		case 1:
			bPause = false;
			break;
		case 2:
			TriggerEvent(NoAlarmEvent, self, None);
			break;
		}
	}

	function EndState()
	{
		SetMultiTimer(0, 0, false);
		SetMultiTimer(1, 0, false);
		SetMultiTimer(2, 0, false);
	}
}

state Alerted
{
	function SetDeviceMaterials()
	{
	}

	function BeginState()
	{
		//do some switches to alert textures, sounds, etc
		ScanSpeed = AlertScanSpeed;

		SetDeviceMaterials();
		PlaySound(DetectSound);

		if(AlertEvent != '')
			TriggerEvent(AlertEvent, self, Pawn(Target));
		
		if(AlertEventRepeat != 0 && AlertEvent != '')
			SetMultiTimer(2, AlertEventRepeat, true);

		SetMultiTimer(3, AlertCooldown, false);
	}

	function MultiTimer(int slot)
	{
		switch(slot)
		{
		case 2:
			TriggerEvent(AlertEvent, self, Pawn(Target));
			break;
		case 3:
			if(TargetInView() && (Target.IsA('Pawn') || IsValidHavokTarget(HavokActor(Target)) ) )
			{
				GotoState('Alarmed');
			}
			else
			{
				GotoState('Scanning');
			}
			break;
		}
	}

	function float GetStateCooldown()
	{
		return AlertCooldown;
	}

	function Tick(float dt)
	{
		local Vector targetdir;
		local Rotator r;
		local int rot;

		if ( TargetInView() )
		{
			targetdir = Normal(target.Location - Location);
			r = Rotator(targetdir);
			rot = GetRotDiff(AdjYawCenter, r.yaw);
		}

		DoScan(dt, rot);
	}

	function EndState()
	{
		SetMultiTimer(2, 0, false);
		SetMultiTimer(3, 0, false);
	}
}

state Alarmed extends Alerted
{
	function SetDeviceMaterials()
	{
	}

	function BeginState()
	{
		ScanSpeed = AlertScanSpeed;

		SetDeviceMaterials();
		PlaySound(DetectSound);

		if(AlarmEvent != '')
			TriggerEvent(AlarmEvent, self, Pawn(Target));

		if(AlarmEventRepeat != 0 && AlarmEvent!='')
			SetMultiTimer(2, AlarmEventRepeat, true);

		SetMultiTimer(3, AlarmCooldown, true);
	}

	function float GetStateCooldown()
	{
		return AlarmCooldown;
	}

	function MultiTimer(int slot)
	{
		switch(slot)
		{
		case 2:
			TriggerEvent(AlarmEvent, self, Pawn(Target));
			break;
		case 3:
			if(!TargetInView() || ( Target.IsA('HavokActor') && !IsValidHavokTarget(HavokActor(Target)) ) )
			{
				GotoState('Scanning');
			}
		}
	}
}

function CheckView()
{
	local Vector dir, loc;
	local Pawn p;
	local HavokActor h;
	local Rotator r;

	r.Yaw = GetDeviceYaw();
	if( bDebugging )
	{
		drawdebugline( Location,  Location + Normal(Vector(r)) * ScanMaxDist, 0, 0, 255 );	
	}

	dir = Normal(Vector(r));

	loc = Location + dir * ScanHalfDist;

	if ( bDebugging )
	{
		DrawDebugCircle(Loc, ScanHalfDist);
		DrawDebugCircle(Loc, ScanHalfDist, Vect(0,0,1));
		DrawDebugCircle(Loc, ScanHalfDist,,Vect(0,0,1));
	}

	ForEach CollidingActors(class'Pawn',p, ScanHalfDist, loc)
	{
		if(p.IsA('SPPlayerPawn') || (p.IsA('SPPawn') && SPPawn(p).race == R_NPC))
		{
			// log("I see "$p@ Normal(Location - p.Location) dot dir);
			if(Normal(p.Location - Location) dot dir > 0.9)
			{
				if(IsValidPawnTarget(p))
				{
					FoundPawnTarget(p);
					break;
				}
				break;
			}
		}
	}

	ForEach CollidingActors(class'HavokActor',h, ScanHalfDist, loc)
	{
		//log("I see "$p@ Normal(Location - p.Location) dot dir);
		if(Normal(h.Location - Location) dot dir > 0.9)
		{
			//log("I see "$h);
			if(IsValidHavokTarget(h))
			{
				FoundHavokTarget(h);
				break;
			}
			break;
		}
	}


}

function int GetRotDiff(int current, int target)
{
	local int ret;

	current = current&65535;
	target = target&65535;

	ret = target - current;
	return ret;
}

function DoScan( float dt, int TargetYaw ) //targetyaw is relative to AdjYawCenter
{
	local Rotator r;

	local int OldYaw;
	OldYaw = YawOffset;

	TargetYaw = FClamp(TargetYaw, YawRange.Min, YawRange.Max);

    if( YawOffset < TargetYaw )
	{
		YawOffset = FMin(YawOffset + dt * ScanSpeed, TargetYaw);
	}
	else 
	{
		YawOffset = FMax(YawOffset - dt * ScanSpeed, TargetYaw);
	}
	if( YawOffset == TargetYaw )
	{
		if ( bYawTrackSound )
		{
			TrackSoundOff();
			bYawTrackSound = false;
		}
		EndScan();
	}

	r.Yaw = AdjYawCenter + YawOffset;
	if( bDebugging )
	{
		drawdebugline( Location,  Location + Normal(Vector(r)) * ScanMaxDist, 0, 255, 0 );	
	}
	SetDeviceYaw(r.Yaw);

	if( Abs(OldYaw - YawOffset) > 10 && !bYawTrackSound )
	{
		bYawTrackSound = true;
		TrackSoundOn();
	}
}

function EndScan()
{
}

function bool TargetInView()
{
	local Vector dir, targetdir;
	local float ang, dist;
	local rotator r;

	r.Yaw = GetDeviceYaw();
	if( bDebugging )
	{
		drawdebugline( Location,  Location + Normal(Vector(r)) * ScanMaxDist, 0, 0, 255 );	
	}
	dir = Vector(r);
	targetdir = Normal(target.Location - Location);
	if( bDebugging )
	{
		drawdebugline( Location,  Location + targetdir * ScanMaxDist, 0, 255, 255 );	
	}
	dist = VSize(Location - Target.Location);

	ang = targetdir dot dir;

	return dist < ScanMaxDist && ang > 0.9;
}

defaultproperties
{
     BaseScanSpeed=2000.000000
     AlertScanSpeed=8000.000000
     ScanPause=2.000000
     AlertCooldown=1.500000
     AlarmCooldown=8.000000
     TrackSound=Sound'PariahGameSounds.Camera.CameraScanA'
     DetectSound=Sound'PariahGameSounds.Camera.DetectionBeepA'
}
