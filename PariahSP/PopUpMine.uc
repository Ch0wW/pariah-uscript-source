class PopUpMine extends Mine;


var float ArmingRadius;
var MineCollisionArea ArmingArea;

var Sound ArmedSound;


function PostBeginPlay()
{
	local Vector v;
	super.PostBeginPlay();


	ArmingArea = spawn(class'MineCollisionArea',self,,Location + v, Rotation);

	ArmingArea.SetCollisionSize(ArmingRadius, 100.0);
	ArmingArea.MyMine = self;

	Skins.Length = 0;   //Wipe out Static Mesh skins automatically put in SKINS on Xbox (and thus showing up as MESH skin as a result)
}

function Arm()
{
	if(bArmed) return;

	Super.Arm();

	PlayAnim('up');
	GotoState('up');

}

function Disarm()
{
	AmbientSound = None;

	if(!bArmed) return;


	Super.Disarm();

	PlayAnim('Down');
	GotoState('Down');

}

function ArmMore()
{
	local PopUpMine p;
    ForEach VisibleCollidingActors(class'PopUpMine', p, ArmingRadius)
	{
		if(p==self) continue;
		log("arming "$p@VSize(p.Location - Location));
		p.Arm();
	}
}

function DisarmMore()
{
	local PopUpMine p;
    ForEach VisibleCollidingActors(class'PopUpMine', p, ArmingRadius)
	{
		if(p==self) continue;
		log("disarming "$p@VSize(p.Location - Location));
		p.Disarm();
	}
}

function Explode()
{
	ArmingArea.Destroy();

	Super.Explode();
}

Auto state Down
{
	function BeginState()
	{
		Enable('AnimEnd');
		AmbientSound = None;
	}
	event AnimEnd(int channel)
	{
		log("ANIMEND DOWN");
		Disable('AnimEnd');
		DisarmMore();
	}

	function AreaViolated(Actor Other, MineCollisionArea area)
	{
		if(Area == ArmingArea)
		{
			Arm();
		}
	}

}


state Up
{
	function BeginState()
	{
		Enable('AnimEnd');
	}
	event AnimEnd(int channel)
	{
		log("ANIMEND UP");
		ArmMore();
		Disable('AnimEnd');
		LoopAnim('ScanLoop');
		AmbientSound = ArmedSound;
	}

	function AreaViolated(Actor Other, MineCollisionArea area)
	{
		if(Area != ArmingArea)
			Super.AreaViolated(Other, area);
	}

	function AreaUnviolated(Actor Other, MineCollisionArea area)
	{
		if(Area == ArmingArea)
		{
			Disarm();
		}
	}

}

defaultproperties
{
     ArmingRadius=750.000000
     ArmedSound=Sound'PariahGameSounds.Mines.MineArmedLoop'
     MineCollisionHeight=10.000000
     MineCollisionHeightOffset=150.000000
     ExplodeSound=Sound'PariahGameSounds.Mines.MineExplosionA'
     ArmingSound=Sound'PariahGameSounds.Mines.MineRaising'
     DisarmingSound=Sound'PariahGameSounds.Mines.MineLowering'
     bArmed=False
     Mesh=SkeletalMesh'PariahGameplayDevices.PopUpMine'
     AmbientSound=Sound'PariahGameSounds.Mines.MineArmedBeepLoop'
     DrawType=DT_Mesh
     SoundVolume=8
     SoundPitch=32
}
