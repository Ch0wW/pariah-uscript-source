Class FragRiffleMuzzleSmoke extends AltMuzzleFlash;

function StopFlash()
{

}

function StartFlash()
{

}

defaultproperties
{
     numEmitters=1
     bOnceOnly=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitter319
         MaxParticles=20
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         InitialParticlesPerSecond=230.000000
         Texture=Texture'PariahWeaponEffectsTextures.Bulldog.Muzzle_Smoke'
         SizeScale(0)=(RelativeTime=0.050000,RelativeSize=15.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(X=200.000000,Y=9.000000,Z=200.000000)
         StartLocationRange=(X=(Min=-30.000000,Max=50.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-6.000000))
         SpinsPerSecondRange=(X=(Min=0.200000,Max=0.400000))
         StartSizeRange=(X=(Min=2.000000,Max=2.500000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=900.000000,Max=1400.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-250.000000,Max=100.000000))
         VelocityLossRange=(X=(Min=10.000000,Max=20.000000),Y=(Max=4.000000),Z=(Min=2.000000,Max=15.000000))
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_Brighten
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter319'
     DrawScale=0.200000
     Tag="Emitter"
     bNoDelete=False
     bUnlit=False
     bDirectional=True
}
