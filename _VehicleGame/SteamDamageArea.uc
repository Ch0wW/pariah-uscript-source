class SteamDamageArea extends Actor;


var Actor SpawningActor;
var Emitter MySteam;
var int PPS;
var SteamAvoidMarker MyAvoidMarker;

function Touch(Actor Other)
{
	log("touched by "$other);
}

function UnTouch(Actor Other)
{
	log("untouched by "$other);
}

Auto state Steaming
{
	function BeginState()
	{
		MySteam = Spawn(class'DavidSteam',self,,Location, Rotation);
		MyAvoidMarker = Spawn(class'SteamAvoidMarker', self,,Location, Rotation);

		PPS = MySteam.Emitters[0].ParticlesPerSecond;

		SetMultiTimer(0, 5, false);
		SetMultitimer(1, 0.2, true);
	}

	event MultiTimer(int slot)
	{
		switch(slot)
		{
		case 0:
			GotoState('Finishing');
			break;
		case 1:
			DoDamage();
			break;
		}
	}

}

state Finishing
{
	function BeginState()
	{
		MySteam.Emitters[0].ParticlesPerSecond = 0;
		SetTimer(1, false);
	}

	function Timer()
	{
		Destroy();
	}

}

event Destroyed()
{
	if( MySteam != None )
		MySteam.Destroy();
	if( MyAvoidMarker != None )
		MyAvoidMarker.Destroy();
}


function DoDamage()
{
	local VGPawn p;
	ForEach TouchingActors(class'VGPawn', p)
	{
		p.TakeDamage(5, none, p.Location, Vect(0,0,0), class'SteamDamageType');
	}
}


static function SpawnDamageArea(Actor Spawner, Vector Location, Vector Normal)
{
	local SteamDamageArea s;
	ForEach Spawner.CollidingActors(class'SteamDamageArea', s, 180, Location)
	{
		return;
	}

	log("spawning a steam damage area at "$Location$" "$Rotator(Normal)$" from owner "$Spawner);

	Spawner.Spawn(class'SteamDamageArea',Spawner,, Location, Rotator(Normal));
}

defaultproperties
{
     StaticMesh=StaticMesh'PariahGametypeMeshes.neutral.SteamBox'
     AmbientSound=SoundGroup'DavidSounds.Steam.SteamGroup'
     DrawScale3D=(X=1.500000,Y=1.500000,Z=1.500000)
     DrawType=DT_StaticMesh
     bHidden=True
     bOnlyAffectPawns=True
     bCollideActors=True
     bCheckOverlapWithBox=True
}
