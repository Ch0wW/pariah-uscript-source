class SPPawnScavengerLight extends SPPawnScavenger;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

defaultproperties
{
     AIRoleClass=Class'PariahSPPawns.SPAIRoleScavenger'
     ExclamationClass=Class'PariahSPPawns.SPScavengerExclaim'
     ControllerClass=Class'PariahSPPawns.SPAIAssaultRifle'
     race=R_Clan
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.RebelPrisoner_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem135
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem135'
     bAffectedByEnhancedVision=27
}
