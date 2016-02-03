class SPPawnShroudAssassinDeCloaked extends SPPawnShroudAssassin;

// always uncloaked
//
function CloakControl( SinglePlayer.AssassinCloakMode mode )
{
	Super.CloakControl( ACM_CloakingOff );
}

defaultproperties
{
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem140
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem140'
     Skins(0)=Shader'PariahCharacterTextures.ShroudAssasin.assasom_body_shader'
     Skins(1)=Texture'PariahCharacterTextures.ShroudAssasin.shroudassasin_head'
}
