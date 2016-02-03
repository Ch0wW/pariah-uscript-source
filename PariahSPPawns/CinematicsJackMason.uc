class CinematicsJackMason extends CinematicsPawn;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

defaultproperties
{
     MeshName="CinematicsCharacterAnimations.CinematicsJackMason"
     CharID="JackMason"
     AdditionalAnimationPkg(0)="PariahMaleAnimations_SP.MaleSkeleton"
     AdditionalAnimationPkg(1)="CinematicsCharacterAnimations.MaleAnimations"
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.Mason_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem111
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem111'
}
