class CollisionStaticMesh extends StaticMeshActor;
	
//ksue

// For use as a collision model over a skeletal mesh

var Actor DamageLinkActor;

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, 
					vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	log("CollisionStaticMesh - TakeDamage function");
	DamageLinkActor.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);
}

simulated function PostBeginPlay()
{
	SetSkin(0, none);

}

simulated function PreBeginPlay()
{
	//DamageLinkActor = self;
	log("DamageLinkActor "$DamageLinkActor );
}

defaultproperties
{
     DrawScale3D=(X=-1.000000)
     bStatic=False
     bProjTarget=True
     bBlockKarma=False
}
