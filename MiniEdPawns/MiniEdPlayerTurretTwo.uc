class MiniEdPlayerTurretTwo extends PlayerTurretAlternate
	placeable;

var StaticMesh ColMesh;


function PostBeginPlay()
{
	local SpecialStaticMesh SSM;

	Super.PostBeginPlay();

	SSM = Spawn( class'SpecialStaticMesh',,, Location, Rotation );
	SSM.SetStaticMesh(ColMesh);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{    
    PawnGunner.TakeDamage(Damage / 2, instigatedBy, hitlocation, momentum, damageType);    // take only half of the damage when you are in a turret - mkm
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
}

event GotoDelayingDeath()
{

}

defaultproperties
{
     ColMesh=StaticMesh'JamesMiniEd.Collision.PlayerTurretStaticCollision'
     TurretCameraOffset=(X=0.000000)
     Health=4000000
     bCollideWorld=False
}
