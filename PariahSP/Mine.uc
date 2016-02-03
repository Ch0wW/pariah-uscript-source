class Mine extends GameplayDevices
	placeable;


var MineCollisionArea MineCollisionArea;
var class<MineCollisionArea> MineCollisionAreaClass;

var float MineCollisionRadius, MineCollisionHeight, MineCollisionHeightOffset;

var float ExplodeDamage;
var float ExplodeRadius;
var float ExplodeMomentum;
var Sound ExplodeSound, ArmingSound, DisarmingSound;

var class<Emitter> ExplodeEmitter, ExplosionDistortionClass;
var() bool bArmed;

var bool bExploding;
var bool bDestroyOnExplode;


var(Events) editconst const Name hArm;
var(Events) editconst const Name hDisarm;
var(Events) editconst const Name hBlowup;

var(Events) Name	ArmEvent;
var(Events) Name	DisarmEvent;
var(Events) Name	BlowupEvent;


var bool bKeepCollisionArea;

function PostBeginPlay()
{
	local Vector v;
	super.PostBeginPlay();


	v.z = MineCollisionHeightOffset;
	MineCollisionArea = spawn(MineCollisionAreaClass,self,,Location + v, Rotation);
	MineCollisionArea.MyMine = self;

	ModifyCollisionArea(MineCollisionArea);

}

function ModifyCollisionArea(MineCollisionArea area)
{
	MineCollisionArea.SetCollisionSize(MineCollisionRadius, MineCollisionHeight);
}

function Arm()
{
	if(bArmed == true) return;

	bArmed=true;

	if(ArmingSound != None)
	{
		PlaySound(ArmingSound);
	}
	if(ArmEvent != 'None')
	{
		TriggerEvent( ArmEvent, self, None );
	}
}

function Disarm()
{
	if(!bArmed) return;

	bArmed=false;

	if(DisarmingSound != None)
	{
		PlaySound(DisarmingSound);
	}
	if(DisarmEvent != 'None')
	{
		TriggerEvent( DisarmEvent, self, None );
	}

}

event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch(handler)
	{
	case hArm:
		log("ARMING");
		Arm();
		break;
	case hDisarm:
		log("DISARMING");
		Disarm();
		break;
	case hBlowup:
		TriggeredExplode();
		break;
	}

}

function TriggeredExplode()
{
	Explode();
}

function AreaViolated(Actor Other, MineCollisionArea area)
{
	if(bArmed && !bExploding)
		Explode();
}

function AreaUnviolated(Actor Other, MineCollisionArea area);

function Explode()
{
	bExploding=true;

	if(!bKeepCollisionArea)
		MineCollisionArea.Destroy();

	DoExplodeDamage();

	if(ExplodeEmitter != None)
		spawn(ExplodeEmitter,self,,Location,Rotation);
	if(ExplosionDistortionClass != None)
		spawn(ExplosionDistortionClass,self,,Location,Rotation);

	if(ExplodeSound != None)
		PlaySound(ExplodeSound);

	if ( BlowupEvent != 'None' )
	{
		TriggerEvent( BlowupEvent, self, None );
	}

    if ( bDestroyOnExplode )
    {
	    Destroy();
    }
}

function DoExplodeDamage()
{
	HurtRadius(ExplodeDamage, ExplodeRadius, class'BarrelExplDamage', ExplodeMomentum, Location );
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	if(bExploding) return;

	Explode();
}

function Destroyed()
{
	if(MineCollisionArea!=None)
		MineCollisionArea.Destroy();
}

defaultproperties
{
     MineCollisionRadius=300.000000
     MineCollisionHeight=100.000000
     ExplodeDamage=60.000000
     ExplodeRadius=768.000000
     ExplodeMomentum=1024.000000
     hArm="Arm"
     hDisarm="Disarm"
     hBlowup="BlowUp"
     MineCollisionAreaClass=Class'PariahSP.MineCollisionArea'
     ExplodeEmitter=Class'VehicleEffects.GrenadeExplosion'
     ExplosionDistortionClass=Class'VehicleEffects.ParticleRocketExplosionSmallDistort'
     bArmed=True
     bDestroyOnExplode=True
     DrawScale=0.300000
     StaticMesh=StaticMesh'DavidPrefabs.Blocks.Cylinder'
     DrawType=DT_StaticMesh
     bHasHandlers=True
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
     bProjTarget=True
}
