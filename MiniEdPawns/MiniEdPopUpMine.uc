class MiniEdPopUpMine extends MiniEdMine;

var float ArmingRadius;
var MiniEdMineCollisionArea ArmingArea;

var Sound ArmedSound;

var bool bUp;
var bool bWasUp;

replication
{
	reliable if ( Role==ROLE_Authority )
		bUp;
}


simulated function PostNetReceive()
{

	if(bUp && !bWasUp) //need to play up anim, then loop
	{
		PlayAnim('up');
		Enable('AnimEnd');
		bWasUp = true;
	}

	if(!bUp && bWasUp) //need to play down anim
	{
		PlayAnim('Down');
		bWasUp = false;
	}


}

simulated function AnimEnd(int channel)
{
	Super.AnimEnd(channel);
	if(Role == ROLE_Authority)
	{
		return;
	}


	if(bUp) //then we want to play the loop
	{
		LoopAnim('ScanLoop');
		Disable('AnimEnd');
	}

}

function PostBeginPlay()
{
	local Vector v;
	super.PostBeginPlay();

	ArmingArea = spawn(class'MiniEdMineCollisionArea',self,,Location + v, Rotation);

	ArmingArea.SetCollisionSize(ArmingRadius, 100.0);
	ArmingArea.MyMine = self;
}

function Arm()
{
	if(bArmed) return;

	Super.Arm();
	bUp = true;
	PlayAnim('up');
	GotoState('up');
}

function Disarm()
{
	AmbientSound = None;

	if(!bArmed) return;



	Super.Disarm();
	bUp = false;
	PlayAnim('Down');
	GotoState('Down');
}

function ArmMore()
{
	local MiniEdPopUpMine p;
    ForEach VisibleCollidingActors(class'MiniEdPopUpMine', p, ArmingRadius)
	{
		if(p==self) continue;
		log("arming "$p@VSize(p.Location - Location));
		p.Arm();
	}
}

function DisarmMore()
{
	local MiniEdPopUpMine p;
    ForEach VisibleCollidingActors(class'MiniEdPopUpMine', p, ArmingRadius)
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

	function AreaViolated(Actor Other, MiniEdMineCollisionArea mArea)
	{
		if(mArea == ArmingArea)
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

	function AreaViolated(Actor Other, MiniEdMineCollisionArea mArea)
	{
		if(mArea != ArmingArea)
			Super.AreaViolated(Other, mArea);
	}

	function AreaUnviolated(Actor Other, MiniEdMineCollisionArea mArea)
	{
		if(mArea == ArmingArea)
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
     DrawType=DT_Mesh
     bNetNotify=True
}
