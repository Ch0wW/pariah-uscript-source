class xPawn extends UnrealPawn
	native
    dependsOn(xUtil)
    dependsOn(xPawnSoundGroup)
    dependsOn(xPawnGibGroup);

#exec OBJ LOAD FILE=GeneralAmbience.uax
#exec OBJ LOAD FILE=NewFootsteps.uax
#exec OBJ LOAD FILE=NewBulletImpactSounds.uax
#exec OBJ LOAD FILE=DC_MiscAmbience.uax
#exec OBJ LOAD FILE=PariahPlayerSounds.uax

var int RepeaterDeathCount;

var bool bBerserk;
var transient bool bSimInvis;

var(UDamage) bool Bleed;                             // Whether or not our pawn bleeds or not - mjm
var(UDamage) float RemainingUDamageMax;              // Maximum allowed remaining UDamage (in seconds)
var(UDamage) Material UDamageWeaponMaterial;         // Weapon overlay material
var float UDamageTime;
var float LastUDamageSoundTime;
var Material InvisMaterial;

var(Shield) float   ShieldChargeMax;                 // max strength
var(Shield) transient float ShieldCharge;            // current charge
var(Shield) float   ShieldChargeRate;                // amount to recharge per sec.

var(Shield) float   ShieldStrengthMax;               // max strength
var(Shield) float   ShieldConvertRate;               // speed at which charge is expended into strength
var(Shield) float   ShieldStrengthDecay;             // max strength

var(Shield) float	ShieldPenetration;				// % of damage applied to players health

var(Shield)	Material	ShieldMat;
var(Shield) Material    ShieldHitMat;
var(Shield) float       ShieldHitMatTime;

var xUtil.ESpecies Species;

var PlayerLight     LeftMarker;
var(Marker) Vector  LeftOffset;
var PlayerLight     RightMarker;
var(Marker) Vector  RightOffset;

var(Sounds) float GruntVolume; // gam
var(Sounds) sound InstantHitSound;  // mjm

var transient int   SimHitFxTicker;
var transient float CantPickupMessageTime;  // mjm - used to not show repeated can't pick up item msg

var(Gib) class<xPawnGibGroup> GibGroupClass;
var(Gib) int GibCountCalf;
var(Gib) int GibCountForearm;
var(Gib) int GibCountHand;
var(Gib) int GibCountHead;
var(Gib) int GibCountTorso;
var(Gib) int GibCountUpperArm;

var float MinTimeBetweenPainSounds;
var localized string HeadShotMessage;

// Common sounds
var(Sounds) class<xPawnSoundGroup> SoundGroupClass;

var(Footsteps) Sound		SoundFootsteps[30];		    // Indexed by ESurfaceTypes (sorry about the literal).
var(Footsteps) class<Actor> EffectFootsteps[30];
var(Footsteps) float        FootstepVolume;			    // used for player footstep sounds
var(Footsteps) float        NotifyFootstepVolume;	    // used for footstep sounds played as a result of anim notify

var class<Actor>    TeleportFXClass;

// weapon affinity
var(WepAffinity) xUtil.WepAffinityData WepAffinity;
var bool bUsingSpeciesStats;

var ShadowProjector PlayerShadow;

var(Jump) int  MultiJumpRemaining;
var(Jump) int  MaxMultiJump;
var(Jump) int  MultiJumpBoost; // depends on the tolerance (100)
var(Jump) Sound		SoundSurfaceJumps[30];              // mjm - Indexed by ESurfaceTypes (sorry about the literal).

var config bool bBlobShadow;

var(anim) name CharTauntAnim;
var(anim) name CharIdleAnim;
var(anim) name WallDodgeAnims[4];
var(anim) name IdleHeavyAnim;
var(anim) name IdleRifleAnim;
var(anim) name FireHeavyRapidAnim;
var(anim) name FireHeavyBurstAnim;
var(anim) name FireRifleRapidAnim;
var(anim) name FireRifleBurstAnim;

//cmr new weapon anims
var(anim) name HealingToolFireAnim;
var(anim) name FragRifleFireAnim;
var(anim) name GrenadeLauncherFireAnim;
var(anim) name PlasmaGunFireAnim;
var(anim) name TitansFistFireAnim;
var(anim) name RocketLauncherFireAnim;
var(anim) name BulldogFireAnim;
var(anim) name BoneSawFireAnim;
var(anim) name SniperFireAnim;

var(anim) name HealingToolIdleAnim;
var(anim) name FragRifleIdleAnim;
var(anim) name GrenadeLauncherIdleAnim;
var(anim) name PlasmaGunIdleAnim;
var(anim) name TitansFistIdleAnim;
var(anim) name RocketLauncherIdleAnim;
var(anim) name BulldogIdleAnim;
var(anim) name BoneSawIdleAnim;
var(anim) name SniperIdleAnim;


var name FireRootBone;
var bool bBlendFiring;
var bool bBlendStrafeFiring;
var float CharIdleTime;
var bool bUseHitAnimChannel;

var enum EFireAnimState
{
    FRS_None,
    FRS_PlayOnce,
    FRS_Looping,
    FRS_Ready
} FireState;

var() bool bMeasureJumps;
var Vector LiftoffLoc;
var float BestAltitude;
var float LiftoffTime;
var bool bBaseMeasurement;

var() float HeadShotRadius;

var float        RagdollLastSeenTime;

var(Havok) float RagDeathImpulseScale;	// scales imparted impulse on death
var(Havok) float RagDeathVelScale;		// scales imparted ragdoll velocity on death
var(Havok) float RagDeathAngVelScale;	// scales imparted ragdoll spin upon death

var(Havok) float RagAngVelScale;		// scales calcualted ragdoll spin when hit by splash damage
var(Havok) float RagUpKick;				// Amount of upwards kick ragdolls get when they get hit by splash damage
var(Havok) float RagInvMass;			// for converting impulse to velocity

var(Havok) float RagMaxLinVel;			// maximum linear velocity we will impart to ragdoll
var(Havok) float RagMaxAngVel;			// maximum angular velocity we will impart to ragdoll

// translocate effect
var Vector  TransEffectOrigin;
var int     TransEffectTicker;
var int     SimTransEffectTicker;
var class<Actor>    TransOutEffect;
var config bool bDelayPlayerLoading;

var bool bHackMoverIgnoreMe;

var bool bUseMarkers;

const SkeletalBlendingTimer = 0;

var config bool		SkeletalBlendingEnabled;
var config float	SkeletalBlendingHitVGainScale;
var config float	SkeletalBlendingHitHGainScale;
var config float	SkeletalBlendingRecoverVGainScale;
var config float	SkeletalBlendingRecoverHGainScale;
var config float	SkeletalBlendingRecoverDelay;
var config int		SkeletalBlendingFalloff;

// debugging UI
//
var config int		SkeletalBlendingUIHitGain;
var InterpCurve		SkeletalBlendingUIHitGainCurve;
var config int		SkeletalBlendingUIRecoverGain;
var InterpCurve		SkeletalBlendingUIRecoverGainCurve;
var config int		SkeletalBlendingUIRecoverRate;
var InterpCurve		SkeletalBlendingUIRecoverRateCurve;
var bool xPawnNoBlend;

var (Havok)     Sound       RagImpactSound;
var (Havok)     float       RagImpactThreshold;
var (Havok)     float       RagImpactSoundVolScale;

var transient bool		bPostLoadGameCalled;
var transient float     LastRagdollImpact;

var Material TeleportMat, TeleportMatRed;

replication
{
    unreliable if( bNetDirty && Role==ROLE_Authority )
		TransEffectOrigin, TransEffectTicker, bUsingSpeciesStats;

    reliable if( bNetOwner && (Role==ROLE_Authority) )
		MaxMultiJump, MultiJumpBoost;

    reliable if( Role==ROLE_Authority )
        ClientEnableUDamage;
}

function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	Super.DisplayDebug(Canvas,YL, YPos);

	Canvas.SetDrawColor(255,255,255);	
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

function DoTranslocateOut(Vector PrevLocation)
{
    TransEffectTicker++;
    TransEffectOrigin = PrevLocation;
}

simulated function Destroyed()
{
    local array<Actor> Attachments;
    local int i;
    local GameObject gameObj;

    if( Level.NetMode != NM_DedicatedServer )
    {
        if ( LeftMarker != None )
        {
            LeftMarker.Destroy();
            LeftMarker = None;
        }

        if ( RightMarker != None )
        {
            RightMarker.Destroy();
            RightMarker = None;
        }
    }

    Super.Destroyed();

    Attachments = Attached;
    for( i = 0; i < Attachments.length; i++ )
    {
        if (Attachments[i] != None)
        {
            gameObj = GameObject(Attachments[i]);
            if (gameObj != None)
                gameObj.Drop(vect(0,0,0));
            else
                Attachments[i].Destroy();
        }
    }

    if( PlayerShadow != None )
        PlayerShadow.Destroy();
}

simulated function RemoveFlamingEffects()
{
    local int i;

    if( Level.NetMode == NM_DedicatedServer )
        return;

    for( i=0; i<Attached.length; i++ )
    {
        if( Attached[i].IsA('xEmitter') && !Attached[i].IsA('BloodJet'))
        {
            xEmitter(Attached[i]).mRegen = false;
        }
    }
}

simulated event PhysicsVolumeChange( PhysicsVolume NewVolume )
{
    if ( NewVolume.bWaterVolume )
        RemoveFlamingEffects();
    Super.PhysicsVolumeChange(NewVolume);
}

/* return a value (typically 0 to 1) adjusting pawn's perceived strength if under some special influence (like berserk)
*/
function float AdjustedStrength()
{
	if ( bBerserk )
		return 1.0;
	return 0;
}

function PlayTeleportEffect( bool bOut, bool bSound)
{
    if ( PlayerReplicationInfo == None || 
         PlayerReplicationInfo.Team == None )
    {
        SetOverlayMaterial( TeleportMatRed, true, 2.0, false );
    }
    else if ( PlayerReplicationInfo.Team.TeamIndex == 0 )
    {
        SetOverlayMaterial( TeleportMatRed, true, 2.0, false );
    }
    else
    {
        SetOverlayMaterial( TeleportMat, true, 2.0, false );
    }

    Spawn(TeleportFXClass,self,,Location,rot(16384,0,0));
    Super.PlayTeleportEffect( bOut, bSound );
}

function PlayMoverHitSound()
{
    if ( IsPlayerPawn() )
        PlaySound(GetSound(EST_Land), SLOT_Interact); 
    else
        PlaySound(GetHitSound(), SLOT_Interact); 
}   

function PlayDyingSound()
{
    // gam ---
    if ( HeadVolume.bWaterVolume )
    {
        PlayOwnedSound(GetSound(EST_Drown), SLOT_Pain);
        return;
    }

    PlaySound(GetDeathSound(), SLOT_Talk, 1.0);
    // --- gam
}

function Gasp()
{
    if ( Role != ROLE_Authority )
        return;
    if ( BreathTime < 2 )
        PlaySound(GetSound(EST_Gasp), SLOT_Talk); // gam
    else
        PlaySound(GetSound(EST_BreatheAgain), SLOT_Talk); // gam
}


