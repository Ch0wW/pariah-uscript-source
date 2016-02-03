class PlayerPlasmaChainEffect extends Emitter
	placeable;

var Pawn ZapTarget;

simulated function Tick(float dt)
{
    if(ZapTarget != None)
    {
        SetChainEnd(ZapTarget.Location);
    }

    Super.Tick(dt);
}

simulated function SetChainEnd(Vector End)
{
    local Vector RelLoc;

    RelLoc = End - Location;

    BeamEmitter(Emitters[0]).BeamEndPoints[0].offset.X.Min = RelLoc.X;
    BeamEmitter(Emitters[0]).BeamEndPoints[0].offset.X.Max = RelLoc.X;
    BeamEmitter(Emitters[0]).BeamEndPoints[0].offset.Y.Min = RelLoc.Y;
    BeamEmitter(Emitters[0]).BeamEndPoints[0].offset.Y.Max = RelLoc.Y;
    BeamEmitter(Emitters[0]).BeamEndPoints[0].offset.Z.Min = RelLoc.Z;
    BeamEmitter(Emitters[0]).BeamEndPoints[0].offset.Z.Max = RelLoc.Z;
}

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter4
         RotatingSheets=1
         LowFrequencyPoints=10
         BeamTextureUScale=6.000000
         BeamEndPoints(0)=(ActorTag="Lightning",offset=(X=(Min=200.000000,Max=200.000000),Y=(Min=234.000000,Max=34.000000),Z=(Min=234.000000,Max=234.000000)))
         LFScaleFactors(0)=(FrequencyScale=(X=1.000000,Y=1.000000,Z=1.000000))
         LFScaleFactors(1)=(FrequencyScale=(X=2.000000,Y=2.000000,Z=2.000000),RelativeLength=1.000000)
         HFScaleFactors(0)=(FrequencyScale=(X=0.500000,Y=0.500000,Z=0.500000))
         HFScaleFactors(1)=(FrequencyScale=(X=2.000000,Y=2.000000,Z=2.000000),RelativeLength=1.000000)
         LowFrequencyNoiseRange=(Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         HighFrequencyNoiseRange=(Y=(Min=-12.000000,Max=12.000000),Z=(Min=-12.000000,Max=12.000000))
         DynamicHFNoiseRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-3.000000,Max=3.000000))
         DynamicHFNoisePointsRange=(Min=1.000000,Max=1.000000)
         DynamicTimeBetweenNoiseRange=(Min=1.000000,Max=1.000000)
         BranchProbability=(Max=1.000000)
         BranchHFPointsRange=(Max=1.000000)
         BranchSpawnAmountRange=(Max=50.000000)
         DetermineEndPointBy=PTEP_Offset
         UseBranching=True
         MaxParticles=9
         FadeInEndTime=0.100000
         Texture=Texture'PariahWeaponEffectsTextures.hit_effects.electric_1'
         ColorScale(0)=(Color=(B=255,G=253,R=244))
         ColorScale(1)=(RelativeTime=0.250000,Color=(B=255,G=183,R=34))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255))
         StartSizeRange=(X=(Min=10.000000,Max=20.000000))
         LifetimeRange=(Min=0.100000,Max=0.500000)
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         AutoDestroy=True
     End Object
     Emitters(0)=BeamEmitter'VehicleEffects.BeamEmitter4'
     LifeSpan=0.400000
     Physics=PHYS_Trailer
     bNoDelete=False
}
