class SPPawnStockton extends SPScriptPawnStockton;


#exec OBJ LOAD FILE=..\Textures\PariahCharacterTextures.utx
#exec OBJ LOAD FILE=..\Animations\PariahMaleAnimations_SP.ukx

var float CurrentScale, ScaleSpeed, TargetScale;

var bool bAllowDeath;

var Emitter shield;



var StocktonSmallGeneratorDrain SmallGenDrain;

var Generator Gen;


var Sound SndGenDrain, SndShieldCharge, SndShieldOn, SndShieldOff, SndShieldImpact, SndStartBeam;

function PostBeginPlay()
{
	Super.PostBeginPlay();

}

function DidDamageTo(Pawn Other)
{
	SPAIStockton(Controller).bDidDamage=true;

}

function LowerShield()
{

	local Emitter s;
	//Shield.Destroy();

	s = Spawn(class'VehicleEffects.StocktonShieldOff',self,,Location,Rotation);
	s.SetBase(self);
	SetTimer(1, false);
	s.PlaySound(SndShieldOff,,5 * TransientSoundVolume, true, 5000, 1.0, false);

	//Lightning.Destroy();
}

event Timer()
{
	Shield.Destroy();
	Shield = None;
}

function RaiseShield()
{
	//BigGenDrain.SetBase(self);
	if(shield == None)
	{

		shield = Spawn(class'VehicleEffects.StocktonShield', self,,Location, Rotation);
		shield.SetBase(self);
		//SetTimer(1, false);
	}

	shield.PlaySound(SndShieldOn,,5 * TransientSoundVolume, true, 5000, 1.0, false);
	//else
	//{
	//	shield.Emitters[0].MaxActiveParticles=10;
	//}
}


function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage)
{
//	local David fx;
	local vector hitdir;
	local rotator rhit;

	if(bInvulnerable)
	{


		hitdir = Normal(hitlocation - location);
		rhit = Rotator(hitdir);

		Momentum=Vect(0,0,0);

		if(!bSplashDamage)
		{
			//fx = spawn(class'VehicleEffects.DavidBossShieldHit',self,,Location, rhit);

		}
		else
		{
			rhit.pitch=0;
			rhit.roll=0;
			//fx = spawn(class'VehicleEffects.DavidBossShieldHitArea',self,,HitLocation,rhit);
		}
		//fx.SetBase(self);
		return;
	}
	if(WouldKill(Damage))
	{
		bInvulnerable=true;
		//SPAIRoleStockton(SPAIStockton(Controller).myAIRole).GOTO_Weakened();
		SPAIStockton(Controller).SetWeakened();

		return;
	}

	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage);
	log(health);
}

function StartCharging(Generator g)
{
	

	Gen = g;
	SmallGenDrain = spawn(class'VehicleEffects.StocktonSmallGeneratorDrain',,,Location, Rotation);
	//SmallGenDrain.AmbientSound = SndGenDrain;
	//SmallGenDrain.SetBase(self);

}

function FinishCharging()
{
	Health = HealthMax;
	bInvulnerable=false;
//	Gen.Tag = '';
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
	if(bInvulnerable)
	{
		PlaySound(SndShieldImpact,,5 * TransientSoundVolume, true, 5000, 1.0, false);
	}
}

function bool WouldKill(int damage)
{
	if(Damage >= Health && !bAllowDeath)
		return true;
	else return false;
}

defaultproperties
{
     CurrentScale=1.000000
     ScaleSpeed=0.100000
     SndShieldCharge=Sound'BossFightSounds.Stockton.StocktonShieldCharge'
     SndShieldOn=Sound'BossFightSounds.Stockton.StocktonShieldOn'
     SndShieldOff=Sound'BossFightSounds.Stockton.StocktonShieldOff'
     SndShieldImpact=Sound'BossFightSounds.Stockton.StocktonShieldImpact'
     SndStartBeam=Sound'PariahDropShipSounds.Millitary.DropshipShieldShortC'
     bInvulnerable=False
     HUDIcon=Texture'PariahInterface.HUD.StocktonIcon'
     AIRoleClass=Class'PariahSPPawns.SPAIRoleStockton'
     HUDIconCoords=(X2=63,Y2=63)
     bUseHitAnimChannel=False
     Health=600
     HealthMax=600.000000
     MovementAnims(0)="RunF_RL"
     MovementAnims(1)="RunB_RL"
     MovementAnims(2)="RunL_RL"
     MovementAnims(3)="RunR_RL"
     ControllerClass=Class'PariahSPPawns.SPAIStockton'
     bCanFall=False
     TransientSoundVolume=1.000000
     Begin Object Class=HavokSkeletalSystem Name=HavokSkeletalSystem115
     End Object
     HParams=HavokSkeletalSystem'PariahSPPawns.HavokSkeletalSystem115'
     Tag="DavidPayne"
     Skins(0)=Shader'StocktonBossTextures.Stockton.StocktonVirusShaderBody'
     Skins(1)=Shader'StocktonBossTextures.Stockton.StocktonVirusShaderHead'
     Skins(2)=Texture'PariahCharacterTextures.Stockton.stocktoneyes_cover'
     Skins(3)=Shader'PariahWeaponTextures.TitansFist.TF_EnergyShader'
}
