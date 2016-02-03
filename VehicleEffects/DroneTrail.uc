class DroneTrail extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter429
         MaxParticles=20
         TextureUSubdivisions=2
         TextureVSubdivisions=2
         ParticlesPerSecond=5.000000
         Texture=Texture'PariahVehicleEffectsTextures.Tire.TireDust'
         ColorScale(0)=(Color=(B=67,G=77,R=80,A=255))
         ColorScale(1)=(RelativeTime=0.500000,Color=(B=131,G=145,R=150,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=122,G=125,R=126))
         SizeScale(0)=(RelativeSize=0.700000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=2.000000)
         LifetimeRange=(Min=0.500000,Max=0.500000)
         DrawStyle=PTDS_AlphaBlend
         UseColorScale=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         UseRandomSubdivision=True
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter429'
     AutoDestroy=True
     Physics=PHYS_Trailer
     bNoDelete=False
     bUnlit=False
}
