Class ShipBurst extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter26
         MaxParticles=1
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         FadeOutStartTime=0.010000
         InitialParticlesPerSecond=2.000000
         Texture=Texture'JS_ForestTextures.Misc.WaveTexture'
         SizeScale(1)=(RelativeTime=0.300000,RelativeSize=20.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=80.000000)
         StartLocationRange=(Z=(Min=-10.000000,Max=10.000000))
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         LifetimeRange=(Min=0.300000,Max=0.300000)
         DrawStyle=PTDS_Brighten
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter26'
     PostEffectsType=PTFT_Distortion
     LifeSpan=5.000000
     DrawScale=5.000000
     CullDistance=2800.000000
     Tag="Emitter"
     bNoDelete=False
}
