Class bulldog_muzzleflash_3rd extends AltMuzzleFlash;


//defaultproperties
//{
//    Begin Object Class=SpriteEmitter Name=SpriteEmitter65
//        MaxParticles=2
//        TextureUSubdivisions=1
//        TextureVSubdivisions=1
//        FadeOutStartTime=-1.800000
//        FadeInEndTime=2.000000
//        InitialParticlesPerSecond=230.000000
//        SecondsBeforeInactive=0.000000
//        Texture=Texture'PariahWeaponEffectsTextures.Bulldog.circle_flash'
//        SizeScale(0)=(RelativeTime=0.050000,RelativeSize=15.000000)
//        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
//        FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
//        SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
//        StartSpinRange=(X=(Max=10.000000),Y=(Max=10.000000))
//        StartSizeRange=(X=(Min=2.500000,Max=3.500000))
//        LifetimeRange=(Min=0.100000,Max=0.100000)
//        DrawStyle=PTDS_Brighten
//        RespawnDeadParticles=False
//        SpinParticles=True
//        UseSizeScale=True
//        UseRegularSizeScale=False
//        UniformSize=True
//        AutomaticInitialSpawning=False
//        UseRandomSubdivision=True
//		ResetOnTrigger=true
//        CoordinateSystem=PTCS_Relative
//        Name="SpriteEmitter65"
//    End Object
//    Emitters(0)=SpriteEmitter'SpriteEmitter65'
//    Begin Object Class=MeshEmitter Name=MeshEmitter2
//        StaticMesh=StaticMesh'PariahWeaponEffectsMeshes.Puncher.bulldog_muzzle_flash'
//        UseMeshBlendMode=false
//        RenderTwoSided=True
//        MaxParticles=1
//        SecondsBeforeInactive=0.000000
//        Texture=Texture'PariahWeaponEffectsTextures.Bulldog.bulldog_muzzle_1'
//        StartSpinRange=(Z=(Max=50.000000))
//        StartSizeRange=(X=(Min=0.500000),Y=(Min=0.800000,Max=0.800000),Z=(Min=0.800000,Max=0.800000))
//        LifetimeRange=(Min=0.100000,Max=0.100000)
//        RespawnDeadParticles=False
//        AutoDestroy=True
//        SpinParticles=True
//        UseSizeScale=True
//		ResetOnTrigger=true
//        CoordinateSystem=PTCS_Relative
//        Name="MeshEmitter2"
//    End Object
//    Emitters(1)=MeshEmitter'MeshEmitter2'
//    DrawScale=0.200000
//    Tag="Emitter"
//    bUnlit=False
//    bNoDelete=false
//}

defaultproperties
{
     numEmitters=2
     Begin Object Class=SpriteEmitter Name=SpriteEmitter310
         MaxParticles=1
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=-1.800000
         FadeInEndTime=2.000000
         InitialParticlesPerSecond=230.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.circle_flash'
         SizeScale(0)=(RelativeTime=0.030000,RelativeSize=30.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         FadeInFactor=(W=0.000000,X=0.000000,Y=0.000000,Z=0.000000)
         StartLocationRange=(X=(Min=15.000000,Max=15.000000))
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSpinRange=(X=(Max=10.000000),Y=(Max=10.000000))
         StartSizeRange=(X=(Min=3.500000,Max=5.000000))
         LifetimeRange=(Min=0.080000,Max=0.080000)
         CoordinateSystem=PTCS_Relative
         RespawnDeadParticles=False
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter310'
     Begin Object Class=MeshEmitter Name=MeshEmitter41
         StaticMesh=StaticMesh'PariahWeaponEffectsMeshes.Bulldog.bulldog_muzzle_flash'
         UseMeshBlendMode=False
         RenderTwoSided=True
         MaxParticles=4
         SecondsBeforeInactive=0.000000
         Texture=None
         StartSpinRange=(Z=(Max=50.000000))
         StartSizeRange=(X=(Max=1.300000))
         LifetimeRange=(Min=0.020000,Max=0.020000)
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_Brighten
         RespawnDeadParticles=False
         AutoDestroy=True
         AutoReset=True
         SpinParticles=True
         UseSizeScale=True
     End Object
     Emitters(1)=MeshEmitter'VehicleEffects.MeshEmitter41'
     DrawScale=0.200000
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
}
