//=============================================================================
//=============================================================================
class FragRifleProjHot extends FragRifleProj;

//var xEmitter		Trail;
//var class<xEmitter>	TrailClass;
//var class<Actor>	ExplosionClass;

var	float			BurnDamage;
var	float			BurnTime;

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	Super.ProcessTouch(Other, HitLocation);

	if ( Other!=Instigator && Other != none && Instigator != none/*&& !Other.IsA('Projectile') */)
	{
		if(Other.IsA('VGPawn'))
		{
			VGPawn(Other).Poison(Instigator, BurnDamage, BurnTime);
		}
	}
}

defaultproperties
{
     BurnDamage=6.000000
     BurnTime=5.000000
     MomentumTransfer=100.000000
}
