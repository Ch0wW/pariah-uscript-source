class StocktonShieldChargeGenerator extends Emitter
	placeable;

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter7
         RotatingSheets=3
         LowFrequencyPoints=15
         HighFrequencyPoints=5
         BeamTextureUScale=3.000000
         HFScaleRepeats=1.000000
         BeamEndPoints(0)=(ActorTag="SPPawnStockton",Weight=1.000000)
         LFScaleFactors(0)=(FrequencyScale=(X=1.000000,Y=1.000000,Z=1.000000))
         LFScaleFactors(1)=(FrequencyScale=(X=5.000000,Y=5.000000,Z=5.000000),RelativeLength=0.500000)
         LFScaleFactors(2)=(FrequencyScale=(X=1.000000,Y=1.000000,Z=1.000000),RelativeLength=1.000000)
         HFScaleFactors(0)=(FrequencyScale=(X=3.000000,Y=3.000000,Z=3.000000))
         HFScaleFactors(1)=(RelativeLength=0.500000)
         HFScaleFactors(2)=(FrequencyScale=(X=3.000000,Y=3.000000,Z=3.000000),RelativeLength=1.000000)
         LowFrequencyNoiseRange=(X=(Min=-2.000000,Max=2.000000),Y=(Min=-2.000000,Max=2.000000),Z=(Min=-5.000000,Max=2.000000))
         HighFrequencyNoiseRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         DynamicHFNoiseRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000),Z=(Min=-8.000000,Max=8.000000))
         DynamicHFNoisePointsRange=(Min=1.000000,Max=4.000000)
         DynamicTimeBetweenNoiseRange=(Min=0.050000,Max=0.300000)
         BranchProbability=(Min=1.000000,Max=1.000000)
         BranchHFPointsRange=(Max=2.000000)
         BranchSpawnAmountRange=(Min=1.000000,Max=1.000000)
         DetermineEndPointBy=PTEP_Actor
         MaxParticles=7
         FadeOutStartTime=0.100000
         FadeInEndTime=0.010000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.electric_1'
         ColorScale(0)=(Color=(B=185,G=255,R=255))
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=79,G=123,R=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         SizeScale(0)=(RelativeSize=1.000000)
         SizeScale(1)=(RelativeTime=0.700000,RelativeSize=2.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=7.000000)
         StartLocationRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         SphereRadiusRange=(Min=-25.000000,Max=25.000000)
         RevolutionCenterOffsetRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         RevolutionsPerSecondRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=70.000000,Max=70.000000))
         LifetimeRange=(Min=0.200000,Max=2.000000)
         StartLocationShape=PTLS_All
         UseRotationFrom=PTRS_Actor
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         AutoReset=True
         UseSizeScale=True
         UseRegularSizeScale=False
     End Object
     Emitters(0)=BeamEmitter'VehicleEffects.BeamEmitter7'
     LifeSpan=3.000000
     Tag="StocktonShieldChargeGenerator"
     bNoDelete=False
}
