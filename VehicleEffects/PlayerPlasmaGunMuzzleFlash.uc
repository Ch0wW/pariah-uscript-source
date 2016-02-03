Class PlayerPlasmaGunMuzzleFlash extends AltMuzzleFlash;


//defaultproperties
//{
//    mLifeRange(0)=0.100000
//    mLifeRange(1)=0.150000
//    mSizeRange(0)=1.500000
//    mSizeRange(1)=2.000000
//    mGrowthRate=2.200000
//    mMeshNodes(0)=StaticMesh'PariahWeaponEffectsMeshes.PulseRifle.PulseRifleMuzzleMesh'
//    mSpawnVecB=(Z=0.000000)
//    Skins(0)=FinalBlend'PariahWeaponEffectsTextures.PulseRifle.PulseRifleMuzzleFB'
//    Style=STY_Additive
//}

defaultproperties
{
     numEmitters=2
     bOnceOnly=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitter325
         MaxParticles=2
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=-1.800000
         FadeInEndTime=2.000000
         InitialParticlesPerSecond=230.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.PulseRifle.plasma_muzzleb'
         SizeScale(0)=(RelativeTime=0.030000,RelativeSize=30.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=15.000000,Max=15.000000))
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSpinRange=(X=(Max=10.000000),Y=(Max=10.000000))
         StartSizeRange=(X=(Min=3.500000,Max=6.000000))
         LifetimeRange=(Min=0.050000,Max=0.100000)
         CoordinateSystem=PTCS_Relative
         RespawnDeadParticles=False
         AutoDestroy=True
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter325'
     Begin Object Class=MeshEmitter Name=MeshEmitter47
         StaticMesh=StaticMesh'PariahWeaponEffectsMeshes.PulseRifle.PulseRifleMuzzleMesh3rd'
         UseMeshBlendMode=False
         RenderTwoSided=True
         MaxParticles=1
         InitialParticlesPerSecond=20.000000
         SecondsBeforeInactive=0.000000
         AutoResetTimeRange=(Min=0.050000,Max=0.050000)
         StartSpinRange=(Z=(Max=50.000000))
         StartSizeRange=(X=(Min=1.600000,Max=2.200000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
         LifetimeRange=(Min=0.050000,Max=0.100000)
         CoordinateSystem=PTCS_Relative
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
         UniformSize=True
         AutomaticInitialSpawning=False
     End Object
     Emitters(1)=MeshEmitter'VehicleEffects.MeshEmitter47'
     DrawScale=0.200000
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
