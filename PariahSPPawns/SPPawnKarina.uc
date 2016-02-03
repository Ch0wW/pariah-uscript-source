class SPPawnKarina extends SPPawnNPC;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahFemaleAnimations_SP.ukx

var(Events) Name OnDeathEvent;
var(Events) int	 HealthA;
var(Events) int	 HealthB;
var(Events) Name HealthAEvent;
var(Events) Name HealthBEvent;

var bool bHealthATriggered;
var bool bHealthBTriggered;

const CHAT_CHANNEL = 5;
var bool bPlayingIdleAnim;


function PlayIdleAnims(Name Animation)
{
    bPlayingIdleAnim = true;
    AnimBlendParams(CHAT_CHANNEL, 1, 0.0, 0.0, SpineBone1);
    PlayAnim(Animation,, 0.2, CHAT_CHANNEL);
}

simulated function AnimEnd( int Channel )
{
    
    if ( CHAT_CHANNEL == Channel )  
    {
        AnimBlendToAlpha(CHAT_CHANNEL, 0, 0.4);
        bPlayingIdleAnim = false;
    }
    else
        Super.AnimEnd( Channel );

        
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	TriggerEvent( OnDeathEvent, self, None);
	Super.Died( Killer, damageType, HitLocation);
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
						Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	Super.TakeDamage( Damage,  instigatedBy,  hitlocation, momentum,  damageType, ProjOwner, bSplashDamage);

	if( Health < HealthB && !bHealthBTriggered) {
		bHealthATriggered = true;
		bHealthBTriggered = true;
		TriggerEvent(HealthBEvent, self, instigatedBy);
	}

	if( Health < HealthA && !bHealthATriggered) {
		bHealthATriggered = true;
		TriggerEvent(HealthAEvent, self, instigatedBy);
	}

}

defaultproperties
{
     HealthA=75
     HealthB=25
     CharID="Karina"
     SoundGroupClass=Class'VehicleGame.PariahSoundGroup'
     bNoDefaultInventory=True
     Health=100
     SightRadius=5000.000000
     MaxFallSpeed=1000.000000
     IdleWeaponAnim="Idle_Breathe"
     ControllerClass=Class'PariahSPPawns.SPAIKarina'
     Mesh=SkeletalMesh'PariahFemaleAnimations_SP.Karina_Female'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem112
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem112'
}
