Class bulldog_muzzleflash_1st extends DavidPuncherFlash;

var int mNumPerFlash;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
//    mStartParticles += mNumPerFlash;
}

simulated function StartFlash()
{
    mRegenRange[0]=15.000000;
    mRegenRange[1]=12.000000;
	mRegen = true;
}

simulated function StopFlash()
{
    mRegenRange[0]=0;
    mRegenRange[1]=0;
}

defaultproperties
{
     mNumPerFlash=2
     mStartParticles=0
     mRegenRange(0)=0.000000
     mRegenRange(1)=0.000000
     mMeshNodes(0)=StaticMesh'PariahWeaponEffectsMeshes.Bulldog.bulldog_muzzle_flash_1st'
     mSpawnVecB=(X=0.000000,Z=0.000000)
     mAttenFunc=ATF_Pulse
     mPosRelative=True
     DrawScale=0.600000
     Tag="DavidPuncherFlash"
     Skins(0)=FinalBlend'PariahWeaponEffectsTextures.Bulldog.bulldog_muzzle_fb'
}
