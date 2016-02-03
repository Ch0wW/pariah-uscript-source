class SPPawn extends VGPawn
	native
   	exportstructs;

var Name            LeftEye, RightEye;

var Actor           EyesLookAtTarget;
var  vector         EyesLookAtPoint;
var Actor           HeadLookAtTarget;
var  vector         HeadLookAtPoint;
var Actor           TorsoLookAtTarget;
var  vector         TorsoLookAtPoint;
var const bool      EyesLookAt;
var const bool      HeadLookAt;
var const bool      TorsoLookAt;
var const float     EyesLookAtAlpha;
var const float     HeadLookAtAlpha;
var const float     TorsoLookAtAlpha;
var const Rotator   EyesCurRotation;
var const Rotator   HeadCurRotation;
var const Rotator   TorsoCurRotation;
var float     EyesTurnRate;  //not these are no longer const (Prof. J)
var float     HeadTurnRate;
var float     TorsoTurnRate;

var const float LookAtAlphaFadeRate;

//Eyes
var() int EyeMaxDeltaInside;		//Max eye can turn towards nose
var() int EyeMaxDeltaOutside;		//Max eye can turn towards ear
var() int EyeMaxDeltaUp;			//Max eye can look up
var() int EyeMaxDeltaDown;			//Max eye can look down
var() int LeftEyeYawOffset;			//An offset to apply to the left eye to get it to line up correctly
var() int LeftEyePitchOffset;		//An offset to apply to the eyes to get them to line up correctly
var() int RightEyeYawOffset;		//An offset to apply to the right eye to get it to line up correctly
var() int RightEyePitchOffset;		//An offset to apply to the eyes to get them to line up correctly

//Procedural Blinking
const BLINK_CHANNEL = 10;
var name EyesBlinkAnim;
var bool bPlayingBlink;				//Don't change this, use this to get status - call AnimateBlink to set
var name EyeLidsBone;

//Procedural Breathing
var float       BreathePeriod;
var float       MaxBreatheScale;
var name        ChestBone;
var const float BreatheCurTime;

//Head Noise
var rotator HeadNoiseAmp;

var class<AIRole>	AIRoleClass;
var class<SPExclaimManager> ExclamationClass;


var const transient int PNptr;    //Ugly padding hack for PerlinNoise object

// AsP --- Used for Boss characters
var Texture HUDIcon;
var IntBox  HUDIconCoords;

/*enum ERace
{
	R_NPC,
	R_Guard,
	R_Clan,
	R_Shroud,
};*/

//var ERace race;

enum EDisposition
{
    D_Coward,
    D_Cautious,
    D_Brave,
    D_Insane,
};

var EDisposition disposition;
var bool bIsNPC;
var bool bMayMelee;
var bool bMayDive;
var bool bMayFallDown;

var int PawnSkill;

//Prof. Jesse LaChapelle
var(CinematicsPawn) array<string> AdditionalAnimationPkg;


//Prof. Jesse LaChapelle

enum EOrderedSound{
    OSOUND_None,
	OSOUND_Pre,
	OSOUND_Concurrent,
    OSOUND_Post
};

struct OrdSoundStruct{
    var EOrderedSound CurrentState;
    var float CurrentDuration;
    var sound PreSound;
    var sound ConcurrentSound;
    var sound ConcurrentLoopSound;
    var sound PostSound;
    var sound SavedAmbient;
    var float Radius;
    var float Volume;
};

var OrdSoundStruct OrderedSoundState;

const ORDERED_SOUND_TIMER = 53225; //nice random id

/*****************************************************************
 * StepOrderedSound
 * A private function strictly for use by the PlayOrderedSound
 * nonsense.
 *****************************************************************
 */
private function StepOrderedSound(){

    switch(OrderedSoundState.CurrentState){
      case (OSOUND_Pre):
            PlaySound(OrderedSoundState.PreSound,,OrderedSoundState.Volume,,OrderedSoundState.Radius);
            OrderedSoundState.CurrentState = OSOUND_Concurrent;
            SetMultiTimer(ORDERED_SOUND_TIMER, GetSoundDuration(OrderedSoundState.PreSound), false);
            break;

        case (OSOUND_Concurrent):
            AmbientSound = OrderedSoundState.ConcurrentLoopSound;
            PlaySound(OrderedSoundState.ConcurrentSound,SLOT_Talk,OrderedSoundState.Volume,,OrderedSoundState.Radius);
            SetMultiTimer(ORDERED_SOUND_TIMER, GetSoundDuration(OrderedSoundState.ConcurrentSound), false);
            OrderedSoundState.CurrentState = OSOUND_Post;
            break;

        case (OSOUND_Post):
            AmbientSound = OrderedSoundState.SavedAmbient;
            PlaySound(OrderedSoundState.PostSound,,OrderedSoundState.Volume,,OrderedSoundState.Radius);
            OrderedSoundState.CurrentState = OSOUND_None; // resetting for next use
            break;
    }
}

