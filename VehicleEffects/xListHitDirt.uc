class xListHitDirt extends xEmitterList;

#exec OBJ LOAD FILE=..\Sounds\NewBulletImpactSounds.uax

defaultproperties
{
     SoundEffect=SoundGroup'NewBulletImpactSounds.Final.sand'
     xEmitterClasses(0)=Class'VehicleEffects.DavidBulletFlash'
     xEmitterClasses(1)=Class'VehicleEffects.DavidBulletDirtHit'
}
