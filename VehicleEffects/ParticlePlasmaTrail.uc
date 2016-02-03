//=============================================================================
class ParticlePlasmaTrail extends xEmitter;

defaultproperties
{
     mLifeRange(0)=0.500000
     mLifeRange(1)=2.000000
     mRegenRange(0)=40.000000
     mRegenRange(1)=40.000000
     mSpeedRange(0)=50.000000
     mSpeedRange(1)=100.000000
     mColorRange(0)=(B=118,G=176,R=74)
     mColorRange(1)=(B=79,G=118,R=50)
     mSpawningType=ST_Explode
     Skins(0)=Texture'NoonTextures.Particles.particle_a'
     Physics=PHYS_Trailer
     Style=STY_Additive
}
