class SPPawnShroudKeeperDrone extends SPPawn;

#exec OBJ LOAD FILE=..\Animations\PariahKeeperAnimations.ukx
#exec OBJ LOAD File="KeepersAndDrones.uax"

function SetMovementPhysics()
{
	SetPhysics(PHYS_Flying);
	
	Controller.bAdvancedTactics = false;
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Super.PlayDying(DamageType,HitLoc);
	AmbientSound=None;
}

defaultproperties
{
     ExclamationClass=Class'PariahSPPawns.SPKeeperExclaim'
     bMayMelee=False
     bDropNothingOnDeath=True
     SoundGroupClass=Class'VehicleGame.PariahSoundGroup'
     AirSpeed=1000.000000
     AccelRate=2000.000000
     BaseEyeHeight=0.000000
     ControllerClass=Class'PariahSPPawns.SPAIKeeperFlyPast'
     race=R_Shroud
     bCanFly=True
     bInvulnerableBody=True
     bPhysicsAnimUpdate=False
     CollisionRadius=75.000000
     CollisionHeight=40.000000
     Mass=80.000000
     Buoyancy=80.000000
     Mesh=SkeletalMesh'PariahKeeperAnimations.KeeperHover'
     AmbientSound=Sound'KeepersAndDrones.Keeper.KeeperAmbientA'
     Begin Object Class=HavokBlendedSkeletalSystem Name=HBSSKeeperFly
         GlobalVelocityGain=0.100000
         GlobalHierarchyGain=0.100000
         KeyframedBones(0)="Root"
         BlendType=HSB_GlobalGain
         SkeletonPhysicsFile="KeeperHoverRagdoll.xml"
     End Object
     HParams=HavokBlendedSkeletalSystem'PariahSPPawns.HBSSKeeperFly'
     Skins(0)=Shader'PariahCharacterTextures.KeeperHover.KeeperShader'
     DrawScale3D=(X=0.500000,Y=0.500000,Z=0.500000)
     RotationRate=(Pitch=16384,Roll=0)
}
