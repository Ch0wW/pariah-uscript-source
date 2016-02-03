class DavidGeneratorLightning extends David
	placeable;

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter19
         RotatingSheets=1
         LowFrequencyPoints=10
         HighFrequencyPoints=5
         BranchEmitter=1
         HFScaleRepeats=3.000000
         BeamEndPoints(0)=(ActorTag="SPPawnStockton",Weight=1.000000)
         LFScaleFactors(1)=(FrequencyScale=(X=1.000000,Y=1.000000,Z=1.000000),RelativeLength=1.000000)
         HFScaleFactors(1)=(FrequencyScale=(X=5.000000,Y=5.000000,Z=5.000000),RelativeLength=1.000000)
         LowFrequencyNoiseRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         HighFrequencyNoiseRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         BranchProbability=(Max=1.000000)
         BranchHFPointsRange=(Max=1000.000000)
         BranchSpawnAmountRange=(Min=1.000000,Max=3.000000)
         DetermineEndPointBy=PTEP_Actor
         UseHighFrequencyScale=True
         UseLowFrequencyScale=True
         MaxParticles=40
         FadeOutStartTime=0.300000
         FadeInEndTime=0.100000
         ParticlesPerSecond=20.000000
         InitialParticlesPerSecond=10.000000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.electric_1'
         ColorScale(0)=(Color=(G=255,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=128,R=255))
         StartLocationRange=(X=(Min=-80.000000,Max=80.000000),Y=(Min=-20.000000,Max=-50.000000),Z=(Min=-200.000000,Max=275.000000))
         LifetimeRange=(Min=0.100000,Max=0.400000)
         StartLocationShape=PTLS_All
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
     End Object
     Emitters(0)=BeamEmitter'VehicleEffects.BeamEmitter19'
     Begin Object Class=BeamEmitter Name=BeamEmitter1
         RotatingSheets=1
         LowFrequencyPoints=10
         HighFrequencyPoints=5
         HFScaleRepeats=3.000000
         BeamEndPoints(0)=(ActorTag="KarinaPawn",Weight=1.000000)
         LFScaleFactors(1)=(FrequencyScale=(X=1.000000,Y=1.000000,Z=1.000000),RelativeLength=1.000000)
         HFScaleFactors(1)=(FrequencyScale=(X=5.000000,Y=5.000000,Z=5.000000),RelativeLength=1.000000)
         LowFrequencyNoiseRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000),Z=(Min=-5.000000,Max=5.000000))
         HighFrequencyNoiseRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         BranchProbability=(Max=1.000000)
         BranchHFPointsRange=(Max=1000.000000)
         BranchSpawnAmountRange=(Min=1.000000,Max=3.000000)
         DetermineEndPointBy=PTEP_Actor
         UseHighFrequencyScale=True
         UseLowFrequencyScale=True
         UseBranching=True
         MaxParticles=1
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.electric_1'
         LifetimeRange=(Min=0.050000,Max=0.100000)
         RespawnDeadParticles=False
     End Object
     Emitters(1)=BeamEmitter'VehicleEffects.BeamEmitter1'
     Tag="DavidGeneratorLightning"
     bNoDelete=False
}
