//=============================================================================
// MervRibbon
// Desc: A trace that follows mervs
//=============================================================================
class MervRibbon extends Emitter
	placeable;

defaultproperties
{
     Begin Object Class=RibbonEmitter Name=RibbonEmitter6
         NumPoints=100
         SampleRate=0.010000
         RibbonWidth=16.000000
         AlphaMaxTime=0.800000
         RibbonTextureUScale=0.010000
         RibbonTextureVScale=0.110000
         RibbonTextureVStart=0.100000
         GetPointAxisFrom=PAXIS_ActorAttach
         bAlphaFade=True
         bDecayPoints=False
         InitialParticlesPerSecond=100.000000
         Texture=Texture'KFTGradients.slanted_blur_01'
         ColorScale(0)=(Color=(B=255,G=255,R=255))
         ColorScale(1)=(Color=(B=255,G=255,R=255))
         FadeOutFactor=(W=0.010000,X=0.000000,Y=0.000000,Z=0.000000)
         LifetimeRange=(Min=2.000000,Max=3.000000)
         DrawStyle=PTDS_AlphaBlend
         RespawnDeadParticles=False
     End Object
     Emitters(0)=RibbonEmitter'VehicleGame.RibbonEmitter6'
     bNoDelete=False
}
