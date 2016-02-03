class SPPawnStubbs extends SPPawnNPC;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
    Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage );
    Health=default.Health;
}

function bool MaySmoke()
{
    return false;
}

defaultproperties
{
     ExclamationClass=Class'PariahSPPawns.SPMilitaryExclaim'
     Helmet=StaticMesh'PariahCharacterMeshes.Helmets.Stubbs_Helmet'
     bFriendly=True
     Health=10000
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.Stubbs_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem116
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem116'
}
