class SPScriptPawnStockton extends SPPawnNPC;


var bool bInvulnerable;



function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	if(bInvulnerable)
		return;
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);
}

defaultproperties
{
     bInvulnerable=True
     Health=200
     HealthMax=200.000000
     race=R_Guard
     bDontScaleAnimSpeedByVel=True
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.Stockton_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem114
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem114'
     Skins(0)=Shader'PariahCharacterTextures.Stockton.stocktonbody_shader'
     Skins(1)=FinalBlend'PariahCharacterTextures.Stockton.stockhead_fb'
     Skins(2)=Shader'PariahWeaponTextures.TitansFist.TF_Shader'
     Skins(3)=Shader'PariahWeaponTextures.TitansFist.TF_EnergyShader'
}
