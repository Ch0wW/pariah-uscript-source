class LaserMine extends Mine;


var() LaserMineExplosive myBomb;

var Sound TrippedSound,ArmedSound;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	assert(myBomb != None);

	if(bArmed)
	{
		AmbientSound=ArmedSound;
		Arm();
	}
	else
		Disarm();
}


function AreaViolated(Actor Other, MineCollisionArea area)
{
	if(!bArmed) return;

	Disarm();
	area.Destroy();
	if(TrippedSound!=None)
		PlaySound(TrippedSound);
	ExplodeBomb();
}

function Arm()
{
	Super.Arm();

	AmbientSound=ArmedSound;
	MineCollisionArea.bHidden=false;
}

function Disarm()
{
	Super.Disarm();

	AmbientSound=None;
	MineCollisionArea.bHidden=true;
}

function TriggeredExplode()
{
	ExplodeBomb();
}

function ExplodeBomb()
{
	myBomb.Explode();

	bArmed=false;

	if ( BlowupEvent != 'None' )
	{
		TriggerEvent( BlowupEvent, self, None );
	}
}

function ModifyCollisionArea(MineCollisionArea area)
{
	local LaserMineLaser laser;
	local vector v;
	local rotator r;

	laser = LaserMineLaser(area);

	assert(laser != None);

	assert( GetAttachPoint('laserattach', v, r) );

	laser.SetLocation( Location + ( v >> Rotation ) );
	laser.SetRotation( Rotation );

	laser.SetBase(self);

	laser.bHidden=!bArmed;

}

defaultproperties
{
     TrippedSound=Sound'PariahGameSounds.Mines.LaserMineTrip'
     ArmedSound=Sound'PariahGameSounds.Mines.LaserAmbientLoopB'
     ExplodeDamage=20.000000
     ExplodeRadius=128.000000
     ExplodeMomentum=256.000000
     MineCollisionAreaClass=Class'PariahSP.LaserMineLaser'
     ExplodeEmitter=Class'VehicleEffects.VehicleHitSparks'
     ExplosionDistortionClass=None
     DrawScale=1.000000
     StaticMesh=StaticMesh'PariahGametypeMeshes.neutral.tripmine_box'
}
