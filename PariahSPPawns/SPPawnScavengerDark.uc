class SPPawnScavengerDark extends SPPawnScavenger;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

defaultproperties
{
     AIRoleClass=Class'PariahSPPawns.SPAIRoleScavenger'
     ExclamationClass=Class'PariahSPPawns.SPScavengerExclaim'
     ControllerClass=Class'PariahSPPawns.SPAIGrenadeLauncher'
     race=R_Clan
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.Scavenger_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem134
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem134'
}