/*****************************************************************
 * PlayOrderedSound
 * This is intended to allow for better co-ordination
 * of sounds. The original implementation is designed to allow
 * things to play radio noises...
 * (i.e. 'click', 'roger that' + <static> , 'click').
 * This is a dumb way to do this, but this late in the project there is
 * no one with enough time to process the mass quantity of audio that needs
 * modification.
 *****************************************************************
 */
function bool PlayOrderedSound(Sound PreSound, Sound ConcurrentSound,
                          Sound ConcurrentLoopSound, Sound PostSound,
                          optional float Volume, optional float Radius)
{
    if (OrderedSoundState.CurrentState == OSOUND_None) {
        OrderedSoundState.CurrentState            = OSOUND_Pre;
        OrderedSoundState.PreSound                = PreSound;
        OrderedSoundState.ConcurrentSound         = ConcurrentSound;
        OrderedSoundState.ConcurrentLoopSound     = ConcurrentLoopSound;
        OrderedSoundState.PostSound               = PostSound;
        OrderedSoundState.SavedAmbient            = AmbientSound;

        OrderedSoundState.Volume                  = TransientSoundVolume;
        if (Volume != 0){OrderedSoundState.Volume = Volume;}

        OrderedSoundState.Radius                  = TransientSoundRadius;
        if (Radius != 0){OrderedSoundState.Radius = Radius;}

        StepOrderedSound();
        return true;
    } else {
        return false;
    }
}


/*****************************************************************
 * Multitimer
 *****************************************************************
 */
function MultiTimer(int SlotID){
    if (slotID == ORDERED_SOUND_TIMER){
        StepOrderedSound();
    } else {
        super.MultiTimer(slotid);
    }
}

/*****************************************************************
 * PostBeginPlay
 * Added this call to postbeginplay to allow pawns to play animations
 * from an additional animations package. This allows BrainBox to do
 * cinematic animations in there own packages that never need to be
 * loaded at run-time, while still having access to the existing set
 * of character animations
 *****************************************************************
 */
function PostBeginPlay(){

    local int i;
    local MeshAnimation AdditionalAnims;

    // switch animations sets, this 'appends' animations provided the
    // names are distinct
    for (i=0; i< AdditionalAnimationPkg.Length; i++){
        AdditionalAnims = MeshAnimation( DynamicLoadObject(AdditionalAnimationPkg[i],
                                                class'MeshAnimation') );
        if ( AdditionalAnims!= none ) {
            LinkSkelAnim( AdditionalAnims );
        }  else {
            Log("The additional animation package: " $ AdditionalAnimationPkg[i] $ " is missing.");
        }
    }
    Super.PostBeginPlay();
}



const HIT_CHANNEL = 14;

native function SetLookAtTarget(Actor target, Vector offset, optional bool Eyes, optional bool Head, optional bool Torso);
native function SetLookAtPoint(Vector point, optional bool Eyes, optional bool Head, optional bool Torso);
native function StopLookAt(optional bool Eyes, optional bool Head, optional bool Torso);

simulated function AnimateBlink(bool bAnimate)
{
	if(bPlayingBlink != bAnimate)
	{
		bPlayingBlink = bAnimate;

		if(bPlayingBlink)
			StartBlink();
		else
			StopBlink();
	}
}

simulated function StartBlink()
{
	AnimBlendParams(BLINK_CHANNEL, 1.0, 0.0, 0.5, EyeLidsBone);
}

simulated function StopBlink()
{
	AnimBlendToAlpha(BLINK_CHANNEL, 0, 0.4);
}

simulated function PlayBlink()
{
	PlayAnim(EyesBlinkAnim,, 0.01, BLINK_CHANNEL);
}

simulated event AnimEnd( int Channel )
{
	if(Channel == BLINK_CHANNEL)
	{
		//AnimateBlink(false);
        return;
	}

    if(bUseHitAnimChannel && Channel == HIT_CHANNEL)
    {
        AnimBlendToAlpha(HIT_CHANNEL, 0, 0.4);
        VGSPAIController(Controller).TakeHitComplete();
	}

    Super.AnimEnd(Channel);
}

function Notify_Melee()
{
    VGSPAIController(Controller).Notify_Melee();
}

function Notify_Toss()
{
    SPAIController(Controller).Notify_Toss();
}

function Notify_FallDown()
{
    SPAIController(Controller).Notify_FallDown();
}

/////



simulated function PlayMidAirDeath()
{
    RandSpin(40000);
    PlayAnim('DeathF',, 0.2);
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
    PlayAnim('DeathF',, 0.2);
}

