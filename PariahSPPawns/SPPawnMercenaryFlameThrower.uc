class SPPawnMercenaryFlameThrower extends SPPawnMerc;

#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx
#exec OBJ LOAD FILE=..\Sounds\PariahPlayerSounds.uax

var float ExplodeDamage;
var float ExplodeRadius;
var float ExplodeMomentum;
var Sound PreExplodeSound;
var Sound ExplodeSound;
var class<Emitter> ExplodeEmitter;
var Sound DeathScream;

const RUN_CHANNEL = 4;


function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
    if( ( (Health - Damage) <= 0)
        && !IsInState('Exploding') )
    {
        GotoState('Exploding');
    }
    else
    {
	    super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);
    }
    
}


state Exploding
{
ignores Trigger, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	event ChangeAnimation() {}
	event StopPlayFiring() {}
	function PlayFiring(float Rate, byte FiringMode) {}
	function PlayWeaponSwitch(Weapon NewWeapon) {}
	function PlayTakeHit(vector HitLoc, int Damage, class<DamageType> damageType) {}
	simulated function PlayNextAnimation() {}
	function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
    {}
    event HitWall(vector HitNormal, actor Wall)
    {
    }
    simulated function SetOnFire()
    {
        Super.SetOnFire();
        if(Fire != None)
            AttachToBone(Fire,'bip01 backpack');
    }

    
BEGIN:
    SPAIFlameThrower(Controller).FlameOut();
    StopMoving();
    SPAIController(Controller).StopFireWeapon();
    if(PreExplodeSound != None)
	{
		PlaySound(PreExplodeSound);
	}
    SetOnFire();
    AnimBlendParams(RUN_CHANNEL, 1.0, 0.0, 0.5, RootBone);
    LoopAnim( 'RunF_OnFire',1.5, 0.2, RUN_CHANNEL);
    PlaySound( DeathScream, SLOT_Talk );
    PlaySound( sound'PariahWeaponSounds.hit.FlameThrowerFireLoop');
    
    WaitForNotification();
    Explode();
}

function Explode()
{
    HurtRadius(ExplodeDamage, ExplodeRadius, class'BarrelExplDamage', ExplodeMomentum, Location);

	if(ExplodeEmitter != None)
		spawn(ExplodeEmitter,Controller,,Location,Rotation);

	if(ExplodeSound != None)
		Controller.PlaySound(ExplodeSound);

	Died(DelayedKiller, DelayedDamageType, DelayedHitLoc);
}

defaultproperties
{
     ExplodeDamage=200.000000
     ExplodeRadius=512.000000
     ExplodeMomentum=15000.000000
     PreExplodeSound=Sound'WeaponSounds.Misc.explosion3'
     ExplodeSound=Sound'PariahWeaponSounds.hit.FlameThrowerExplode'
     DeathScream=Sound'PariahPlayerSounds.MaleDeath.death7'
     ExplodeEmitter=Class'VehicleEffects.BarrelShardBurst'
     AIRoleClass=Class'PariahSPPawns.SPAIRoleFlameThrower'
     ExclamationClass=Class'PariahSPPawns.SPMercExclaim'
     Health=200
     ControllerClass=Class'PariahSPPawns.SPAIFlameThrower'
     race=R_Clan
     bDelayDied=True
     Mesh=SkeletalMesh'PariahMaleAnimations_SP.Engineer_Male'
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem118
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem118'
}