simulated function TickFX(float DeltaTime)
{
    local int i;
    local float reduction;

    reduction = FClamp(deltatime*DamageDirReduction, 3.2f, 255.f);
    
    for(i=0; i<DamageDirMax; i++)
    {
		if ( DamageDirIntensity[i] != 0 )
			DamageDirIntensity[i] = Clamp(DamageDirIntensity[i] - int(reduction), 0, 255);
    }

    if ( SimHitFxTicker != HitFxTicker )
    {
        if( !bTearOff )
        {
            PlayDirectionalHit(Location + Vector(HitFX[SimHitFxTicker].rotDir) );
        }
        ProcessHitFX();
    }

    // do translocate-out effect
    if( TransEffectTicker != SimTransEffectTicker && Level.NetMode != NM_DedicatedServer )
    {
        SimTransEffectTicker = TransEffectTicker;
        Spawn(TransOutEffect,self,,TransEffectOrigin,rot(16384,0,0));
    }

    if( bInvis != bSimInvis )
    {
        bSimInvis = bInvis;
        if (bInvis)
        {
            if( PlayerShadow != None )
                PlayerShadow.bHiddenEd = true;
            if (LeftMarker != None)
                LeftMarker.bHidden = true;
            if (RightMarker != None)
                RightMarker.bHidden = true;
        }
        else
        {
            if( PlayerShadow != None )
                PlayerShadow.bHiddenEd = false;
            if (LeftMarker != None)
                LeftMarker.bHidden = false;
            if (RightMarker != None)
                RightMarker.bHidden = false;
        }
    }

    if( (PlayerReplicationInfo == None) || (PlayerReplicationInfo.Team == None) || (Level.NetMode == NM_DedicatedServer) )
        return;


	if(bUseMarkers)
	{
		if ( LeftMarker == None && !bInvis )
		{
			LeftMarker = Spawn(class'PlayerLight',self,,Location);
			if( !AttachToBone(LeftMarker,'lshoulder') )
			{
				log( "Couldn't attach LeftMarker to lshoulder", 'Error' );
				LeftMarker.Destroy();
				return;
			}

			RightMarker = Spawn(class'PlayerLight',self,,Location);
			if( !AttachToBone(RightMarker,'rshoulder') )
			{
				log( "Couldn't attach RightMarker to rshoulder", 'Error' );
				RightMarker.Destroy();
				return;
			}
		}

		LeftMarker.SetRelativeLocation(LeftOffset);
		RightMarker.SetRelativeLocation(RightOffset);

		if ( PlayerReplicationInfo.Team.TeamIndex == 0 )
		{
			//RightMarker.Texture = Texture'RedMarker_t';
			//LeftMarker.Texture = Texture'RedMarker_t';
		}
		else
		{
			//RightMarker.Texture = Texture'BlueMarker_t';
			//LeftMarker.Texture = Texture'BlueMarker_t';
		}
	}
}


simulated function AttachEffect( class<xEmitter> EmitterClass, Name BoneName, Vector Location, Rotator Rotation )
{
    local Actor a;
    local int i;

    if( BoneName == 'None' )
        return;

    for( i = 0; i < Attached.Length; i++ )
    {
        if( Attached[i] == None )
            continue;

        if( Attached[i].AttachmentBone != BoneName )
            continue;

        if( ClassIsChildOf( EmitterClass, Attached[i].Class ) )
            return;
    }

    a = Spawn( EmitterClass,,, Location, Rotation );

    if( !AttachToBone( a, BoneName ) )
    {
        log( "Couldn't attach "$EmitterClass$" to "$BoneName, 'Error' );
        a.Destroy();
        return;
    }

    for( i = 0; i < Attached.length; i++ )
    {
        if( Attached[i] == a )
            break;
    }

    a.SetRelativeRotation( Rotation );
}

simulated event SetHeadScale(float NewScale)
{
	HeadScale = NewScale;
    //log("SetHeadScale: "$NewScale);
	SetBoneScale(4,HeadScale,'head');
}

simulated function SpawnGiblet( class<Gib> GibClass, Vector Location, Rotator Rotation, float GibPerterbation )
{
    local Gib Giblet;
    local Vector Direction, Dummy;

    return;
	
	if( GibClass == None )
        return;

    if ( class'GameInfo'.default.bGreenGore || class'GameInfo'.default.GoreLevel > 0 )
        return;
	
	Instigator = self;
    Giblet = Spawn( GibClass,,, Location, Rotation );

    if( Giblet == None )
        return;

    Giblet.SetDrawScale( Giblet.DrawScale * GetGibScale() );

    GibPerterbation *= 32768.0;

    Rotation.Pitch += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Yaw += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;
    Rotation.Roll += ( FRand() * 2.0 * GibPerterbation ) - GibPerterbation;

    GetAxes( Rotation, Dummy, Dummy, Direction );

    Giblet.Velocity = Velocity + Normal(Direction) * (200+350*FRand());

	/*
    if (  (Level.NetMode != NM_DedicatedServer) && Level.bHighDetailMode && !Level.bDropDetail )//&& (LifeSpan < 19.3) )
	    PlaySound(class'Gib'.default.HitSounds[Rand(4)], SLOT_Pain);
	*/
}

simulated function ProcessHitFX()
{
    local Coords boneCoords;
    local class<xEmitter> HitEffects[4];
    local int i;

   	if( Level.NetMode == NM_DedicatedServer )
        return;

    for ( SimHitFxTicker = SimHitFxTicker; SimHitFxTicker != HitFxTicker; SimHitFxTicker = (SimHitFxTicker + 1) % ArrayCount(HitFX) )
    {
        if( HitFX[SimHitFxTicker].damtype == None )
            continue;

        if( class'GameInfo'.default.GoreLevel > 0 )
            continue;

        boneCoords = GetBoneCoords( HitFX[SimHitFxTicker].bone );

		if( GibGroupClass.default.BloodHitClass != None )
        {
			/*
            if( class'GameInfo'.default.GoreLevel > 0 )
    			Spawn( class'xEffects.HitPow',,, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );
            else*/
			if ( class'GameInfo'.default.bGreenGore )
				Spawn( GibGroupClass.default.LowGoreBloodHitClass,,, boneCoords.Origin+VRand()*10.0, HitFX[SimHitFxTicker].rotDir );
            else
				Spawn( GibGroupClass.default.BloodHitClass,,, boneCoords.Origin+VRand()*10.0, HitFX[SimHitFxTicker].rotDir );
        }

		HitFX[SimHitFxTicker].damtype.static.GetHitEffects( HitEffects, Health );

		SomeBlood( boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );

        if( !PhysicsVolume.bWaterVolume ) // don't attach effects under water
        {
            for( i = 0; i < ArrayCount(HitEffects); i++ )
            {
                if( HitEffects[i] == None )
                    continue;

                AttachEffect( HitEffects[i], HitFX[SimHitFxTicker].bone, boneCoords.Origin, HitFX[SimHitFxTicker].rotDir );
            }
        }
    }
}


//Manny will replace that with one single emitter but for now...
simulated function SomeBlood( Vector Loc, Rotator BoneRot )
{
    Spawn(class'BloodSpray',,, Loc, BoneRot);
}

function CalcHitLoc( Vector hitLoc, Vector hitRay, out Name boneName, out float dist )
{
    boneName = GetClosestBone( hitLoc, hitRay, dist );
}

