class SPPawnShroudAssassinCloaked extends SPPawnShroudAssassin;

// alays cloaked
//
function CloakControl( SinglePlayer.AssassinCloakMode mode )
{
	Super.CloakControl( ACM_CloakingOn );
}


function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
    Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage );
    Health=default.Health;
}

defaultproperties
{
     AIRoleClass=Class'PariahSP.SPAIRole'
     Health=10000
     ControllerClass=Class'PariahSP.SPAIController'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem139
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem139'
     Skins(0)=Shader'PariahCharacterTextures.ShroudAssasin.assasom_body_shader'
     Skins(1)=Texture'PariahCharacterTextures.ShroudAssasin.shroudassasin_head'
     bAffectedByEnhancedVision=0
}
