class VGWeapon extends Weapon
	abstract;

#exec OBJ LOAD FILE=PariahWeaponTextures.utx
#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax

var		int			WECLevel;
var	()	int			WECPerLevel[3];
var	()	int			WECMaxLevel;
var	()	int			MultiPlayerWECLevel;

var	()	class<WeaponMessage>	WeaponMessageClass;

replication
{
	// Functions called by server on client
    reliable if( Role==ROLE_Authority )
		ClientAddWEC, ClientAddSuperWEC, WECLevel;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	AddLightTag('FPWEAPON');
	if ( Level.bFirstPersonWeaponsExclusivelyLit )
	{
		bMatchLightTags=True;
	}
	if(Level.Game != none && !Level.Game.IsA('SinglePlayer'))
	{
		SetWECLevel(MultiPlayerWECLevel);
	}
}

simulated function int GetWecLevel()
{
    return WecLevel;
}

function DropWECs(Controller Killer){}
function DropEnergy(Controller Killer) {}

function byte BestMode()
{
	return 0;
}

simulated function bool IsFiring() // called by pawn animation, mostly
{
    return  ( ClientState == WS_ReadyToFire && ( (FireMode[0] != none && FireMode[0].IsFiring()) || (FireMode[1] != none && FireMode[1].IsFiring()) ) );
}

simulated function StartBerserk()
{
	Super.StartBerserk();
	//SetOverlayMaterial(Material'XGameShaders.PlayerShaders.PlayerShieldSh',false,1.0,false);
	//if(ThirdPersonActor != None)
	//	ThirdPersonActor.SetOverlayMaterial(Material'XGameShaders.PlayerShaders.PlayerShieldSh',false,1.0,false);
}

simulated function StopBerserk()
{
	Super.StopBerserk();
	//RemoveOverlayMaterial();
	//if(ThirdPersonActor != None)
    //    ThirdPersonActor.RemoveOverlayMaterial();
}

//Weapon energy core, implemented in PersonalWeapon.uc

//called by server on client to update the WEC count
simulated function ClientAddWEC(int WECAmmount){}
simulated function ClientAddSuperWEC(){}

//not all weapons should do something when adding a WEC
simulated function AddWEC(int WECAmmount){}
simulated function AddSuperWEC(){}

//what to do when the WEC goes up a level
simulated function WECLevelUp(optional bool bNoMessage){}
//set the level of a weapon arbitrarily
simulated function SetWECLevel(int level){}

simulated function SetTurret(Pawn Turret){}

//simulated function WeaponTick(float dt)
//{
//	Super.WeaponTick(dt);

	// check to see if weapon needs a reload
//	if(Ammo[0].CheckReload() && !bIsReloading) {
//		DoReload();
//		bIsReloading = true;
//		Ammo[0].AddAmmo(Ammo[0].PickupAmmo);
//		log("RELOAD");
//	}
//}

defaultproperties
{
     WeaponMessageClass=Class'VehicleGame.WeaponMessage'
     SoundRadius=200.000000
     TransientSoundVolume=1.000000
     TransientSoundRadius=200.000000
     SoundVolume=255
}
