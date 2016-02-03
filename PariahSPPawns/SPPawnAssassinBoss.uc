class SPPawnAssassinBoss extends SPPawnShroudAssassin;

var AssassinBossCloak TheCloak;
var sound DeathScream;
//simulated function AnimEnd(int Channel)
//{
//
//}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	TheCloak = Spawn(class'AssassinBossCloak',self,,Location,Rotation);
	AttachToBone(TheCloak, 'cloak');
}

function SetMovementPhysics()
{

}

//boss doesn't need blades
function AddBlades();

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Vect(0,0,0), DamageType, ProjOwner, bSplashDamage);
}


simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	//Super.PlayDying(DamageType, hitloc);

	TheCloak.SetBase(None);
	TheCloak.SetPhysics(PHYS_Falling);
	TheCloak.PlayAnim('cloak_die');
	TheCloak.bCollideWorld=true;
    PlaySound(DeathScream,SLOT_Talk);
	Controller.PawnDied(self);
	Destroy();
}


function Cloak()
{
}

function DeCloak()
{
}

defaultproperties
{
     DeathScream=SoundGroup'GenericFemaleAssassinBoss.DeathScream.RandomBossScream'
     HUDIcon=Texture'PariahInterface.HUD.ShroudAssasin'
     AIRoleClass=Class'PariahSPPawns.SPAIRoleAssassinBoss'
     ExclamationClass=Class'PariahSPPawns.SPAssassinBossExclaim'
     HUDIconCoords=(X2=63,Y2=63)
     bUseHitAnimChannel=False
     bRagdollCorpses=False
     Health=2000
     HealthMax=2000.000000
     ControllerClass=Class'PariahSPPawns.SPAIAssassinBoss'
     race=R_Guard
     bPhysicsAnimUpdate=False
     DrawScale=1.500000
     TransientSoundVolume=255.000000
     TransientSoundRadius=3000.000000
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem138
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem138'
     Skins(0)=Shader'DavidTextures.Assassin.AssassinBossBody'
     Skins(1)=Texture'PariahCharacterTextures.ShroudAssasin.shroudassasin_head'
     RotationRate=(Pitch=0,Roll=3072)
     Physics=PHYS_Flying
     SoundVolume=255
}
