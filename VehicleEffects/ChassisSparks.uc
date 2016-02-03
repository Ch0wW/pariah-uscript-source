class ChassisSparks extends Emitter;


function Destroyed()
{
	Super.Destroyed();
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter363
         UseDirectionAs=PTDU_Up
         MaxParticles=300
         FadeOutStartTime=0.900000
         ColorScale(0)=(Color=(B=6,G=209,R=225))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=65,G=120,R=250))
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=6.000000)
         Acceleration=(Z=-950.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=1.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Max=200.000000))
         DrawStyle=PTDS_Brighten
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
     End Object
     Emitters(0)=SpriteEmitter'VehicleEffects.SpriteEmitter363'
     AutoDestroy=True
     AutoReset=True
     Physics=PHYS_Trailer
     bNoDelete=False
     bTrailerSameRotation=True
}
