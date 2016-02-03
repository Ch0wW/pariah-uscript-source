class StocktonCeilingPart extends SimpleHavokDestroyableMesh;

var StocktonStage OwningStage;


function GetBent(Pawn instigator,optional Controller ProjOwner)
{
	OwningStage.RemoveCeilingPart(self);

	Super.GetBent(instigator,ProjOwner);
}

event bool EncroachingOn(Actor Other)
{
//	log("Encroaching on "$other);

	if(VSize(Velocity) > 100.0)
	{
		Other.TakeDamage(1300, none, location, Velocity, class'Crushed');	
		
	}

	return Super.EncroachingOn(Other);
}



function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, 
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	if(DamageType == class'TitansFistDamage')
		Super.TakeDamage(10000,eventinstigator,hitlocation,momentum,damagetype,projowner,bsplashdamage);
	else
		Super.TakeDamage(Damage,eventinstigator,hitlocation,momentum,damagetype,projowner,bsplashdamage);
}

defaultproperties
{
     HMass=2000.000000
     HRestitution=0.000000
     HGravScale=2.000000
     MaxHealth=500
     DrawScale=4.000000
}
