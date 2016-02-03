class SecurityCameraHead extends Actor
	notplaceable;


var Range YawRange;
var int YawCenter;

var int YawOffset;

var int ScanDir;
var float ScanSpeed;

var float BaseScanSpeed, AlertScanSpeed, ScanPause;

var SecurityCamera MyCamera;
	

var bool bPause;

var Actor Target;

var int LastTargetSide;

var Name AlertEvent, AlarmEvent, NoAlarmEvent;
var float AlertEventRepeat, AlarmEventRepeat, NoAlarmEventRepeat;

var float AlertCooldown;
var float AlarmCooldown;


var Material ScanMaterial, AlertMaterial, AlarmMaterial, ConeMaterial, AlertConeMaterial, AlarmConeMaterial;


var Sound TrackSound, DetectSound;

const ScanMaxDist = 1500;
const ScanHalfDist = 750;

function bool IsValidPawnTarget(Pawn p);
function FoundPawnTarget(Actor NewTarget);

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

Auto state Scanning
{
	function BeginState()
	{
		ScanDir = -1;
		ScanSpeed = BaseScanSpeed;
		SetMultiTimer(0, 0.33, true);
		Target = None;

		SetSkin(0, ScanMaterial);
		SetSkin(1, ConeMaterial);

		if(AlertEvent != '')
			TriggerEvent(NoAlarmEvent, self, Pawn(Target));

		
		if(NoAlarmEventRepeat != 0 && NoAlarmEvent != '')
			SetMultiTimer(2, NoAlarmEventRepeat, true);
		else
			SetMultiTimer(2, 0, false);
	}

	function Tick(float dt)
	{
		if(!bPause)
		{
			DoScan(dt, 0);
		}
	}

	function EndScan(int OldDir)
	{
		AmbientSound=None;

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
	}

}

function DoStateChange();

state Alerted
{
	function BeginState()
	{
		//do some switches to alert textures, sounds, etc
		ScanSpeed = AlertScanSpeed;

		SetSkin(0, AlertMaterial);
		SetSkin(1, AlertConeMaterial);

		PlaySound(DetectSound);

		if(AlertEvent != '')
			TriggerEvent(AlertEvent, self, Pawn(Target));

		
		if(AlertEventRepeat != 0 && AlertEvent != '')
			SetMultiTimer(2, AlertEventRepeat, true);
		else
			SetMultiTimer(2, 0, false);

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
		local Vector dir, targetdir,v ;
		local Rotator r;
		local int rot;
		local bool bInView;
		local bool bSkipScan;
		local float f;

		dir = Vector(Rotation);
		targetdir = Normal(target.Location - Location);

		bInView = TargetInView();

		if(bInView)
		{
			v = (dir cross targetdir);

			f = dir dot targetdir;
			if( v.z < -0.001 )
			{
				LastTargetSide = -1;
				ScanDir = -1;
			}
			else if( v.z > 0.001 )
			{
				LastTargetSide = 1;
				ScanDir = 1;
			}
			else
				bSkipScan = true;

			r = Rotator(targetdir);
			
			rot = GetRotDiff(LastTargetSide, yawcenter, r.yaw);
		}

		if(!bSkipScan)
			DoScan(dt, rot);
		else
			AmbientSound=None;


	}

	function EndState()
	{
		SetMultiTimer(3, 0, false);
	}

}

state Alarmed extends Alerted
{
	function BeginState()
	{
		ScanSpeed = AlertScanSpeed;

		SetSkin(0, AlarmMaterial);
		SetSkin(1, AlarmConeMaterial);
	
		PlaySound(DetectSound);

		if(AlarmEvent != '')
			TriggerEvent(AlarmEvent, self, Pawn(Target));

		if(AlarmEventRepeat != 0 && AlarmEvent!='')
			SetMultiTimer(2, AlarmEventRepeat, true);
		else
			SetMultiTimer(2, 0, false);

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

	dir = Normal(Vector(Rotation));

	loc = Location + dir * ScanHalfDist;

	//DrawDebugCircle(Loc, ScanHalfDist);
	//DrawDebugCircle(Loc, ScanHalfDist, Vect(0,0,1));
	//DrawDebugCircle(Loc, ScanHalfDist,,Vect(0,0,1));

	ForEach CollidingActors(class'Pawn',p, ScanHalfDist, loc)
	{
		if(p.IsA('SPPlayerPawn') || (p.IsA('SPPawn') && SPPawn(p).race == R_NPC))
		{
			//log("I see "$p@ Normal(Location - p.Location) dot dir);
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

function int GetRotDiff(int dir, int current, int target)
{
	local int ret;

	current = current&65535;
	target = target&65535;

	//log(current@target@dir);

	if(current == target) return target;

	

	if(dir == 1)
	{
		if(target > current)
		{
			ret = target - current;
		}
		else
		{
			ret = 65535 - current + target;
		}
	}
	else if(dir == -1)
	{
		if(current	> target)
		{
			ret = current - target;
		}
		else
		{
			ret = 65535 - target + current;
		}
		ret *= -1;
	}

	//log("result:  "$ret);
	return ret;
}

function DoScan(float dt, optional int TargetYaw) //targetyaw is relative to yawcenter
{
	local Rotator r;

	local int OldYaw;
	OldYaw = YawOffset;
	//log("DoScan dir "$ScanDir$" Target "$TargetYaw);

	if(TargetYaw == 0)
	{
		if(ScanDir == 1)
			TargetYaw = YawRange.Max;
		else if(ScanDir == -1)
			TargetYaw = YawRange.Min;

	}
	else
	{
		//log("checking to clamp targetyaw = "$ TargetYaw);
		TargetYaw = FClamp(TargetYaw, YawRange.Min, YawRange.Max);
	}

    if(ScanDir == 1)
	{
		YawOffset = FMin(YawOffset + dt * ScanSpeed, TargetYaw);

		if(YawOffset == TargetYaw)
		{
			EndScan(ScanDir);
		}

	}
	else if(ScanDir == -1)
	{
		YawOffset = FMax(YawOffset - dt * ScanSpeed, TargetYaw);

		if(YawOffset == TargetYaw)
		{
			EndScan(ScanDir);
		}

	}

	r = Rotation;
	r.Yaw = YawCenter + YawOffset;
	SetRotation(r);

	if(Abs(OldYaw - YawOffset) > 10)
		if(AmbientSound==None) AmbientSound=TrackSound;

}

function EndScan(int OldDir)
{
	AmbientSound=None;
}

function bool TargetInView()
{
	local Vector dir, targetdir;
	local float ang, dist;

	dir = Vector(Rotation);
	targetdir = Normal(target.Location - Location);
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
     ScanMaterial=Shader'PariahGameTypeTextures.Camera.camera_off_shader'
     AlertMaterial=Shader'PariahGameTypeTextures.Camera.camera_on_shader'
     AlarmMaterial=Shader'PariahGameTypeTextures.Camera.camera_search_shader'
     ConeMaterial=Shader'PariahGameTypeTextures.Camera.viewcone_shader'
     AlertConeMaterial=Shader'PariahGameTypeTextures.Camera.viewcone_yellow_shader'
     AlarmConeMaterial=Shader'PariahGameTypeTextures.Camera.viewcone_red_shader'
     TrackSound=Sound'PariahGameSounds.Camera.CameraScanA'
     DetectSound=Sound'PariahGameSounds.Camera.DetectionBeepA'
     StaticMesh=StaticMesh'PariahGametypeMeshes.Camera.camera_head'
     DrawType=DT_StaticMesh
}
