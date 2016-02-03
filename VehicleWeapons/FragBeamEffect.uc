class FragBeamEffect extends RailBeamEffect;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    PlaySound(Sound'PariahWeaponSounds.FragConcentrator',,2.0);
}

defaultproperties
{
     mStartParticles=4
     mMaxParticles=10
     mNumTileColumns=1
     mNumTileRows=1
     mLifeRange(0)=1.250000
     mRegenDist=150.000000
     mSizeRange(0)=8.000000
     mSizeRange(1)=8.000000
     mGrowthRate=30.000000
     LifeSpan=1.250000
     Skins(0)=Shader'PariahWeaponEffectsTextures.Bulldog.FBeamShader'
}
