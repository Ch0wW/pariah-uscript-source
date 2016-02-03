class RailBeamEffect extends xEmitter;

var Vector HitNormal;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        HitNormal;
}

function AimAt(Vector hl, Vector hn)
{
    HitNormal = hn;
    mSpawnVecA = hl;
    if (Level.NetMode != NM_DedicatedServer)
        SpawnEffects();
}

simulated function PostNetBeginPlay()
{
    if (Role < ROLE_Authority)
        SpawnEffects();
}

simulated function SpawnEffects()
{
//    local Rotator HitRot;
//    local Vector EffectLoc;
//    local RailBeamWave Coil;
//	local xEmitter tempxEmitter;
    local VGWeaponAttachment Attachment;
//	local int i;
//	local rotator randRot;

    if (Instigator != None)
    {
        Attachment = VGPawn(Instigator).VGWeaponAttachment;
//        if ( Instigator.IsFirstPerson() && Instigator.Weapon != None )
//        {
//			SetLocation(
//            SetLocation(Instigator.Weapon.GetEffectStart());
			//SetBase(Instigator.Weapon);
//            tempxEmitter = Spawn(class'RailMuzzleFlash',,, Location);
			//tempxEmitter.SetBase(self);
//        }
//        else
//        {
            if (Attachment != None && (Level.TimeSeconds - Attachment.LastRenderTime) < 1)
                SetLocation(Attachment.GetMuzzleLocation());
            else
                SetLocation(Instigator.Location + Instigator.EyeHeight*Vect(0,0,1) + Normal(mSpawnVecA - Instigator.Location) * 25.0); 
			//SetBase(Attachment);
//            tempxEmitter = Spawn(class'RailMuzzleFlash',,, Location);
			//tempxEmitter.SetBase(self);

//        }
    }

/*    if ( EffectIsRelevant(EffectLoc,false) )
	{
		if (HitNormal != Vect(0,0,0))
		{
			HitRot = Rotator(HitNormal);
			EffectLoc = mSpawnVecA + HitNormal*2;
			//Spawn(class'ShockImpactFlare',,, EffectLoc, HitRot);
			Spawn(class'RailStar',,, EffectLoc, HitRot);
			Spawn(class'RailScorch',,, EffectLoc, HitRot);
			//Spawn(class'RailRing',,, EffectLoc+HitNormal*8, HitRot);
		}
	}

    if ( !Level.bDropDetail && Level.bHighDetailMode )
    {
		for(i=0;i<2;i++)
		{
			randRot = RotRand();
			Coil = Spawn(class'RailBeamWave',,, Location, randRot);
			//Coil.SetBase(self);
			if (Coil != None)
			{
				Coil.mSpawnVecA = mSpawnVecA;
			}
		}
    }*/
}

defaultproperties
{
     mMaxParticles=2
     mNumTileColumns=2
     mNumTileRows=0
     mLifeRange(0)=1.500000
     mRegenDist=25.000000
     mSpinRange(0)=50000.000000
     mSpinRange(1)=12546.416992
     mSizeRange(0)=2.500000
     mSizeRange(1)=1.000000
     mAttenKa=0.100000
     mColorRange(0)=(B=180,G=180,R=180)
     mColorRange(1)=(B=180,G=180,R=180)
     mParticleType=PT_Beam
     mDistanceAtten=True
     mWaveLockEnd=True
     LifeSpan=1.500000
     Skins(0)=TexPanner'PariahEffectsTextures.LaserRail.LaserRail_beam_pan'
     RemoteRole=ROLE_SimulatedProxy
     Style=STY_Additive
     bReplicateInstigator=True
     bReplicateMovement=False
}
