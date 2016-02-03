class SPPlayerPawn extends VGPawn;

#exec LOAD File="PariahWeaponSounds.uax"

var Name CharID;

var BulletWhizSound bulletWhiz;

function PostBeginPlay()
{
	// log("SPPlayerPawn postbeginplay registering self");
	SinglePlayer(Level.Game).RegisterNPC(CharID, self);
    bulletWhiz = spawn(class'BulletWhizSound');
	Super.PostBeginPlay();
}

function bool CanRide()
{
	if(PotentialVehicle.Controller != None && !PotentialVehicle.Controller.SameTeamAs(Controller))
	{
		return false;
	}
	else return Super.CanRide();
		
}

function Destroyed()
{
    if(bulletWhiz != None)
        bulletWhiz.Destroy();
	AmbientSound = None;
    Super.Destroyed();
}

function NotifyBulletMiss( vector loc, int style )
{
    if(frand() < 0.25)
        bulletWhiz.PlayWhizSound(loc, style);
}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
	// log(damage@eventinstigator@damagetype@projowner);
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Vect(0,0,0), DamageType, ProjOwner, bSplashDamage);
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(Level.IsCoopSession() && Level.Game.IsA('SinglePlayer'))
	{
		SinglePlayer(Level.Game).SaveRespawnState(self);
	}
	Super.Died(Killer, DamageType, HitLocation);
}

defaultproperties
{
     CharID="PlayerMason"
     HealthUnitRegenRate=8.000000
     SoundGroupClass=Class'XGame.xMercMaleSoundGroup'
     VoiceType="VehicleGame.PariahVoicePack"
     MovementAnims(0)="RunF_NoWeapon"
     IdleWeaponAnim="Idle_Breathe"
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.Mason_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem14
     End Object
     HParams=HavokSkeletalSystem'PariahSP.HavokSkeletalSystem14'
     Skins(0)=Shader'PariahCharacterTextures.Mason.newmason_bodyshader'
     Skins(1)=Texture'PariahCharacterTextures.Mason.newmason_head'
     Skins(2)=Texture'PariahCharacterTextures.Mason.mason_eyecover'
}
