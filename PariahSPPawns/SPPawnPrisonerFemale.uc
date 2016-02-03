class SPPawnPrisonerFemale extends SPPawn;


#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahFemaleAnimations_SP.ukx

defaultproperties
{
     AIRoleClass=Class'PariahSPPawns.SPAIRolePrisoner'
     ExclamationClass=Class'PariahSPPawns.SPScavengerExclaim'
     bMayFallDown=True
     Health=50
     IdleWeaponAnim="Healing_Tool_Ready"
     ControllerClass=Class'PariahSPPawns.SPAIPrisoner'
     race=R_Prisoner
     Mesh=SkeletalMesh'PariahFemaleAnimations_SP.Prisoner_Female'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem131
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem131'
}
