class SPPawnShroudInfantry extends SPPawnShroud;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

defaultproperties
{
     AIRoleClass=Class'PariahSPPawns.SPAIRoleAggressive'
     disposition=D_Cautious
     Health=75
     ControllerClass=Class'PariahSPPawns.SPAIShroudPlasmaGun'
     race=R_Shroud
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.ShroudInfantry_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem141
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem141'
}