function String RetrivePlayerName()
{
    return String(Name);
}

function DropWEC(Controller Killer) {}

function CreateInventory(string InventoryClassName)
{
	local Inventory Inv;
	local class<Inventory> InventoryClass;

	InventoryClass = class<Inventory>( DynamicLoadObject(InventoryClassName, class'Class') );
	if( (InventoryClass!=None) && (FindInventoryType(InventoryClass)==None) )
	{	Inv = Spawn(InventoryClass);
		if( Inv != None )
		{	Inv.GiveTo(self);
			Inv.PickupFunction(self);
		}
	}
}


//////////

function bool PawnMayMelee()
{
    return bMayMelee;
}
function bool PawnMayDive()
{
    return bMayDive;
}
function bool MaySmoke()
{
    return true;
}

//=============================================
// Oh dear... this is rape and paste from xPawn
//=============================================
simulated function PlayDirectionalHit(Vector HitLoc)
{
    local Vector X,Y,Z, Dir;
    local float r;

    //Super.PlayDirectionalHit(HitLoc);

    IdleTime = Level.TimeSeconds;

    if(!bUseHitAnimChannel || IsAnimating(HIT_CHANNEL) )
        return;

	AnimBlendParams(HIT_CHANNEL, 1.0, 0.0, 0.2, FireRootBone);

    GetAxes(Rotation, X,Y,Z);
    HitLoc.Z = Location.Z;
    
    VGSPAIController(Controller).PlayTakeHit();

    if( bMayFallDown
		&& (HitFX[SimHitFxTicker].bone == 'lthigh'
        || HitFX[SimHitFxTicker].bone == 'rthigh'
        || HitFX[SimHitFxTicker].bone == 'lfoot'
        || HitFX[SimHitFxTicker].bone == 'rfoot')
        && Frand()< 0.10 )
    {
        SPAIController(Controller).FallDown();
        return;  
    }

    if( bMayFallDown
		&& HitFX[SimHitFxTicker].DamType.Name != 'VGAssaultDamage' 
		&& HitFX[SimHitFxTicker].DamType.Name != 'PlasmaGunDamage'
        && Frand()< 0.125 )
    {
        SPAIController(Controller).FullBodyHit();
        return;
    }

    Dir = Normal(HitLoc - Location);
    if ( Dir Dot X > 0.7 )
    {
        r = FRand();
        if( r < 0.5)
        {
            PlayAnim('FullBodyHit_Front02', , 0.1, HIT_CHANNEL);
        }
        else
        {    PlayAnim('FullBodyHit_Front03', , 0.1, HIT_CHANNEL);
        }
    }
    else if ( Dir Dot X < -0.7 )
    {
        r = FRand();
        if( r < 0.5 || !bMayFallDown)
        {
            PlayAnim('FullBodyHit_Back01',, 0.1, HIT_CHANNEL);
        }
        else
        {
            //FullBody falldown/recover State
            SPAIController(Controller).FallDown();
            return;
        }
    }
    else if( FRand() < 0.5 )
	{
		PlayAnim(HitAnims[0],, 0.1,2);
	}
	else
	{
		PlayAnim(HitAnims[1],, 0.1,2);
	}
}

// Leave bCanClimbLadders as true so bots don't freak out and hammer the pathfinder..
// but never let them go to PHYS_Ladder
function bool CanGrabLadder()
{
    return false;
}

defaultproperties
{
     EyeMaxDeltaInside=7200
     EyeMaxDeltaOutside=7200
     EyeMaxDeltaUp=2500
     EyeMaxDeltaDown=2500
     EyesTurnRate=6.000000
     HeadTurnRate=3.000000
     TorsoTurnRate=1.000000
     LookAtAlphaFadeRate=4.000000
     BreathePeriod=2.000000
     MaxBreatheScale=0.020000
     LeftEye="EyeL"
     RightEye="EyeR"
     EyesBlinkAnim="Blink"
     EyeLidsBone="head"
     ChestBone="Bip01 Chest"
     AIRoleClass=Class'VGSPAI.AIRole'
     ExclamationClass=Class'PariahSP.SPExclaimManager'
     HeadNoiseAmp=(Pitch=910,Yaw=910,Roll=910)
     bMayMelee=True
     bMayDive=True
     RequiredEquipment(0)=""
     RequiredEquipment(1)=""
     VoiceType="VehicleGame.PariahVoicePack"
     SightRadius=2500.000000
     PeripheralVision=0.707000
     MaxFallSpeed=10000.000000
     bJumpCapable=False
     bCanJump=False
     bCanWalkOffLedges=True
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem12
     End Object
     HParams=HavokSkeletalSystem'PariahSP.HavokSkeletalSystem12'
}
