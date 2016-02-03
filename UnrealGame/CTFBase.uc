//=============================================================================
// CTFBase.
//=============================================================================
class CTFBase extends GameObjective
	abstract;

var() Sound TakenSound;
var CTFFlag myFlag;
var class<CTFFlag> FlagType;

function BeginPlay()
{
	Super.BeginPlay();
	bHidden = false;

	myFlag = Spawn(FlagType, self);

	if (myFlag==None)
	{
		warn(Self$" could not spawn flag of type '"$FlagType$"' at "$location);
		return;
	}
	else
	{
		myFlag.HomeBase = self;
		myFlag.TeamNum = DefenderTeamIndex;
	}
}

function PlayAlarm()
{
	SetTimer(5.0, false);
	//AmbientSound = TakenSound;
}

function Timer()
{
	StopBaseSound();
}

function StopBaseSound()
{
	AmbientSound = None;
}

defaultproperties
{
     DrawScale=1.300000
     SoundRadius=255.000000
     CollisionRadius=60.000000
     CollisionHeight=60.000000
     NetUpdateFrequency=8.000000
     DrawType=DT_Mesh
     SoundVolume=255
     bStatic=False
     bAlwaysRelevant=True
     bCollideActors=True
}
