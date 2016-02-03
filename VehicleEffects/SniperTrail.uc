Class SniperTrail extends ParticleHellfireStream;

var bool bFirstTick;
var float killTimer;

simulated function Tick(float dt)
{
	if(mNumActivePcl > 0 && bFirstTick) {
//		if(Role == ROLE_Authority)
			Velocity = Normal(vector(Rotation) )*100000;
		bFirstTick = false;
	}

	if(!bFirstTick)
		killTimer += dt;

//	bFirstTick = false;

	if(killTimer > 5.0) {
		mRegen = false;
//		log("stopping trail");
//		Destroy();
	}

	Super.Tick(dt);
}

simulated function Destroyed()
{
//	log("ARGH");
	Super.Destroyed();
}

defaultproperties
{
     bFirstTick=True
     mStartParticles=0
     mLifeRange(0)=0.450000
     mLifeRange(1)=0.450000
     mRegenRange(0)=35.000000
     mRegenRange(1)=35.000000
     mSpeedRange(0)=2.000000
     mSpeedRange(1)=2.000000
     mAirResistance=0.500000
     mSpinRange(0)=20000.000000
     mSpinRange(1)=20000.000000
     mSizeRange(0)=50.000000
     mSizeRange(1)=50.000000
     mGrowthRate=60.000000
     mColElasticity=0.400000
     mColorRange(0)=(B=138,G=138,R=0)
     mColorRange(1)=(B=138,G=138,R=0)
     bSuspendWhenNotVisible=False
     DrawScale=0.500000
     Texture=None
     Tag="ParticleHellfireStream"
     Skins(0)=Texture'PariahWeaponEffectsTextures.sniper.sniper_tracer'
     Physics=PHYS_Projectile
     RemoteRole=ROLE_SimulatedProxy
     bNetInitialRotation=True
     bCollideActors=True
     bCollideWorld=True
}
