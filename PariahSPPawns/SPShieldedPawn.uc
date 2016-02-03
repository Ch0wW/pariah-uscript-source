class SPShieldedPawn extends SPPawn;

var SPAIShield myController;

// Shield Attachment
var() staticmesh ShieldMesh;
var class<ShieldActor> ShieldClass;
var ShieldActor Shield;
var name ShieldBone;
var vector ShieldRelativeLocation;
var rotator ShieldRelativeRotation;

var byte hitPhase;
var float hitTime;

const HIT_CHANNEL2 = 4;

function AnimEnd(int Channel)
{
    if ( Channel == HIT_CHANNEL2 )
    {
        AnimBlendToAlpha(HIT_CHANNEL2, 0, 0.4);
    }
    else if (Channel == 1)
    {
		ChannelOneAnimEnd();
    }
	else
    {
        Super.AnimEnd(Channel);
    }
}

function ChannelOneAnimEnd()
{
	if (FireState == FRS_Ready 
		|| FireState == FRS_None)
	{
		PlayAnim( GetIdleWeaponAnim(),, 0.2, 1);
    }
    else if (FireState == FRS_PlayOnce)
    {
        PlayAnim( GetIdleWeaponAnim(),, 0.2, 1);
        FireState = FRS_Ready;
        
		IdleTime = Level.TimeSeconds;
    }
}
function PlayWeaponSwitch(Weapon NewWeapon)
{
    if ( Physics == PHYS_Walking )
    {
		FireState = FRS_None;
        PlayAnim('Weapon_Switch');
        AnimAction = 'Weapon_Switch';
    }
}

function Name GetIdleWeaponAnim()
{
    return 'WalkF_Shield';
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
    Super.PlayDirectionalHit(HitLoc);
    PlayAnim('ShieldDefense03', , ,HIT_CHANNEL2);
    SetAnimFrame( 0.51, HIT_CHANNEL2);
    //AnimBlendToAlpha(HIT_CHANNEL2, 0, 0);
}

function PlayShieldHit()
{
    if( IsAnimating(HIT_CHANNEL2))
    {
        MarkTime(hitTime);
        return;
    }
	AnimBlendParams(HIT_CHANNEL2, 1.0, 0.0, 0.5, RootBone);

    
    if( !TimeElapsed(hitTime, 0.4) )
        hitPhase = (hitPhase + 1) % 3;
    else
        hitPhase = 0;

    if(hitPhase == 0)
    {
        PlayAnim('ShieldDefense01', , ,HIT_CHANNEL2);
     }
    else if(hitPhase == 1)
    {
        PlayAnim('ShieldDefense02', , ,HIT_CHANNEL2);
    }
    else
    {
        PlayAnim('ShieldDefense03', , ,HIT_CHANNEL2);
        hitPhase=0;
    }

    MarkTime(hitTime);
}

function NotifyShieldHit()
{
    myController.NotifyShieldHit();
    PlayShieldHit();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
    SetupShield();
	AnimBlendParams(1, 1.0, 0.0, 0.5, SpineBone1);
	PlayAnim( GetIdleWeaponAnim(),, 0.2, 1);

}

function SetupShield()
{
    if ( Shield == None )
	{
		Shield = Spawn(ShieldClass);
	}
    
	Shield.SetStaticMesh(ShieldMesh);
    AttachToBone(Shield,ShieldBone);

	Shield.SetRelativeLocation(ShieldRelativeLocation);
	Shield.SetRelativeRotation(ShieldRelativeRotation);
    Shield.Init(self);
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
    Super.PlayDying( DamageType, HitLoc);
    KnockOffShield();
}

function KnockOffShield()
{
	if ( Shield != None )
	{
		Shield.TornOff();
		Shield = None;
	}
}

defaultproperties
{
     ShieldMesh=StaticMesh'PariahGametypeMeshes.ShieldS.guard_shield'
     ShieldBone="Bip01 L Hand"
     ShieldClass=Class'PariahSPPawns.ShieldActor'
     ShieldRelativeRotation=(Pitch=32768,Yaw=32768)
     bMayMelee=False
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem128
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem128'
}