function DoDamageFX( Name boneName, int Damage, class<DamageType> DamageType, Rotator r )
{
    local float DismemberProbabilty;
    local int boneScaleSlot;
    local bool KillingBlow;

    KillingBlow = (Health<=0 && Health+Damage >= 0 );

    //log("KillingBlow: "$KillingBlow);

    Damage *= DamageType.Default.GibModifier;

    if ( FRand() > 0.3f || Damage > 30 || Health <= 0 )
    {
        HitFX[HitFxTicker].damtype = DamageType;

        if( Health <= 0 )
        {
            switch( boneName )
            {
                case 'lfoot':
                    boneName = 'lthigh';
                    break;

                case 'rfoot':
                    boneName = 'rthigh';
                    break;

                case 'rhand':
                    boneName = 'rfarm';
                    break;

                case 'lhand':
                    boneName = 'lfarm';
                    break;

                case 'rshoulder':
                case 'lshoulder':
                    boneName = 'spine';
                    break;
            }

            DismemberProbabilty = 0.25 + Abs( float(Health - Damage) / 200.0f );

            if( DamageType.default.bAlwaysSevers )
                HitFX[HitFxTicker].bSever = true;
            else
            {
                switch( boneName )
                {
                    case 'lthigh':
                    case 'rthigh':
                    case 'rfarm':
                    case 'lfarm':
                    case 'head':
                        if( FRand() < DismemberProbabilty )
                            HitFX[HitFxTicker].bSever = true;
                        break;

                    case 'spine':
                        if( FRand() < DismemberProbabilty * 0.5 )
                            HitFX[HitFxTicker].bSever = true;
                        break;

                    case 'None':
                        if( FRand() < DismemberProbabilty * 0.3 )
                            HitFX[HitFxTicker].bSever = true;
                        break;
                }
            }
        }
        
        if( (DamageType.Name != 'DamTypeSniperHeadShot') && KillingBlow && Damage>16 && Frand()>0.8 ) // total gib prob
        {
            HitFX[HitFxTicker].bSever = true;
            boneName = 'None';
        }

        if ( class'GameInfo'.default.bGreenGore || class'GameInfo'.default.GoreLevel > 0 )
            HitFX[HitFxTicker].bSever = false;

        // scalars are now slot-based
        if( boneName == 'lthigh' )
            boneScaleSlot = 0;
        else if ( boneName == 'rthigh' )
            boneScaleSlot = 1;
        else if( boneName == 'rfarm' )
            boneScaleSlot = 2;
        else if ( boneName == 'lfarm' )
            boneScaleSlot = 3;
        else if ( boneName == 'head' )
            boneScaleSlot = 4;
        else if ( boneName == 'spine' )
            boneScaleSlot = 5;

        HitFX[HitFxTicker].bone = boneName;

        if( HitFX[HitFxTicker].bSever )
            SetBoneScale(boneScaleSlot, 0.0, HitFX[SimHitFxTicker].bone);

        HitFX[HitFxTicker].rotDir = r;
        HitFxTicker++;
        if( HitFxTicker > ArrayCount(HitFX)-1 )
            HitFxTicker = 0;
    }
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	
	if ( bPostLoadGameCalled )
	{
		if ( bPlayedDeath )
		{
			// if we were just loaded from a save game and we are dead,
			// destroy ourselves so we don't end up with ragdolls embedded in
			// floors
			//
			`log( "RJ: destroying dead pawn after save game loaded" );
			Destroy();
			return;
		}
		bPostLoadGameCalled = false;
	}

	if( Level.NetMode != NM_DedicatedServer )
    {
        TickFX(DeltaTime);
    }

    // assume dead if bTearOff - for remote clients unfff unfff
    if ( bTearOff )
    {
        if ( !bPlayedDeath )
            PlayDying(HitDamageType, TakeHitLocation);
        return;
    }

    if (bMeasureJumps)
    {
        if (bBaseMeasurement && Physics == PHYS_Falling)
        {
            BestAltitude = Location.Z;
            LiftoffLoc = Location;
            LiftoffTime = Level.TimeSeconds;
            bBaseMeasurement = false;
        }
        if (Location.Z > BestAltitude) BestAltitude = Location.Z;
    }
}


simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
	if(!xPawnNoBlend)
		AnimBlendParams(1, 1.0, 0.2, 0.2, 'Bip01 Spine1');

	AddLightTag( 'CHARACTER' );
	if ( Level.bCharactersExclusivelyLit )
	{
		bMatchLightTags=True;
	}

    if(bActorShadows && bPlayerShadows && (UsingHighDetailShadows() || bBlobShadow) && (Level.NetMode != NM_DedicatedServer))
    {
        PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
        PlayerShadow.ShadowActor = self;
		PlayerShadow.LightDirection = Normal(vect(0.f,0.f,1.f));
        PlayerShadow.bBlobShadow = bBlobShadow;
		PlayerShadow.LightDistance = 800;
        PlayerShadow.MaxTraceDistance = 600;
        PlayerShadow.InitShadow();
    }	

     if( IsMiniEd() ) 
     { 
          SetupPlayerRecord(class'xUtil'.static.FindPlayerRecord("DMPlayerA"), true); 
     } 
	
}

function int ShieldAbsorb( int damage )
{
	local int ShieldDamage, PlayerDamage;

	PlayerDamage = damage * ShieldPenetration;
	ShieldDamage = damage - PlayerDamage;
	
    if (ShieldStrength == 0)
    {
        return damage;
    }
    if (ShieldStrength > ShieldDamage)
    {
        ShieldStrength -= ShieldDamage;
        return PlayerDamage;
    }
    else
    {
        ShieldDamage -= ShieldStrength;
        ShieldStrength = 0;
		RemoveOverlayMaterial();
        return (ShieldDamage + PlayerDamage);
    }
}

function bool GiveHealth(int HealAmount, int HealMax)
{
    local bool bPickup;
    if (Weapon != None)
    {
        bPickup = Weapon.DistributeHealth(HealAmount, HealMax); // modifies HealAmount
    }
    return Super.GiveHealth(HealAmount, HealMax) || bPickup;
}

// called from debugging UI
simulated static function UpdateSkeletalBlendingParameters()
{
	local float f;

	f = InterpCurveEval( class'xPawn'.default.SkeletalBlendingUIHitGainCurve, class'xPawn'.default.SkeletalBlendingUIHitGain );
	class'xPawn'.default.SkeletalBlendingHitVGainScale = f;
	class'xPawn'.default.SkeletalBlendingHitHGainScale = f;
	f = InterpCurveEval( class'xPawn'.default.SkeletalBlendingUIRecoverGainCurve, class'xPawn'.default.SkeletalBlendingUIRecoverGain );
	class'xPawn'.default.SkeletalBlendingRecoverVGainScale = f;
	class'xPawn'.default.SkeletalBlendingRecoverHGainScale = f;
	f = InterpCurveEval( class'xPawn'.default.SkeletalBlendingUIRecoverRateCurve, class'xPawn'.default.SkeletalBlendingUIRecoverRate );
	class'xPawn'.default.SkeletalBlendingRecoverDelay = f;

	//log( "RJ: Updated HVG="$class'xPawn'.default.SkeletalBlendingHitVGainScale$",HHG="$class'xPawn'.default.SkeletalBlendingHitHGainScale$",Delay="$class'xPawn'.default.SkeletalBlendingRecoverDelay );
	//log( "RJ: Updated RVG="$class'xPawn'.default.SkeletalBlendingRecoverVGainScale$",RHG="$class'xPawn'.default.SkeletalBlendingRecoverHGainScale );
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector HitLocation, 
                        Vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
    local Vector HitNormal;
    local Vector HitRay;
    local Name HitBone;
    local float HitBoneDist;
    local PlayerController PC;
    local float r;
    local int severCount;
    local int actualDamage;
    local XPawn XInstigatedBy;
	local bool bShowEffects;
	local HavokBlendedSkeletalSystem hskel;
	local vector HavokImpulse;
	local int bDoHitEffectsAnyway;
	
	if (Weapon != None && DamageType != class'Fell')
        Weapon.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );

    XInstigatedBy = xPawn(InstigatedBy);

    if ( XInstigatedBy != None )
    {
        if (bBerserk && Damage > 1)
            Damage /= 2;

        if (XInstigatedBy.bBerserk)
            Damage *= 2;

        if (XInstigatedBy.HasUDamage())
            Damage *= 2;
    }

	if(DamageType == class'Fell') {
		// no reduction on falling damage
		actualDamage = Damage;
	}
	else {
		actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType,bDoHitEffectsAnyway);
	}

    if (actualDamage > 0 || bDoHitEffectsAnyway==1)
    {
        if(( InstigatedBy != None ) && ( InstigatedBy.Controller != None ) && InstigatedBy != self &&
            (InstigatedBy.Controller.PlayerReplicationInfo.Stats != None) )
            InstigatedBy.Controller.PlayerReplicationInfo.Stats.RegisterHit( DamageType );

        // Flash the screen
        PC = PlayerController(Controller);
        if (PC!=None)
        {
            if( PC.bEnableDamageForceFeedback )        // jdf
                PC.ServerPlayForceFeedback("Damage");  // jdf
        }

        HitRay = vect(0,0,0);
        if( InstigatedBy != None )
        {
            HitRay = Normal(HitLocation-(InstigatedBy.Location+(vect(0,0,1)*InstigatedBy.EyeHeight)));
        }

        if( DamageType.default.bLocationalHit )
		{
            // jim: Make a blood decal.
            if ( !bSplashDamage && Bleed && ( class'GameInfo'.default.GoreLevel <= 0 ) && self.IsA('SPPawnDrone'))
            {
                Level.BloodDecal( HitLocation, Normal(Momentum), 25.0f, self, class'ExplosionMark'.default.ProjTexture );
            }

            CalcHitLoc( HitLocation, HitRay, HitBone, HitBoneDist );
			
			if( !Level.bDropDetail && class'xPawn'.default.SkeletalBlendingEnabled && Level.NetMode == NM_Standalone && HitBone != 'None' && !IsFirstPerson() 
				&& damageType.static.GetHavokHitImpulse( momentum, HavokImpulse ) )
			{
				hskel = HavokBlendedSkeletalSystem(HParams);

				if( hskel != None )
				{
					if ( hskel.SkeletonPhysicsFile == "" )
					{
						hskel.SkeletonPhysicsFile = GetHavokSkeletonPhysicsFilename();
					}
					if ( class'xPawn'.default.SkeletalBlendingHitVGainScale == 0 )
					{
						// hasn't been initialized yet
						class'xPawn'.static.UpdateSkeletalBlendingParameters();
					}

					// scale gains around the hit bone
					hskel.BlendType = HSB_BoneScaleGain;
					hskel.BoneGainBones.Length = 1;
					hskel.BoneGainBones[0] = HitBone;
					hskel.GlobalVelocityGain = class'xPawn'.default.SkeletalBlendingHitVGainScale;
					hskel.GlobalHierarchyGain = class'xPawn'.default.SkeletalBlendingHitHGainScale;
					hskel.BoneGainFalloff = class'xPawn'.default.SkeletalBlendingFalloff;
					HUpdateSkeleton();
					SetMultiTimer( SkeletalBlendingTimer, class'xPawn'.default.SkeletalBlendingRecoverDelay, False );
					//log( "RJ: GVG="$hskel.GlobalVelocityGain$",GHG="$hskel.GlobalHierarchyGain$",BGF="$hskel.BoneGainFalloff$",Delay="$class'xPawn'.default.SkeletalBlendingRecoverDelay );
					//log( "RJ: RVG="$class'xPawn'.default.SkeletalBlendingRecoverVGainScale$",RHG="$class'xPawn'.default.SkeletalBlendingRecoverHGainScale );

					if ( hskel.SkelState == HSSS_PoseUpdated )
					{
						// the skeleton is active so we can just call HAddImpulse
						//
						if ( bSplashDamage )
						{
							// if splash damage provide bone name because the weapon trace probably
							// didn't hit any rigid body
							//
							HAddImpulse( HavokImpulse, HitLocation, HitBone );
						}
						else
						{
							HAddImpulse( HavokImpulse, HitLocation );
						}
					}
					else
					{
						// skeleton isn't ready yet, so setup a deferred shot
						hskel.ShotBone = HitBone;
						hskel.ShotVec0 = HitLocation;
						hskel.ShotVec1 = HavokImpulse;
						hskel.ShotStrength = 1;
					}
				}
			}
		}
        else
        {
            HitLocation = Location;
            HitBone = 'None';
            HitBoneDist = 0.0f;
        }

        if( DamageType != None && DamageType.default.bAlwaysSevers== true && DamageType.default.bSpecial == true )
            HitBone = 'head';

		bShowEffects = ( (Level.NetMode != NM_Standalone) || (Level.TimeSeconds - LastRenderTime < 3) 
						|| ((InstigatedBy != None) && (PlayerController(InstigatedBy.Controller) != None)) 
						|| (PlayerController(Controller) != None) );

		if(actualDamage > 0)
		{
		if(DamageType != class'Fell')
			Damage = ShieldAbsorb( actualDamage );
        if ( bShoweffects && (Damage < actualDamage) )
			SetOverlayMaterial(ShieldHitMat,true,ShieldHitMatTime,true,true);
		}

        if(InstigatedBy == None)
        {
		    PlayTakeHit(Normal(HitLocation - Location), Damage, DamageType); // sound
        }
        else
        {
            PlayTakeHit(Normal(InstigatedBy.Location - Location), Damage, DamageType); // sound
        }
		LastPainTime = Level.TimeSeconds;

		if(actualDamage > 0)
		{
		    // XJ Bone names: 
		    if( !bSplashDamage)	// don't do locations for splash damage
		    {
			    if(HitBone == 'lfarm' || HitBone == 'rfarm' || HitBone == 'lthigh' || HitBone == 'rthigh'
				    || HitBone == 'lfoot' || HitBone == 'rfoot' || HitBone == 'FlagHand' || HitBone == 'righthand')
			    {
				    Damage *= 0.8;
			    }
			    else if(HitBone != 'head')
			    {
				    Damage *= 0.9;
			    }
		    }
			Super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage );
		}


		if ( bShowEffects && ( Damage > 0 || bDoHitEffectsAnyway==1 ) )
		{
			if( InstigatedBy != None )
				HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + (VRand() * 0.2) );
			else
				HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

			DoDamageFX( HitBone, Damage, DamageType, Rotator(HitNormal) );

			if( (Damage > 20) && (Health < -10) && FRand() < 0.3 && HitBone != 'Head') // megakill
			{
				while( severCount>0 )
				{
					//log("MegaKill!");
					r = FRand();
					if( r < 0.1 )
					{
						HitBone = 'head';
					}
					else if ( r < 0.2 )
					{
						HitBone = 'lthigh';
					}
					else if ( r < 0.4 )
					{
						HitBone = 'rthigh';
					}
					else if ( r < 0.6 )
					{
						HitBone = 'rfarm';
					}
					else if ( r < 0.8 )
					{
						HitBone = 'rfarm';
					}
					else
					{
						HitBone = 'none';
					}
					DoDamageFX( HitBone, 1000, DamageType, Rotator(HitNormal) );
					severCount--;
				}
			}

			if (DamageType != None && DamageType.default.DamageOverlayMaterial != None)
				SetOverlayMaterial( DamageType.default.DamageOverlayMaterial, true, DamageType.default.DamageOverlayTime, false );
		}
	}
	//XJ: don't move pawn unless there is a lot of momentum
    else if ( Momentum != Vect(0,0,0) )
    {
        if( VSize(Momentum) > 2000.0 )
        {
            if (Physics == PHYS_Walking)
                momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
            if( ( instigatedBy != None ) && ( instigatedBy == self ) )
                momentum *= 0.6;
            momentum = momentum/Mass;
            AddVelocity( momentum );
        }
    }
}

event MultiTimer( int id )
{
	local HavokBlendedSkeletalSystem	 hskel;

	if ( id == SkeletalBlendingTimer )
	{
		// update skeletal blending
		//
		if ( Physics != PHYS_HavokSkeleton )
		{
			hskel = HavokBlendedSkeletalSystem(HParams);

			if( hskel != None )
			{
				if ( hskel.bAllBonesKeyframed )
				{
					// if the skeleton is entirely keyframed, switch off blending
					//
					hskel.BlendType = HSB_None;
				}
				else
				{
					// globally scale gains
					hskel.BlendType = HSB_GlobalScaleGain;
					hskel.GlobalVelocityGain = class'xPawn'.default.SkeletalBlendingRecoverVGainScale;
					hskel.GlobalHierarchyGain = class'xPawn'.default.SkeletalBlendingRecoverHGainScale;

					// start timer again
					SetMultiTimer( SkeletalBlendingTimer, class'xPawn'.default.SkeletalBlendingRecoverDelay, False );
				}
				HUpdateSkeleton();
			}
		}
	}
	else
	{
		Super.MultiTimer( id );
	}
}

function bool CheckReflect( Vector HitLocation, out Vector RefNormal, int Damage )
{
    if (Weapon != None)
        return Weapon.CheckReflect( HitLocation, RefNormal, Damage );
    else
        return false;
}

function name GetWeaponBoneFor(Inventory I)
{
    if (I.IsA('HoverPlat'))
    {
        return 'spine'; //create a tag for: 'Bip01 Pelvis'
    }
    else
        return 'righthand';
}

event Landed(vector HitNormal)
{
    Super.Landed(HitNormal);
    MultiJumpRemaining = MaxMultiJump;
    
    if (Health > 0)
      PlayOwnedSound(SoundSurfaceJumps[GetSurfaceType()], SLOT_Interact, FMin(1,-0.3 * Velocity.Z/JumpZ));
}

// ----- animation ----- //

simulated function name GetAnimSequence()
{
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
    return anim;
}

simulated event SetAnimAction(name NewAction)
{
    AnimAction = NewAction;

	if(SnapAnimAction)
	{
		PlayAnim(AnimAction, 1.0, 0.0);
		AnimBlendParams(1, 0.0, 0.0, 0.0, FireRootBone);
	}
	else if (!bWaitForAnim)
    {
        if (Physics != PHYS_Walking) // jump move - perhaps not the best way to differentiate
        {
            if ( PlayAnim(AnimAction) )
                bWaitForAnim = true;
        }
        else if (bIsIdle && !bIsCrouched) // standing taunt
        {
            PlayAnim(AnimAction);
        }
        else if (bBlendFiring) // running taunt
        {
            if (FireState == FRS_None || FireState == FRS_Ready)
            {
                if(!xPawnNoBlend)
					AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);
                PlayAnim(NewAction,, 0.0, 1);
                FireState = FRS_Ready;
            }
        }
    }
}

simulated function StartFiring(bool bHeavy, bool bRapid, optional WeaponAttachment.EWeaponType type)
{
    local name FireAnim;

	//log("start firing got weapon type "$type);

    if (HasUDamage() && Level.TimeSeconds - LastUDamageSoundTime > 0.25)
    {
        LastUDamageSoundTime = Level.TimeSeconds;        
    }

    IdleTime = Level.TimeSeconds;

    //cmr -- this will never be true
	//if (!bBlendFiring && !bIsIdle)	
    //    return;

	if (!bBlendStrafeFiring && !bIsIdle && Get4WayDirection() >= 2)
    {
        FireState = FRS_None;
		if(!xPawnNoBlend)
		    AnimBlendParams(1, 0.0);
        return;
    }

    if (Physics == PHYS_Swimming)
        return;

	switch(type)
	{
	case EWT_HealingTool:
		FireAnim = HealingToolFireAnim;
		break;
	case EWT_FragRifle:
		FireAnim = FragRifleFireAnim;
		break;
	case EWT_GrenadeLauncher:
		FireAnim = GrenadeLauncherFireAnim;
		break;
	case EWT_PlasmaGun:
		FireAnim = PlasmaGunFireAnim;
		break;
	case EWT_TitansFist:
		FireAnim = TitansFistFireAnim;
		break;
	case EWT_RocketLauncher:
		FireAnim = RocketLauncherFireAnim;
		break;
	case EWT_Bulldog:
		FireAnim = BulldogFireAnim;
		break;
	case EWT_SniperRifle:
		FireAnim = SniperFireAnim;
		break;
	case EWT_BoneSaw:
		FireAnim = BoneSawFireAnim;
		break;
	case EWT_None:
		FireAnim='';
		break;
	default:
		if (bHeavy)
		{
			if (bRapid)
				FireAnim = FireHeavyRapidAnim;
			else
				FireAnim = FireHeavyBurstAnim;
		}
		else
		{
			if (bRapid)
				FireAnim = FireRifleRapidAnim;
			else
				FireAnim = FireRifleBurstAnim;
		}
	}

	//log("start firing with anim "$fireanim);

    if (bBlendFiring)
    {
        if (FireState == FRS_None)
            if(!xPawnNoBlend)
				AnimBlendParams(1, 1.0, 0.0, 0.2, FireRootBone);

        if (bRapid)
        {
            if (FireState != FRS_Looping)
            {
                LoopAnim(FireAnim,, 0.0, 1);
                FireState = FRS_Looping;
            }
        }
        else
        {
            PlayAnim(FireAnim,, 0.0, 1);
            FireState = FRS_PlayOnce;
        }
    }
    else
    {
        if (FireState != FRS_PlayOnce)
        {
            PlayAnim(FireAnim,, 0.0, 0);
            FireState = FRS_PlayOnce;
        }
    }
}

simulated function StopFiring()
{
    //log("stopfiring");

	if (bBlendFiring)
    {
        if (FireState == FRS_Looping)
        {
            FireState = FRS_PlayOnce;
        }
    }
    else
    {
        FireState = FRS_None;
    }
    IdleTime = Level.TimeSeconds;
}

//mh
//The movement channel will play FullBody.  
// **So IdleWeaponAnim when idling needs the legs to be still
// The weapon only plays upper body, so we can play an animation that would
// otherwise move the legs, and not worry about it.
// ** the shield guy does this so we only use one animation for holding the shield
// i.e. WalkFWithShield can be both the walkF and the weaponIdle, but NOT the movement idle
//
simulated function name GetIdleWeaponAnim()
{
    return IdleWeaponAnim;
}

simulated function AnimEnd(int Channel)
{
	if (Channel == 1)
    {
        if (FireState == FRS_Ready)
        {
			if(!xPawnNoBlend)
				AnimBlendParams(1, 0.0);
            FireState = FRS_None;
        }
        else if (FireState == FRS_PlayOnce)
        {
            PlayAnim(GetIdleWeaponAnim(),, 0.2, 1);
            FireState = FRS_Ready;
            
			IdleTime = Level.TimeSeconds;
        }
    }
	else if (bUseHitAnimChannel && Channel == 2)
	{
        AnimBlendToAlpha(2, 0, 0.2);
	}
    else
    {
        if (!bBlendFiring)
            FireState = FRS_None;

        if (bIsIdle && Level.TimeSeconds - IdleTime > 10 && CharIdleAnim != '')
        {
            if (Level.TimeSeconds > CharIdleTime)
            {
                CharIdleTime = Level.TimeSeconds + 10 + FRand()*6;
				//log("going to play my charidleanim from script"@CharIdleAnim);
				PlayAnim(CharIdleAnim,, 0.2);
            }
        }
    }
}

function PlayWeaponSwitch(Weapon NewWeapon)
{
    if ( Physics == PHYS_Walking )
    {
        if(!xPawnNoBlend)
			AnimBlendParams(1, 0.0);
        FireState = FRS_None;
        PlayAnim('Weapon_Switch');
        AnimAction = 'Weapon_Switch';
    }
}

function PlayVictoryAnimation()
{
    //SetAnimAction('gesture_cheer');
}

simulated final function RandSpin(float spinRate)
{
/*
    local Rotator r;

    
    r = rot(0,0,0);
    r.Yaw = 0;
    r.Pitch = -16384;
    //r.Roll = -16384;

    SetRotation(r);
    */
    
    DesiredRotation = RotRand(true);
    RotationRate.Yaw = spinRate * 2 *FRand() - spinRate;
    RotationRate.Pitch = spinRate * 2 *FRand() - spinRate;
    RotationRate.Roll = spinRate * 2 *FRand() - spinRate;   

    bFixedRotationDir = true;
    bRotateToDesired = false;
}

simulated function string GetHavokSkeletonPhysicsFilename()
{
	local string MeshName, SkelPhysicsFilename;

	MeshName = GetMeshName();
	
	// Have to check Female first, because it contains 'male'!
	if(InStr(MeshName, "_Male") >= 0)
		SkelPhysicsFilename = "MaleRagdoll.xml";
	else if(InStr(MeshName, "_Female") >=0)
		SkelPhysicsFilename = "FemaleRagdoll.xml";
	else if(InStr(GetMeshName(), "Keeper") >= 0)
	{
		SkelPhysicsFilename = "KeeperHoverRagdoll.xml";
	}
	else
	{
		SkelPhysicsFilename = "";
	}

	return SkelPhysicsFilename;
}

function InitializeRagdollDeathImpulse( class<DamageType> DamageType, vector HitLoc )
{
	local vector shotDir;
	local float maxDim, f;
	local HavokSkeletalSystem hskel;
	local vector HavokImpulse;

	if ( DamageType.static.GetHavokHitImpulse( TearOffMomentum, HavokImpulse ) )
	{
		f = VSize(HavokImpulse);
		shotDir = HavokImpulse / f;
		hskel = HavokSkeletalSystem(HParams);
		if ( bTearOffSplashDamage )
		{
			HavokImpulse.Z += RagUpKick * f;
			f *= RagInvMass;
			hskel.StartLinVel = RagDeathVelScale * f * Normal( HavokImpulse );
			hskel.StartAngVel = RagDeathAngVelScale * RagAngVelScale * f * VRand();
		}
		else
		{
			// Set up deferred shot-bone impulse
			maxDim = Max(CollisionRadius, CollisionHeight);

			hskel.ShotBone = '';
			hskel.ShotVec0 = HitLoc - (1 * shotDir);
			hskel.ShotVec1 = HitLoc + (2*maxDim*shotDir);
			hskel.ShotStrength = RagDeathImpulseScale * f;
		}
	}
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local string RagSkelName;
	local HavokSkeletalSystem hskel;
    local PlayerController PC;
	local float v;
	local bool avail;

    PC = PlayerController(Controller); // sjs
    if (PC!=None)
    {
        ///cmr -- hook to save properties that might be needed
		PC.PreDying(self);

		if( PC.bEnableDamageForceFeedback )
        {
            if( Health > -20 )
            {
                PC.ClientPlayForceFeedback("Death");
            }
            else
            {
                PC.ClientPlayForceFeedback("BigDeath");
            }
        }
    }

    bPlayedDeath = true;

    // gib!
    if ( (DamageType != None) && DamageType.default.bAlwaysGibs )
    {
        //ChunkUp( Rotation, DamageType.default.GibPerterbation );
    	SpawnGibs( Rotation, DamageType.default.GibPerterbation );
        Destroy();
        return;
    }

    bCanTeleport = false; // sjs - fix karma going crazy when corpses land on teleporters
    bReplicateMovement = false;
    bTearOff = true;

    HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;

    // stop shooting
    if(!xPawnNoBlend)
		AnimBlendParams(1, 0.0);
    FireState = FRS_None;

    PlayDyingSound();


	if ( Level.NetMode != NM_DedicatedServer && bRagdollCorpses && !Level.bNoHavok )
	{
		RagSkelName = GetHavokSkeletonPhysicsFilename();
		if( RagSkelName != "" )
		{
			HMakeRagdollAvailable();
		}

		avail = HIsRagdollAvailable();
		if( avail && RagSkelName != "" && HavokSkeletalSystem(HParams) != None )
		{
			hskel = HavokSkeletalSystem(HParams);

			hskel.SkeletonPhysicsFile=RagSkelName;

			InitializeRagdollDeathImpulse( DamageType, HitLoc );
			`log( "RJ: ragdoll: lv="$hskel.StartLinVel$",av="$hskel.StartAngVel$",shot:"$hskel.ShotStrength$","$hskel.ShotVec0$"->"$hskel.ShotVec1 );
			if ( RagMaxLinVel > 0 )
			{
				hskel.MaxLinVel = RagMaxLinVel;
			}
			if ( RagMaxAngVel > 0 )
			{
				v = VSize(hskel.StartAngVel);
				if ( v > RagMaxAngVel )
				{
					`log( "RJ: capped ragdoll ang velocity from"@v@"to"@RagMaxAngVel );
					hskel.StartAngVel *= (RagMaxAngVel / v);
				}
			}

			SetPhysics( PHYS_HavokSkeleton );
			if ( RagImpactThreshold > 0 && RagImpactSound != None )
			{
				hskel.ImpactThreshold = RagImpactThreshold;
			}

			if( class'GameInfo'.default.GoreLevel > 0 )
			{
				LifeSpan = 2.0;
			}
			else
			{
				LifeSpan = Level.RagdollLifeSpan;
			}
			Velocity += TearOffMomentum;
			GotoState('Dying');
			return;
		}
		else
		{
			if( !avail )
			{
				log( "did not ragdoll because HIsRagdollAvailable() returned false" );
			}
			else if ( RagSkelName == "" )
			{
				log( "did not ragdoll because there was no ragdoll skeleton name" );
			}
			else if ( HavokSkeletalSystem(HParams) == None )
			{
				log( "did not ragdoll because there was no HavokSkeletalSystem parameter" );
			}
		}
	}
	else
	{
		if ( Level.NetMode == NM_DedicatedServer )
		{
			log( "did not ragdoll because Level.NetMode == NM_DedicatedServer" );
		}
		else if ( !bRagdollCorpses )
		{
			log( "did not ragdoll because bRagdollCorpses is false" );
		}
		else if ( Level.bNoHavok )
		{
			log( "did not ragdoll because Level.bNoHavok is true" );
		}
	}
    GotoState('Dying');
	Velocity += TearOffMomentum;

    //local Vector X,Y,Z, Dir;

    BaseEyeHeight = Default.BaseEyeHeight;

    SetTwistLook(0, 0);
    SetInvisibility(0.0);

    // hoverplat death
    if ( AnimIsInGroup( 0, 'Hover') )
    {
        Velocity.Z = Default.JumpZ*0.5;
        LoopAnim('Death_Fly',, 0.2);
    }

    // repeater death
    else if ( DamageType!=None && DamageType.default.bFastInstantHit )
    {
        PlayAnim('Death_Spasm',, 0.2);
        RepeaterDeathCount = 0;
    }

    // death in mid-air
    else if( (Physics == PHYS_Falling) && (!ClassIsChildOf (DamageType, class'Engine.Fell') ) )
    {
        PlayMidAirDeath();
        
    }

    // normal death
    else
    {
        PlayDirectionalDeath(HitLoc);
    }

    SetPhysics(PHYS_Falling);

    if( class'GameInfo'.default.GoreLevel > 0 )
    {
        LifeSpan = 2.0;
    }
    else
        LifeSpan = Level.RagdollLifeSpan;
}

simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation, optional Pawn Killer, optional vector HitLocation)
{

	return;

    if( class'GameInfo'.default.GoreLevel > 0 )
	{
        return;
	}

    if( GibCountTorso+GibCountHead+GibCountForearm+GibCountUpperArm+GibCountHand > 4 )
    {
        if( GibGroupClass.default.BloodGibClass != None )
        {
            if ( class'GameInfo'.default.bGreenGore )
                Spawn( GibGroupClass.default.LowGoreBloodGibClass,,,Location );
            else
                Spawn( GibGroupClass.default.BloodGibClass,,,Location );
        }
    }

    SpawnGiblet( GetGibClass(EGT_Torso), Location, HitRotation, ChunkPerterbation );
    GibCountTorso--;

    while( GibCountTorso-- > 0 )
        SpawnGiblet( GetGibClass(EGT_Torso), Location, HitRotation, ChunkPerterbation );
    while( GibCountHead-- > 0 )
        SpawnGiblet( GetGibClass(EGT_Head), Location, HitRotation, ChunkPerterbation );
    while( GibCountForearm-- > 0 )
        SpawnGiblet( GetGibClass(EGT_UpperArm), Location, HitRotation, ChunkPerterbation );
    while( GibCountUpperArm-- > 0 )
        SpawnGiblet( GetGibClass(EGT_Forearm), Location, HitRotation, ChunkPerterbation );
    while( GibCountHand-- > 0 )
        SpawnGiblet( GetGibClass(EGT_Hand), Location, HitRotation, ChunkPerterbation );
}

simulated function PlayTakeHit(vector ToSource, int Damage, class<DamageType> DamageType)
{
    if ( Controller != None )
    {
        CalcDamageDir(ToSource, Damage);
    }

    if( DamageType.default.bInstantHit )
    {
        PlayOwnedSound(InstantHitSound, SLOT_Interact);
    }

    if( Damage <= 0 || Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
        return;

    LastPainSound = Level.TimeSeconds;

    if( HeadVolume.bWaterVolume )
    {
        if( DamageType.IsA('Drowned') )
            PlayOwnedSound( GetSound(EST_Drown), SLOT_Pain );
        else
            PlayOwnedSound( GetHitSound(), SLOT_Pain );
        return;
    }

    
    PlayOwnedSound(GetHitSound(), SLOT_Pain);
}

simulated function AlignRotator( Vector x, Vector y, Vector z, int major, out Rotator result )
{
    local vector tx, ty, tz;
    
    return; // disabled

    switch ( major )
    {
        case 0: // x
            ty = x cross z;
            tz = ty cross z;
            break;
        case 1: // y
            tx = y cross z;
            tz = tx cross y;
            break;
        case 2: // z
            tx = y cross z;
            ty = z cross tx;
            break;
    }

    /*
    if( x dot tx < 0.0 )
        tx *= -1.0;

    if( y dot ty < 0.0 )
        ty *= -1.0;

    if( z dot tz < 0.0 )
        tz *= -1.0;*/

    result = OrthoRotation(tx,ty,tz);
}

simulated function PlayLandingDeath(Vector HitLoc )
{
    local Vector X,Y,Z;
    local Name seq;
    local float xd, yd, zd;
    local Rotator rtmp;

    GetAxes(Rotation,X,Y,Z);
    HitLoc.Z = Location.Z;

    seq = 'Death_ImpactB';

    // find dominant axis with floor
    xd = X dot vect(0,0,1);
    yd = Y dot vect(0,0,1);
    zd = Z dot vect(0,0,1);

    rtmp = DesiredRotation;
    DesiredRotation = Rotation;

    if( Abs(xd) > Abs(yd) )
    {
        if( Abs(xd) > Abs(zd) ) // x
        {
            if( xd > 0.0 )
            {
                seq = 'Death_ImpactB';
                DesiredRotation.Pitch = 16384;
                DesiredRotation.Roll = 0;
                AlignRotator( vect(1,0,0), Y, Z, 0, DesiredRotation );
            }
            else
            {
                seq = 'Death_ImpactF';
                DesiredRotation.Pitch = 32768+16384;
                DesiredRotation.Roll = 0;
                AlignRotator( vect(-1,0,0), Y, Z, 0, DesiredRotation );
            }
        }
        else // z
        {
            if( zd > 0.0 )
            {
                seq = 'Death_Impact_Feet';
                DesiredRotation.Pitch = 0;
                DesiredRotation.Roll = 0;
                AlignRotator( X, Y, vect(0,0,1), 2, DesiredRotation );
            
            }
            else
            {
                seq = 'Death_Impact_Head';
                DesiredRotation.Pitch = 32768;
                DesiredRotation.Roll = 0;
                AlignRotator( X, Y, vect(0,0,-1), 2, DesiredRotation );
            }
        }
    }
    else if( Abs(yd) > Abs(zd) ) // y
    {
        if( yd > 0.0 )
        {
            seq = 'Death_ImpactL';
            DesiredRotation.Roll = -16384;
            DesiredRotation.Pitch = 0;
            AlignRotator( X, vect(0,1,0), Z, 1, DesiredRotation );
        }
        else
        {
            seq = 'Death_ImpactR';
            DesiredRotation.Roll = 16384;
            DesiredRotation.Pitch = 0;
            AlignRotator( X, vect(0,-1,0), Z, 1, DesiredRotation );
        }
    }
    else // z
    {
        if( zd > 0.0 )
        {
            seq = 'Death_Impact_Feet';
            DesiredRotation.Pitch = 0;
            DesiredRotation.Roll = 0;
            AlignRotator( X, Y, vect(0,0,1), 2, DesiredRotation );
        }
        else
        {
            seq = 'Death_Impact_Head';
            DesiredRotation.Pitch = 32768;
            DesiredRotation.Roll = 0;
            AlignRotator( X, Y, vect(0,0,-1), 2, DesiredRotation );
        }
    }

    //DesiredRotation = OrthoRotation(X,Y,Z);
    RotationRate = rot(400000,400000,400000);
    bRotateToDesired = true;
    bFixedRotationDir = false;
    SetPhysics(PHYS_Rotating);

    //log("xd:"$ xd $ " yd:"$ yd $ " zd:"$ zd );
    //log("PlayLandingDeath: "$seq);
    PlayAnim(seq,,0.2); // Death_Impact_Feet Death_Impact_Head Death_ImpactB Death_ImpactF Death_ImpactL Death_ImpactR
    if ( GetAnimSequence() != seq ) // temp fallback for missing anims
    {
        PlayDirectionalDeath(HitLoc);
        DesiredRotation = rtmp;
    }
}

simulated function PlayMidAirDeath()
{
    RandSpin(40000);
    LoopAnim('Death_Fly',, 0.2);
    //log("Playing death_fly loop!");
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;
    
    // random
    if ( VSize(Velocity) < 10.0 && VSize(Location - HitLoc) < 1.0 )
    {
        Dir = VRand();
    }
    // velocity based
    else if ( VSize(Velocity) > 0.0 )
    {
        Dir = Normal(Velocity*Vect(1,1,0));
    }
    // hit location based
    else
    {
        Dir = -Normal(Location - HitLoc);
    }

    if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
    {
        PlayAnim('DeathB',, 0.2);
    }
    else if ( Dir Dot X < -0.7 )
    {
        PlayAnim('DeathF',, 0.2);
    }
    else if ( Dir Dot Y > 0 )
    {
        PlayAnim('DeathL',, 0.2);
    }
    else
    {
        PlayAnim('DeathR',, 0.2);
    }
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    local float r;
    r = FRand();

	if(bUseHitAnimChannel)
	{
		AnimBlendParams(2, 1.0, 0.0, 0.2, FireRootBone);
		if ( r < 0.5 )
		{
			PlayAnim(HitAnims[0],, 0.1,2);
		}
		else
		{
			PlayAnim(HitAnims[1],, 0.1,2);
		}
	}
	//if (FireState == FRS_None || FireState == FRS_Ready)
 //   {
	//	PlayAnim(AnimAction,, 0.1, 1);
	//	FireState = FRS_Ready;
	//}


    /*local Vector X,Y,Z, Dir;

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;
    
    // random
    if ( VSize(Location - HitLoc) < 1.0 )
    {
        Dir = VRand();
    }
    // hit location based
    else
    {
        Dir = -Normal(Location - HitLoc);
    }

    if ( Dir Dot X > 0.7 )
    {
        PlayAnim('HitF',, 0.1);
    }
    else if ( Dir Dot X < -0.7 )
    {
        PlayAnim('HitB',, 0.1);
    }
    else if ( Dir Dot Y > 0 )
    {
        PlayAnim('HitR',, 0.1);
    }
    else
    {
        PlayAnim('HitL',, 0.1);
    }*/

    IdleTime = Level.TimeSeconds;
}

// rj ---
simulated function int GetSurfaceType()
{
    local int SurfaceType;
	local actor A;
	local material FloorMat;
	local vector HL,HN,Start,End;

    SurfaceType = 0;
    if ( PhysicsVolume.bWaterVolume )
        SurfaceType = 9; // Water

	if ( (Base!=None) && (!Base.IsA('LevelInfo')) && (Base.SurfaceType!=0) )
	{
		SurfaceType = Base.SurfaceType;
	}
	else
	{
		Start = Location - Vect(0,0,1)*CollisionHeight;
		End = Start - Vect(0,0,50);
		A = Trace(HL,HN,End,Start,false,,FloorMat);
		if (FloorMat !=None)
			SurfaceType = FloorMat.SurfaceType;
	}		

	return SurfaceType;
}

event FootStepNotify( out class<Actor> FootStepEffect )
{
    local int SurfaceType;
	local PlayerController PC;


	// cmr -- don't play anim footstep for viewport controller who is in first person
	if(Controller != None && Controller.IsA('PlayerController'))
	{
		PC = PlayerController(Controller);
		if(Viewport(PC.Player) != None && !PC.bBehindView)
		{
			return;
		}
	}
	// -- cmr


	SurfaceType = GetSurfaceType();
	PlayOwnedSound(SoundFootsteps[SurfaceType],SLOT_None, NotifyFootstepVolume );
	FootStepEffect = EffectFootsteps[SurfaceType];
}

simulated function FootStepping(int Side)
{
    local int SurfaceType;

	SurfaceType = GetSurfaceType();
	PlayOwnedSound(SoundFootsteps[SurfaceType],SLOT_None, FootstepVolume );
}
// --- rj

// ----- shield control ----- //
function float GetShieldStrengthMax()
{
    return ShieldStrengthMax;
}

function float GetShieldStrength()
{
    // could return max if it's active right now, which make it unable to be recharged while it's on...
    return ShieldStrength;
}

function bool AddShieldStrength(int ShieldAmount)
{
    local bool bPickup;
    if (Weapon != None)
    {
        bPickup = Weapon.DistributeShield(ShieldAmount, ShieldStrengthMax); // modifies ShieldAmount
    }
	if (ShieldStrength < ShieldStrengthMax)
	{
		ShieldStrength = Min(ShieldStrengthMax, ShieldStrength + ShieldAmount);
		SetOverlayMaterial(ShieldMat,false,0.0,false);
        bPickup = true;
	}
    return bPickup;
}


// ----- combos ----- //
function bool HasUDamage()
{
    return (UDamageTime > Level.TimeSeconds);
}

function float EnableUDamage(float amount)
{
    ClientEnableUDamage(amount);
    UDamageTime = Level.TimeSeconds + amount;
    SetWeaponOverlay(UDamageWeaponMaterial, amount, false);
    return UDamageTime - Level.TimeSeconds;
}

simulated function ClientEnableUDamage(float amount)
{
    UDamageTime = Level.TimeSeconds + amount;
}

function SetWeaponOverlay(Material mat, float time, bool override)
{
    if (Weapon != None)
    {
        Weapon.SetOverlayMaterial(mat, true, time, override);
        if (WeaponAttachment(Weapon.ThirdPersonActor) != None)
            WeaponAttachment(Weapon.ThirdPersonActor).SetOverlayMaterial(mat, true, time, override);
    }
}

function ChangedWeapon()
{
    if (Weapon != None && Role < ROLE_Authority)
    {
        if (bBerserk)
            Weapon.StartBerserk();
    }

    Super.ChangedWeapon();
}

function ServerChangedWeapon(Weapon OldWeapon, Weapon NewWeapon)
{
    if (HasUDamage() || bInvis)
        SetWeaponOverlay(None, 0.f, true);

    Super.ServerChangedWeapon(OldWeapon, NewWeapon);

    if (bInvis)
        SetWeaponOverlay(InvisMaterial, Weapon.OverlayTimer, true);
    else if (HasUDamage())
        SetWeaponOverlay(UDamageWeaponMaterial, UDamageTime - Level.TimeSeconds, false);

    if (bBerserk)
        Weapon.StartBerserk();
}

function SetInvisibility(float time)
{
    bInvis = (time > 0.0);
    if (bInvis)
    {
		Visibility = 1;
        SetWeaponOverlay(InvisMaterial, time, true);
        SetOverlayMaterial(InvisMaterial, true, 60.0, true);
    }
    else
    {
		Visibility = Default.Visibility;
        if (HasUDamage())
            SetWeaponOverlay(UDamageWeaponMaterial, UDamageTime - Level.TimeSeconds, true);
        else
            SetWeaponOverlay(None, 0.0, true);
        SetOverlayMaterial(None, true, 0.0, true);
    }
}

function FireEffect(bool alt)
{
}   

/* BotDodge()
returns appropriate vector for dodge in direction Dir (which should be normalized)
*/
function vector BotDodge(Vector Dir)
{
	local vector Vel;
	
	Vel = DodgeSpeedFactor*GroundSpeed*Dir;
	Vel.Z = DodgeSpeedZ;
	return Vel;
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
    local vector X,Y,Z;
    local float VelocityZ;
    //local PlayerController PC;

    // gam ---
    //PC = PlayerController(Controller);
    //if( PC != None && !PC.DodgingIsEnabled() )
    //    return( false );
    // --- gam

    if ( bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking) )
        return false;

    GetAxes(Rotation,X,Y,Z);

    VelocityZ = Velocity.Z;

    if (DoubleClickMove == DCLICK_Forward)
        Velocity = DodgeSpeedFactor*GroundSpeed*X + (Velocity Dot Y)*Y;
    else if (DoubleClickMove == DCLICK_Back)
        Velocity = -DodgeSpeedFactor*GroundSpeed*X + (Velocity Dot Y)*Y; 
    else if (DoubleClickMove == DCLICK_Left)
        Velocity = -DodgeSpeedFactor*GroundSpeed*Y + (Velocity Dot X)*X; 
    else if (DoubleClickMove == DCLICK_Right)
        Velocity = DodgeSpeedFactor*GroundSpeed*Y + (Velocity Dot X)*X; 
 
    Velocity.Z = VelocityZ + DodgeSpeedZ;
    CurrentDir = DoubleClickMove;
    SetPhysics(PHYS_Falling);
    PlayOwnedSound(GetSound(EST_Dodge), SLOT_Pain, GruntVolume);
	bJustDodged = true;

    return true;
}

function DoDoubleJump( bool bUpdating )
{
}

function bool CanDoubleJump()
{
    //log("CanDoubleJump");
	return false; //( (MultiJumpRemaining > 0) && (Physics == PHYS_Falling) );
}

function bool DoJump( bool bUpdating )
{
    if ( Super.DoJump(bUpdating) )
    {
		if ( !bUpdating )
			PlayOwnedSound(SoundSurfaceJumps[GetSurfaceType()], SLOT_Pain, GruntVolume,,80);
        return true;
    }
    return false;
}

//// amb ---
//simulated event PostNetReceive()
//{
//    //log(self$" PostNetReceive PlayerReplicationInfo.CharacterName="$PlayerReplicationInfo.CharacterName);
//
//	if ( PlayerReplicationInfo != None ) // && PlayerReplicationInfo.Team != None)
//    {
//		//log("SPR called by postnetreceive");
//		SetupPlayerRecord(class'xUtil'.static.FindPlayerRecord(PlayerReplicationInfo.CharacterName));
//		bNetNotify = false;
//    }
//}

simulated function bool ShouldDelayPlayerLoading(int recIndex)
{
    local xUtil.PlayerRecord rec;

    // refresh copy
    rec = class'xUtil'.static.GetPlayerRecord(recIndex);

    return (bDelayPlayerLoading && 
            rec.bLoaded == 0    && 
            Level.NetMode != NM_DedicatedServer);
}

simulated function SetupPlayerRecord(xUtil.PlayerRecord rec, optional bool bLoadNow)
{   
	local bool bMP;

	if (!bLoadNow && ShouldDelayPlayerLoading(rec.RecordIndex))
    {
        //log(self$" SETUP - delay setup: "$rec.DefaultName, 'LOADING');
        Level.AddDelayedPlayer(PlayerReplicationInfo);
        return;
    }

    /*
    if (bLoadNow)
        log(self$" SETUP - setup now! "$rec.DefaultName, 'LOADING');
    else
        log(self$" SETUP - really setup: "$rec.DefaultName, 'LOADING');*/
    //log("SetupPlayerRecord for:"@rec.DefaultName@rec.SkeletonMeshName@rec.BodySkinName@rec.FaceSkinName);
    rec = class'xUtil'.static.CheckLoadLimits(Level, rec.RecordIndex);
    //log("Memory remapped to:"@rec.SkeletonMeshName@rec.BodySkinName@rec.FaceSkinName);

	bMP = Level.NetMode != NM_Standalone || !Level.Game.bSinglePlayer;

	if(bMP) //dirty hack to disable MP skins for deathmatch
	{
		if(PlayerReplicationInfo.Team == None || PlayerReplicationInfo.Team.TeamIndex == 255) //DM
			bMP = false;

	}

    class'xUtil'.static.LoadPlayerRecordResources(rec.RecordIndex, bMP);

	//log("====== I'm setting up a playerrecord for "$self$" with PRI "$PlayerReplicationInfo$" with teamindex "$PlayerReplicationInfo.Team.TeamIndex);
	//log("====== and the bitchtits wants a "$rec.DefaultName$" with mesh "$rec.MeshName);

    Species = rec.Species;   
    
    // memory consuming aspects!
	LinkMesh(Mesh(CheckObject(Mesh, rec.MeshName)));
    ResetPhysicsBasedAnim();
	// CMRFIX

    Skins.length = Max(Skins.length, 2);
    if(!bMP || rec.BodySkinNameMP == "")
		SetSkin(0, Material(CheckObject(Skins[0], rec.BodySkinName)));
	else
		SetSkin(0, Material(CheckObject(Skins[0], rec.BodySkinNameMP)));
    if(!bMP || rec.FaceSkinNameMP == "")
		SetSkin(1, Material(CheckObject(Skins[1], rec.FaceSkinName)));
	else
		SetSkin(1, Material(CheckObject(Skins[1], rec.FaceSkinNameMP)));

    SoundGroupClass = class<xPawnSoundGroup>(CheckClass(SoundGroupClass, rec.SoundGroupClassName));
    GibGroupClass = class<xPawnGibGroup>(CheckClass(GibGroupClass, rec.GibGroupClassName));
	if ( rec.WepAffinity.WepString != "" )
	{
		rec.WepAffinity.WepClass = class<Weapon>(DynamicLoadObject(rec.WepAffinity.WepString, class'Class'));
	}
	else
	{
		rec.WepAffinity.WepClass = None;
	}
    if (rec.WepAffinity.WepClass != None)
        WepAffinity = rec.WepAffinity;

    if (rec.VoiceClassName != "")
        VoiceType = rec.VoiceClassName;

    if (PlayerReplicationInfo != None)
        PlayerReplicationInfo.VoiceType = class<VoicePack>(CheckClass(PlayerReplicationInfo.VoiceType, VoiceType));

    // bloody animators making our code all ugly
    if (rec.Species == SPECIES_Night)
    {
        CharTauntAnim = 'Gesture_Taunt03';
        CharIdleAnim = 'Idle_Character03';
    }
    else if (rec.Species == SPECIES_Egypt || InStr(rec.MeshName, "AlienFemale") >= 0 || InStr(rec.MeshName, "JuggFemale") >= 0)
    {
        CharTauntAnim = 'Gesture_Taunt02';
        CharIdleAnim = 'Idle_Character02';
    }
    else
    {
        CharTauntAnim = 'wave';
        CharIdleAnim = 'Idle_Breathe';
    }

    UpdatePrecacheMaterials();
}

simulated function ResetPhysicsBasedAnim()
{
    bIsIdle = false;
    bWaitForAnim = false;
}

simulated function UpdatePrecacheMaterials()
{
	local int len;
	local int sk;

	len = Skins.Length;
	for ( sk = 0; sk < len; sk++ )
	{
		Level.AddPrecacheMaterial( Skins[sk] );
	}
}

simulated function Object CheckObject(Object orig, string newName)
{
    local Object newObj;

    if (newName == "")
        return orig;

    newObj = DynamicLoadObject(newName, class'Object');

    if (newObj == None)
        return orig;

    return newObj;
}

simulated function class<Object> CheckClass(class<Object> origClass, string newClassName)
{
    local class<Object> newClass;

    if (newClassName == "")
        return origClass;

    newClass = class<Object>(DynamicLoadObject(newClassName, class'Class'));

    if (newClass == None)
        return origClass;

    return newClass;
}

function Sound GetSound(xPawnSoundGroup.ESoundType soundType)
{
    return SoundGroupClass.static.GetSound(soundType);
}

function Sound GetHitSound()
{
    return SoundGroupClass.static.GetHitSound();
}

function Sound GetDeathSound()
{
    return SoundGroupClass.static.GetDeathSound();
}

function class<Gib> GetGibClass(xPawnGibGroup.EGibType gibType)
{
    return GibGroupClass.static.GetGibClass(gibType);
}

function float GetGibScale()
{
    return GibGroupClass.default.GibScale;
}

simulated function bool IsControlled()
{
    return bHackMoverIgnoreMe || Super.IsControlled();
}
// --- amb

State Dying
{
    simulated function AnimEnd( int Channel )
    {
        if ( GetAnimSequence() == 'Death_Spasm' )  
            PlayDirectionalDeath(Location);
        else
        {
            ReduceCylinder();
            //Super.AnimEnd(Channel);
        }
    }

    // prone body should have low height, wider radius
    simulated function ReduceCylinder()
    {
        local float OldHeight, OldRadius;
        local vector OldLocation;
        local vector OldPrePivot;

        SetCollision(True,False,False);
        OldHeight = default.CollisionHeight;
        OldRadius = default.CollisionRadius;
        SetCollisionSize(1.5 * Default.CollisionRadius, CarcassCollisionHeight);
        OldPrePivot = PrePivot;
        PrePivot = vect(0,0,1) * (OldHeight - CarcassCollisionHeight); // FIXME - changing prepivot isn't safe w/ static meshes
        OldLocation = Location;
        if ( !SetLocation(OldLocation - PrePivot) )
        {
            SetCollisionSize(OldRadius, CollisionHeight);
            if ( !SetLocation(OldLocation - PrePivot) )
            {
                SetCollisionSize(CollisionRadius, OldHeight);
                SetCollision(false, false, false);
                PrePivot = vect(0,0,0);
                if ( !SetLocation(OldLocation) )
                    ChunkUp( Rotation, 1.0 ); // gam
            }
        }
        //PrePivot = vect(0,0,1) * (default.CollisionHeight - default.CarcassCollisionHeight);//PrePivot + vect(0,0,3);
    }

    function LandThump()
    {
        // animation notify - play sound if actually landed, and animation also shows it
        if ( Physics == PHYS_None)
        {
            bThumped = true;
            PlaySound(GetHitSound());
        }
    }

    simulated function Landed(vector HitNormal)
    {
        if ( GetAnimSequence() == 'Death_Fly' )  
        {
            PlayLandingDeath(Location);
        }

        Super.Landed(HitNormal);

        if ( Level.NetMode == NM_DedicatedServer )
            return;

        HitWall( HitNormal, None );
    }

    simulated function HitWall( Vector HitNormal, Actor Wall )
    {
        Velocity = 0.5 * ((Velocity dot HitNormal) * HitNormal*(-2.0) + Velocity);
    }

    simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
    {
        local Vector SelfToHit, SelfToInstigator, CrossPlaneNormal;
        local float W;
        local float YawDir;

        local Vector HitNormal;
        local Vector PushVel, AngVel;
        local Name HitBone;
        local float HitBoneDist;
        local int MaxCorpseYawRate;
		local float v;

        //log("DyingDamage"@InstigatedBy@damageType);
        if (InstigatedBy == None || damageType == None)
		{
			log("not taking damage");
			return;
		}

		if( bPlayedDeath && Physics==PHYS_HavokSkeleton  )
		{
			if ( HavokSkeletalSystem(HParams) != None && HavokSkeletalSystem(HParams).SkelState == HSSS_PoseUpdated && damageType.static.GetHavokHitImpulse( momentum, PushVel ) )
			{
				if ( bSplashDamage )
				{
					// 
					// reorient pushvel to give it more lift
					//
					W = VSize(PushVel);
					PushVel.Z += RagUpKick * W;
					W *= RagInvMass;
					PushVel = W * Normal(PushVel);
					AngVel = W * RagAngVelScale * VRand();
					`log( "RJ: ragdoll: lv="$PushVel$",av="$AngVel );

					// - limit angular velocity if necessary
					// - linear velocity is being limited by MaxLinVel in HavokSkeletalSystem
					//
					if ( RagMaxAngVel > 0 )
					{
						v = VSize(AngVel);
						if ( v > RagMaxAngVel )
						{
							`log( "RJ: capped ragdoll ang velocity from"@v@"to"@RagMaxAngVel );
							AngVel *= (RagMaxAngVel / v);
						}
					}
					HSetSkelVel( PushVel, AngVel );
				}
				else
				{
					HAddImpulse( PushVel, hitlocation );
				}
			}

            // jim: Make a blood decal.
            if (Bleed && DamageType.default.bLocationalHit && !bSplashDamage && ( class'GameInfo'.default.GoreLevel <= 0 ))
            {
                Level.BloodDecal( HitLocation, Normal(Momentum), 25.0f, self, class'ExplosionMark'.default.ProjTexture );
            }

			return;
		}
	    
        //if(( InstigatedBy != None ) && ( InstigatedBy.Controller != None ) )
        //    InstigatedBy.Controller.Stats.RegisterHit( DamageType );

        if ( DamageType.default.bFastInstantHit && GetAnimSequence() == 'Death_Spasm' && RepeaterDeathCount < 6)
        {
            PlayAnim('Death_Spasm',, 0.2);
            RepeaterDeathCount++;
        }
        else if (Damage > 0)
        {
            if (InstigatedBy != None && InstigatedBy.IsA('xPawn') && xPawn(InstigatedBy).bBerserk )
                Damage *= 2;

            // Figure out which direction to spin:

            if( InstigatedBy.Location != Location )
            {
                SelfToInstigator = InstigatedBy.Location - Location;
                SelfToHit = HitLocation - Location;

                CrossPlaneNormal = Normal( SelfToInstigator cross Vect(0,0,1) );
                W = CrossPlaneNormal dot Location;

                if( HitLocation dot CrossPlaneNormal < W )
                    YawDir = -1.0;
                else
                    YawDir = 1.0;
            }

            if( VSize(Momentum) < 10 )
            {
                Momentum = - Normal(SelfToInstigator) * Damage * 1000.0;
                Momentum.Z = Abs( Momentum.Z );
            }

            SetPhysics(PHYS_Falling);
            Momentum = Momentum / Mass;
            AddVelocity( Momentum ); 
            bBounce = true;

            RotationRate.Pitch = 0;
            RotationRate.Yaw += VSize(Momentum) * YawDir;

            MaxCorpseYawRate = 150000;
            RotationRate.Yaw = Clamp( RotationRate.Yaw, -MaxCorpseYawRate, MaxCorpseYawRate );
            RotationRate.Roll = 0;

            bFixedRotationDir = true;
            bRotateToDesired = false;

            Health -= Damage;
            CalcHitLoc( HitLocation, vect(0,0,0), HitBone, HitBoneDist );

            if( InstigatedBy != None )
                HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + VRand() * 0.2 + vect(0,0,2.8) );
            else
                HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

            DoDamageFX( HitBone, Damage, DamageType, Rotator(HitNormal) );
        }
    }

    simulated function BeginState()
	{
		if ( (LastStartSpot != None) && (Level.TimeSeconds - LastStartTime < 7) )
			LastStartSpot.LastSpawnCampTime = Level.TimeSeconds;
		SetCollision(true,false,false);
        if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else if ( class'GameInfo'.default.GoreLevel > 0 )
			SetTimer(0.1, false);
        else
			SetTimer(2.0, false);
        
        // Q: MH: If we set to Falling all the time, we don't 
        //      know what kind of death it was later on
        //SetPhysics(PHYS_Falling);
		
        bInvulnerableBody = true;

        if( Level.NetMode != NM_DedicatedServer )
        {
            // NOTE: Keep pointers around just in cast they sever the spine.
            if ( LeftMarker != None )
                LeftMarker.Extinguish( self );

            if ( RightMarker != None )
                RightMarker.Extinguish( self );
        }
		
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied(self);
			else
				Controller.Destroy();
		}
        RagdollLastSeenTime = Level.TimeSeconds;
	}

    simulated function Timer()
	{
        local bool  bDestroy;
        local PlayerController pc;
        local float dist, ns;
        local HavokSkeletalSystem hskel;

        bDestroy = false;

        if ( Physics == PHYS_HavokSkeleton && HavokSkeletalSystem(HParams) != None )
        {
            hskel = HavokSkeletalSystem(HParams);

            if ( IsAnimating() && (hskel.SkelState == HSSS_PoseUpdated || hskel.SkelState == HSSS_Frozen) )
            {
                StopAnimating( true );
            }

            if ( Level.GetRagdollNotSeenLimit() > 0 )
            {
                if ( PlayerCanSeeMe() )
                {
                    RagdollLastSeenTime = Level.TimeSeconds;
                }
                else
                {
                    ns = (Level.TimeSeconds - RagdollLastSeenTime);
                }
            }

            if ( Level.GetRagdollNotSeenLimit() <= 0 || ns > Level.GetRagdollNotSeenLimit() )
            {
                if ( Level.GetRagdollDistanceLimit() > 0 )
                {
                    pc = Level.GetLocalPlayerController();

                    if ( pc != None && pc.Pawn != None )
                    {
                        dist = VSize( Location - pc.Pawn.Location );
                        if ( dist > Level.GetRagdollDistanceLimit() )
                        {
                            `log( "RJ: ragdoll is"@dist@"units away and not seen for"@ns@" - destroying" );
                            bDestroy = true;
                        }
                    }
                }
                else if ( Level.GetRagdollNotSeenLimit() > 0 )
                {
                    `log( "RJ: ragdoll not seen for"@ns@"seconds - destroying" );
                    bDestroy = true;
                }
            }
        }
        else if ( !PlayerCanSeeMe() )
        {
            `log( "RJ: not seen --- destroying" );
            bDestroy = true;
        }

		if ( bDestroy )
        {
            Destroy();
        }
        else
        {
			SetTimer(0.5, false);
        }
	}

	// this will only be called if the pawn is in ragdoll mode and the impact is greater than it's HParam's ImpactThresold 
	//
	simulated event HImpact(actor other, vector pos, vector ImpactVel, vector ImpactNorm, Material HitMaterial)
	{
		local float Vol;

		if ( RagImpactSound != None && Level.TimeSeconds > LastRagdollImpact + 1.0)
		{
			Vol = FClamp(VSize(ImpactVel), 0.5, 1.0);
			if ( RagImpactSoundVolScale > 0 )
			{
				Vol /= RagImpactSoundVolScale;
			}
			PlaySound(RagImpactSound,,Vol);
			LastRagdollImpact = Level.TimeSeconds;
		}
	}
}

event PostLoadGame()
{
	Super.PostLoadGame();
	bPostLoadGameCalled = true;
}

function HandlePickupRefused(Pickup item) 
{
    if (Level.TimeSeconds - CantPickupMessageTime > 0.75)
    {
        ReceiveLocalizedMessage( class'CantPickupMessage', 0, None, None, item);
        CantPickupMessageTime = Level.TimeSeconds;
    }
}

simulated function DrawHudDebug(Canvas C, Vector Center)
{
    local vector screenPos;
	local string msg;
	local int yoff;
	local HavokSkeletalSystem hskel;

	if( VSize(Center - Location) > 3000 )
		return;

	screenPos = C.WorldToScreen( Location
                               + vect(0,0,1)*(CollisionHeight / 2) );
    if (screenPos.Z > 1.0) return;

    C.SetDrawColor(0,255,0);
    C.Font = C.SmallFont;
	yoff = -36;

	msg = "Name: "$Name@"("$GetStateName()$")";
    C.SetPos(screenPos.X - 8*Len(msg)/2, screenPos.y+yoff);
    C.DrawText( msg );
	yoff += 12;

	msg = "LifeSpan: "$LifeSpan;
	C.SetPos(screenPos.X - 8*Len(msg)/2, screenPos.y+yoff);
    C.DrawText( msg );
	yoff += 12;

	msg = "Physics: "$Physics;
	if ( Physics == PHYS_HavokSkeleton )
	{
		hskel = HavokSkeletalSystem(HParams);
		if ( hskel != None )
		{
			msg = msg@"("$hskel.SkelState$")";
		}
	}
	C.SetPos(screenPos.X - 8*Len(msg)/2, screenPos.y+yoff);
    C.DrawText( msg );
	yoff += 12;
}

defaultproperties
{
     GibCountCalf=4
     GibCountForearm=2
     GibCountHand=2
     GibCountHead=2
     GibCountTorso=2
     GibCountUpperArm=2
     MultiJumpRemaining=1
     MaxMultiJump=1
     MultiJumpBoost=25
     SkeletalBlendingFalloff=3
     SkeletalBlendingUIHitGain=8
     SkeletalBlendingUIRecoverGain=6
     SkeletalBlendingUIRecoverRate=13
     RemainingUDamageMax=60.000000
     ShieldChargeMax=1000.000000
     ShieldStrengthMax=150.000000
     ShieldConvertRate=200.000000
     ShieldStrengthDecay=35.000000
     ShieldHitMatTime=0.200000
     GruntVolume=0.550000
     MinTimeBetweenPainSounds=0.750000
     FootstepVolume=0.200000
     NotifyFootstepVolume=0.300000
     HeadShotRadius=40.000000
     RagDeathImpulseScale=2.000000
     RagDeathVelScale=2.000000
     RagDeathAngVelScale=2.000000
     RagAngVelScale=100.000000
     RagUpKick=3.000000
     RagInvMass=0.020000
     RagMaxLinVel=1500.000000
     RagMaxAngVel=60000.000000
     RagImpactThreshold=100.000000
     ShieldMat=Shader'PariahEffectsTextures.ShieldS.PlayerShield'
     ShieldHitMat=Shader'PariahEffectsTextures.ShieldS.PlayerShieldHit'
     InstantHitSound=SoundGroup'NewBulletImpactSounds.Final.FleshImpact'
     SoundFootsteps(0)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(1)=SoundGroup'NewFootsteps.Final.rock'
     SoundFootsteps(2)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(3)=SoundGroup'NewFootsteps.Final.Metal'
     SoundFootsteps(4)=SoundGroup'NewFootsteps.Final.Wood'
     SoundFootsteps(5)=SoundGroup'NewFootsteps.Final.Plant'
     SoundFootsteps(6)=SoundGroup'NewFootsteps.Final.Plant'
     SoundFootsteps(7)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(8)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(9)=SoundGroup'NewFootsteps.Final.water'
     SoundFootsteps(10)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(11)=SoundGroup'NewFootsteps.Final.water'
     SoundFootsteps(12)=SoundGroup'NewFootsteps.Final.Stone'
     SoundFootsteps(13)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(14)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(15)=SoundGroup'NewFootsteps.Final.rock'
     SoundFootsteps(16)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(17)=SoundGroup'NewFootsteps.Final.Metal'
     SoundFootsteps(18)=SoundGroup'NewFootsteps.Final.Wood'
     SoundFootsteps(19)=SoundGroup'NewFootsteps.Final.Plant'
     SoundFootsteps(20)=SoundGroup'NewFootsteps.Final.Plant'
     SoundFootsteps(21)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(22)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(23)=SoundGroup'NewFootsteps.Final.water'
     SoundFootsteps(24)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(25)=SoundGroup'NewFootsteps.Final.water'
     SoundFootsteps(26)=SoundGroup'NewFootsteps.Final.Stone'
     SoundFootsteps(27)=SoundGroup'NewFootsteps.Final.dirt'
     SoundFootsteps(28)=SoundGroup'NewFootsteps.Final.Metal'
     SoundFootsteps(29)=SoundGroup'NewFootsteps.Final.rock'
     SoundSurfaceJumps(0)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(1)=SoundGroup'NewFootsteps.FinalJump.JumpRock'
     SoundSurfaceJumps(2)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(3)=SoundGroup'NewFootsteps.FinalJump.JumpMetal'
     SoundSurfaceJumps(4)=SoundGroup'NewFootsteps.FinalJump.JumpWood'
     SoundSurfaceJumps(5)=SoundGroup'NewFootsteps.FinalJump.JumpPlant'
     SoundSurfaceJumps(6)=SoundGroup'NewFootsteps.FinalJump.JumpPlant'
     SoundSurfaceJumps(7)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(8)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(9)=SoundGroup'NewFootsteps.FinalJump.JumpWater'
     SoundSurfaceJumps(10)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(11)=SoundGroup'NewFootsteps.FinalJump.JumpWater'
     SoundSurfaceJumps(12)=SoundGroup'NewFootsteps.FinalJump.JumpStone'
     SoundSurfaceJumps(13)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(14)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(15)=SoundGroup'NewFootsteps.FinalJump.JumpRock'
     SoundSurfaceJumps(16)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(17)=SoundGroup'NewFootsteps.FinalJump.JumpMetal'
     SoundSurfaceJumps(18)=SoundGroup'NewFootsteps.FinalJump.JumpWood'
     SoundSurfaceJumps(19)=SoundGroup'NewFootsteps.FinalJump.JumpPlant'
     SoundSurfaceJumps(20)=SoundGroup'NewFootsteps.FinalJump.JumpPlant'
     SoundSurfaceJumps(21)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(22)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(23)=SoundGroup'NewFootsteps.FinalJump.JumpWater'
     SoundSurfaceJumps(24)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(25)=SoundGroup'NewFootsteps.FinalJump.JumpWater'
     SoundSurfaceJumps(26)=SoundGroup'NewFootsteps.FinalJump.JumpStone'
     SoundSurfaceJumps(27)=SoundGroup'NewFootsteps.FinalJump.JumpDirt'
     SoundSurfaceJumps(28)=SoundGroup'NewFootsteps.FinalJump.JumpMetal'
     SoundSurfaceJumps(29)=SoundGroup'NewFootsteps.FinalJump.JumpRock'
     RagImpactSound=SoundGroup'HavokObjectSounds.Bodies.BodyFallRandom'
     TeleportMat=Shader'PariahGameTypeTextures.Extra.PlayerTrans'
     TeleportMatRed=Shader'PariahGameTypeTextures.Extra.PlayerTransRed'
     CharTauntAnim="wave"
     CharIdleAnim="Idle_Breathe"
     WallDodgeAnims(0)="WallDodgeF"
     WallDodgeAnims(1)="WallDodgeB"
     WallDodgeAnims(2)="WallDodgeL"
     WallDodgeAnims(3)="WallDodgeR"
     IdleHeavyAnim="PlasmaGun_Idle"
     IdleRifleAnim="PlasmaGun_Idle"
     FireHeavyRapidAnim="PlasmaGun_Fire"
     FireHeavyBurstAnim="PlasmaGun_Fire"
     FireRifleRapidAnim="PlasmaGun_Fire"
     FireRifleBurstAnim="PlasmaGun_Fire"
     FireRootBone="Bip01 Spine1"
     LeftOffset=(X=20.000000,Y=25.000000,Z=20.000000)
     RightOffset=(X=20.000000,Y=25.000000,Z=-20.000000)
     SkeletalBlendingUIHitGainCurve=(Points=((OutVal=1.000000),(InVal=10.000000,OutVal=0.020000),(InVal=20.000000,OutVal=0.001000)))
     SkeletalBlendingUIRecoverGainCurve=(Points=((OutVal=1.000000),(InVal=10.000000,OutVal=2.000000),(InVal=20.000000,OutVal=10.000000)))
     SkeletalBlendingUIRecoverRateCurve=(Points=((OutVal=0.500000),(InVal=20.000000,OutVal=0.025000)))
     Species=SPECIES_Jugg
     Bleed=True
     bBlendFiring=True
     bBlendStrafeFiring=True
     bUseHitAnimChannel=True
     bPlayerShadows=True
     bRagdollCorpses=True
     GroundSpeed=440.000000
     WaterSpeed=220.000000
     AirSpeed=440.000000
     JumpZ=340.000000
     WalkingPct=0.400000
     BaseEyeHeight=38.000000
     EyeHeight=38.000000
     CrouchHeight=58.000000
     CrouchRadius=40.000000
     DodgeSpeedFactor=1.500000
     DodgeSpeedZ=210.000000
     MovementAnims(0)="RunF"
     MovementAnims(1)="RunB"
     MovementAnims(2)="RunL"
     MovementAnims(3)="RunR"
     TurnLeftAnim="TurnL"
     TurnRightAnim="TurnR"
     SwimAnims(0)="SwimF"
     SwimAnims(1)="SwimB"
     SwimAnims(2)="SwimL"
     SwimAnims(3)="SwimR"
     CrouchAnims(0)="CrouchF"
     CrouchAnims(1)="CrouchB"
     CrouchAnims(2)="CrouchL"
     CrouchAnims(3)="CrouchR"
     WalkAnims(0)="WalkF"
     WalkAnims(1)="WalkB"
     WalkAnims(2)="WalkL"
     WalkAnims(3)="WalkR"
     AirAnims(0)="JumpF_Mid"
     AirAnims(1)="JumpB_Mid"
     AirAnims(2)="JumpL_Mid"
     AirAnims(3)="JumpR_Mid"
     TakeoffAnims(0)="JumpF_Takeoff"
     TakeoffAnims(1)="JumpB_Takeoff"
     TakeoffAnims(2)="JumpL_Takeoff"
     TakeoffAnims(3)="JumpR_Takeoff"
     LandAnims(0)="JumpF_Land"
     LandAnims(1)="JumpB_Land"
     LandAnims(2)="JumpL_Land"
     LandAnims(3)="JumpR_Land"
     SlideAnims(0)="SlideF"
     SlideAnims(1)="SlideB"
     SlideAnims(2)="SlideL"
     SlideAnims(3)="SlideR"
     DoubleJumpAnims(0)="DoubleJumpF"
     DoubleJumpAnims(1)="DoubleJumpB"
     DoubleJumpAnims(2)="DoubleJumpL"
     DoubleJumpAnims(3)="DoubleJumpR"
     DodgeAnims(0)="DodgeF"
     DodgeAnims(1)="DodgeB"
     DodgeAnims(2)="DodgeL"
     DodgeAnims(3)="DodgeR"
     AirStillAnim="Jump_Mid"
     TakeoffStillAnim="Jump_Takeoff"
     LandStillAnim="Jump_Land"
     CrouchTurnRightAnim="Crouch_TurnR"
     CrouchTurnLeftAnim="Crouch_TurnL"
     IdleCrouchAnim="Crouch"
     IdleSwimAnim="Swim_Tread"
     IdleWeaponAnim="PlasmaGun_Idle"
     RootBone="Bip01"
     HeadBone="Bip01 Head"
     SpineBone1="Bip01 Spine1"
     SpineBone2="Bip01 Spine2"
     ControllerClass=Class'XGame.xBot'
     bPhysicsAnimUpdate=True
     bDoTorsoTwist=True
     LODBias=1.500000
     ScaleGlow=2.000000
     CollisionRadius=40.000000
     CollisionHeight=75.000000
     Begin Object Class=HavokSkeletalSystem Name=PawnHParams
     End Object
     HParams=HavokSkeletalSystem'XGame.PawnHParams'
     RotationRate=(Pitch=3072)
     AmbientGlow=0
     MaxLights=6
     bActorShadows=True
     bNetNotify=True
}
