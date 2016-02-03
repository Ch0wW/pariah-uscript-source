class SPPawnMason extends SPPawnNPC;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

defaultproperties
{
     CharID="Mason"
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.Mason_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem113
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem113'
     Skins(0)=Shader'PariahCharacterTextures.Mason.newmason_bodyshader'
     Skins(1)=Texture'PariahCharacterTextures.Mason.newmason_head'
     Skins(2)=Texture'PariahCharacterTextures.Mason.mason_eyecover'
}
