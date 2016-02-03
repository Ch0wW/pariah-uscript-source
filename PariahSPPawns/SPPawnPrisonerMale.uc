class SPPawnPrisonerMale extends SPPawn;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

defaultproperties
{
     AIRoleClass=Class'PariahSPPawns.SPAIRolePrisoner'
     ExclamationClass=Class'PariahSPPawns.SPScavengerExclaim'
     bMayFallDown=True
     Health=50
     MovementAnims(0)="RunF_NoWeapon"
     IdleWeaponAnim="Healing_Tool_Ready"
     ControllerClass=Class'PariahSPPawns.SPAIPrisoner'
     race=R_Prisoner
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.MalePrisoner_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem132
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem132'
}
