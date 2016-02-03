class PersonalWeapon extends VGWeapon
	abstract;

var vector WeaponDynLightRelPos;//Relative position of the weapon dynamic light
var bool bTurnedOnDynLight;		//Is the weapon dynamic light turned on
var float LightIntensityTimer;	//Timer for the weapon dynamic light flashing

var array<WeaponFire> Modes;	// available fire modes
var int CurrentMode;			// current fire mode

var(Zoom) Sound sndZoomIn;          // mjm
var(Zoom) Sound sndZoomOut;         // mjm
var(Zoom) Texture ZoomEdge;

var() float ReloadTime;
var() float ReloadAnimRate;
var() Name  ReloadAnim;
var() Sound ReloadSound;
var() Sound WecUpSound;

struct WecAttachmentDesc
{
    var() Material      Skin;
    var() StaticMesh    WecMesh;
    var() float         DrawScale;
    var() Vector        WecRelativeLoc;
    var() Rotator       WecRelativeRot;
    var() Name          AttachPoint;
};

var() WecAttachmentDesc WecAttachDescs[3];
var() Actor             WecAttachmentActor[3];
var() Material          WecNotActive;

var int                 WECCount;
var int                 ClientWECLevel;

replication
{
    unreliable if( Role==ROLE_Authority )
		WECCount;
}

simulated function PostNetReceive()
{
    local int i;
    local int DesiredWecLevel;

    if(ClientWECLevel != WecLevel)
    {
        //log("PostNetReceive:" @ WecLevel);
        DesiredWecLevel = WecLevel; // bit of a hack because WecLevel gets clobbered in WECLevelUp
        WecLevel = ClientWECLevel;
       	for(i = WecLevel; i < DesiredWeclevel; i++)
	    {
		    WECLevelUp();
	    }
    }
}

simulated function SetupWecAttachments()
{
    local int index;

    if(Level.NetMode == NM_DedicatedServer)
    {
		// log( "Spawning WEC Attachments on Server", 'Error' );
        return;
    }

    for(index = 0; index < 3; ++index) // set '3' to WecLevel if you don't want wec attachments for inactive levels
    {
        if(WecAttachDescs[index].WecMesh == None)
        {
            continue;
        }
        if(WecAttachmentActor[index] == None)
        {
            WecAttachmentActor[index] = Spawn(class'InventoryAttachment', self);
        }
        WecAttachmentActor[index].SetDrawScale(WecAttachDescs[index].DrawScale);
        if(WecAttachDescs[index].Skin != None)
        {
            WecAttachmentActor[index].SetSkin(0, WecAttachDescs[index].Skin);
        }
        WecAttachmentActor[index].SetDrawType(DT_StaticMesh);
        WecAttachmentActor[index].SetStaticMesh(WecAttachDescs[index].WecMesh);
        WecAttachmentActor[index].SetRelativeLocation(WecAttachDescs[index].WecRelativeLoc);
        WecAttachmentActor[index].SetRelativeRotation(WecAttachDescs[index].WecRelativeRot);
        AttachToBone(WecAttachmentActor[index], WecAttachDescs[index].AttachPoint);
        if(index < WecLevel)
        {
            WecAttachmentActor[index].SetSkin(1, None);
        }
        else
        {
            WecAttachmentActor[index].SetSkin(1, WecNotActive);
        }
    }
}

simulated function RemoveWecAttachments()
{
    local int index;
    
    for(index = 0; index < WecLevel; ++index)
    {
        if(WecAttachmentActor[index] != None)
        {
            WecAttachmentActor[index].Destroy();
            WecAttachmentActor[index] = None;
        }
    }
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

simulated event RenderOverlays( Canvas Canvas )
{
    local float halfScreenY;
    local float ZoomMult;
    local PlayerController PC;

    if(Instigator == None || Instigator.Controller == None)
    {
        return;
    }

    Super.RenderOverlays(Canvas);
    PC = PlayerController(Instigator.Controller);    
    
    // drawing 'universal zoom' edge darkening
	ZoomMult = (1 - (PC.FOVAngle / PC.DefaultFOV)) * 3;
	
    if(PC.FOVAngle == PC.DefaultFOV)
	{        
		return;
	}
	
	// render some edge darkening
    Canvas.Style = ERenderStyle.STY_Alpha;
    Canvas.DrawColor.R = 0;   
	Canvas.DrawColor.G = 0;
	Canvas.DrawColor.B = 0;
	Canvas.DrawColor.A = FClamp(255 * ZoomMult, 0, 255);

    halfScreenY = Canvas.SizeY * 0.3; // less that the full screen

    // Corners    
    Canvas.SetPos(0,halfScreenY); // upper left
    Canvas.DrawTile( ZoomEdge, Canvas.SizeX, -halfScreenY, 0.0, 0.0, 64, 64 ); // !! hardcoded size


    Canvas.SetPos(0,Canvas.SizeY-halfScreenY); // lower left
    Canvas.DrawTile( ZoomEdge, Canvas.SizeX, halfScreenY, 0.0, 0.0, 64, 64 ); // !! hardcoded size
}

// this supports the virus power functionality so it needn't (and shouldn't) do anything outside of the VirusPower weapon
function int AbsorbEnergy()
{
	return 0;
}

simulated event ClientStartFire(int mode)
{
    if (!IsInState('Reload') && FireMode[mode].IsA('ZoomFire'))   // 1 = secondary weapon
    {        
        FireMode[mode].bIsFiring = true;
		if(Instigator.Controller.IsA('PlayerController'))
        {
            if (PlayerController(Instigator.Controller).bZoomed)
            {                
                PlaySound(sndZoomOut, SLOT_Interact);
            }
            else
            {
                PlaySound(sndZoomIn, SLOT_Interact);                
            }
			PlayerController(Instigator.Controller).ClientToggleZoom();
		}
    }
	Super.ClientStartFire(mode);
}


simulated event ClientStopFire(int mode)
{
    if (FireMode[mode].IsA('ZoomFire'))
    {        
        FireMode[mode].bIsFiring = false;
		if(Instigator.Controller.IsA('PlayerController'))
        {
			PlayerController(Instigator.Controller).ClientStopZoom();
		}
	}
	Super.ClientStopFire(mode);
}

simulated function bool PutDown()
{
	if(Instigator.Controller.IsA('PlayerController') && PlayerController(Instigator.Controller).bZoomed) 
	{
		PlayerController(Instigator.Controller).ClientEndZoom();
		PlayerController(Instigator.Controller).bNewCamShake = false;
	}
	if(IsInState('Reload'))
	{
	    GotoState('');
    }
    RemoveWecAttachments();
    return Super.PutDown();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp( PrevWeapon );
    if(Instigator.IsLocallyControlled())
    {
    	SetupWeaponDynLight();
	    SetupWecAttachments();
	    VGWeaponFire(FireMode[0]).SetCamSpring();
    }
    if(Ammo[0] != None && Ammo[0].CheckReload())
    {
        DoReload();
    }
}

simulated function SetupWeaponDynLight() //xmatt
{
	local PlayerController PC;
	PC = PlayerController(Instigator.Controller);

	if ( PC == None || PC.MuzzleFlashLight == None )
	{
		return;
	}

	//Start with no brightness
	PC.MuzzleFlashLight.LightBrightness = 0;

	//Some weapon have 'Tip' as the reference, some have 'FX1'
	//Note: All weapons will use 'FX1' eventually

	if( IsA('VGRocketLauncher')  )
	{
		AttachToBone( PC.MuzzleFlashLight, 'RocketLauncher' );

	}
	else
	{
		if( !AttachToBone( PC.MuzzleFlashLight, 'FX1' ) )
		{
			if( !AttachToBone( PC.MuzzleFlashLight, 'Tip' ) )
				log( "Couldn't attach MUZZLE flash LIGHT", 'Error' );
		}
	}

	//Set the relative position of the light
	//Note: Must be done after bone attachment
	PC.MuzzleFlashLight.SetRelativeLocation( WeaponDynLightRelPos );
}

function DropEnergy(Controller Killer)
{
	local AmmoPack tempPickup;

	if (Level.Game != None && Level.Game.bSingleplayer)
		tempPickup = Spawn(class'VehicleGame.AmmoPack',,,Owner.Location, rot(0, 0, 0) );
	else
		tempPickup = Spawn(class'VehicleGame.MPAmmoPack',,,Owner.Location, rot(0, 0, 0) );
	tempPickup.bPickupOnce = true;
	tempPickup.InitDroppedPickupFor(self);
	tempPickup.Killer = Killer;
}

function DropWECs(Controller Killer)
{
	local int totalWECs, i;
	local WeaponEnergyCore tempPickup;
	local class<WeaponEnergyCore> RedWEC, YellowWEC, PurpleWEC, GreenWEC;
	local vector WECVelocity;

	for(i=0;i<WECLevel;i++)
	{
		totalWECs += WECPerLevel[i];
	}
	totalWECs += WECCount;
	// drop half the wecs with a min of one
	totalWECs = Max(1,totalWECs - 1);

	RedWEC = class<WeaponEnergyCore>(DynamicLoadObject("VehiclePickups.PickupWECRed", class'Class'));
	YellowWEC = class<WeaponEnergyCore>(DynamicLoadObject("VehiclePickups.PickupWECYellow", class'Class'));
	PurpleWEC = class<WeaponEnergyCore>(DynamicLoadObject("VehiclePickups.PickupWECPurple", class'Class'));
	GreenWEC = class<WeaponEnergyCore>(DynamicLoadObject("VehiclePickups.PickupWECGreen", class'Class'));

	while(totalWECs > 0)
	{
		if(totalWECs >= GreenWEC.static.GetWECAmmount())
		{
			totalWECs -= GreenWEC.static.GetWECAmmount();
			tempPickup = Spawn(GreenWEC,,,Owner.Location,rot(0,0,0));
		}
		else if(totalWECs >= PurpleWEC.static.GetWECAmmount())
		{
			totalWECs -= PurpleWEC.static.GetWECAmmount();
			tempPickup = Spawn(PurpleWEC,,,Owner.Location,rot(0,0,0));
		}
		else if(totalWECs >= YellowWEC.static.GetWECAmmount())
		{
			totalWECs -= YellowWEC.static.GetWECAmmount();
			tempPickup = Spawn(YellowWEC,,,Owner.Location,rot(0,0,0));
		}
		else if(totalWECs >= RedWEC.static.GetWECAmmount())
		{
			totalWECs -= RedWEC.static.GetWECAmmount();
			tempPickup = Spawn(RedWEC,,,Owner.Location,rot(0,0,0));
		}
		WECVelocity = (VRand() + vect(0,0,1)) * 150;
		tempPickup.bPickupOnce = true;
		tempPickup.InitDroppedPickupFor(None);
		tempPickup.Velocity = WECVelocity;
		tempPickup.Killer = Killer;
	}
}

//push the weapon to the next WECLevel regardless of WECCount
simulated function AddSuperWEC()
{
	if(Role == ROLE_Authority)
	{
		ClientAddSuperWEC();
	}
	if(WECLevel != WECMaxLevel)
	{
		WECLevelUp();
	}
}

//implement in each weapon
simulated function WECLevelUp(optional bool playAnim)
{
	if(WECLevel >= WECMaxLevel)
		return;
	WECLevel++;
    ClientWECLevel = WECLevel;
	if(Instigator.IsLocallyControlled() && Instigator.Controller.IsA('PlayerController') && playAnim)
	{
        GotoState('AddingWec');
	}
	else
	{
        if(!IsInState('AddingWec'))
	        SetupWecAttachments();
	}
}

simulated function SetWECLevel(int level)
{
	local int i;
	for(i = WecLevel; i < level; i++)
	{
		WECLevelUp();
	}
}

simulated function ClientAddSuperWEC()
{
	if(Role < ROLE_Authority)
		AddSuperWEC();
}

simulated function bool HasAmmo()
{
	return ( (Ammo[0] != none && FireMode[0] != none && Ammo[0].HasAmmo() ) );
}

function SwitchFireMode()
{
	if(Modes.Length == 0 && FireMode[0] != none)
		Modes[0] = FireMode[0];

	CurrentMode++;
	if(CurrentMode >= Modes.Length)
		CurrentMode = 0;

	FireMode[0] = Modes[CurrentMode];
}

function AddNewFireMode(class<WeaponFire> ModeClass)
{
	local WeaponFire theMode;

	theMode = CreateNewFireMode(ModeClass);
	if(theMode != none) 
	{
		Modes[Modes.Length] = theMode;
	}
}

simulated function WeaponFire CreateNewFireMode(class<WeaponFire> ModeClass)
{
	local WeaponFire theMode;

	theMode = Spawn(ModeClass, self);
	if(theMode != none) 
	{
		theMode.ThisModeNum = 0;
		theMode.Weapon = self;
		theMode.Instigator = Instigator;
	}

	return theMode;
}

simulated function DetachLight()
{
    local PlayerController PC;
    
    PC = PlayerController(Instigator.Controller);
	if ( PC == None || PC.MuzzleFlashLight == None )
	{
		return;
	}
    PC.MuzzleFlashLight.LightBrightness = 0;
	DetachFromBone(PC.MuzzleFlashLight);
}

simulated function Destroyed()
{
	local int n;

	Super.Destroyed();

	for(n = 0; n < Modes.Length; n++) 
	{
		if(Modes[n] != none) 
		{
			Modes[n].Destroy();
			Modes[n] = none;
		}
	}
	
	for(n = 0; n < 3; ++n)
	{
	    if(WecAttachmentActor[n] != None)
	    {
	        WecAttachmentActor[n].Destroy();
	    }
	}
	
	DetachLight();
}

simulated function ManualReload()
{
	DoReload();
}

simulated function bool CanReload()
{
    local AmmoClip ac;
    
    if(IsInState('Reload'))
    {
        return(false);
    }
    
    if(Ammo[0].IsA('AmmoClip'))
    {
        ac = AmmoClip(Ammo[0]);
        if(ac.RemainingMagAmmo < ac.MagAmount && ac.AmmoAmount > 0)
        {
            return(true);
        }
        else
        {
            return(false);
        }
    }
    return(Super.CanReload());    
}

function CheckTouchingPickups()
{
    local Pickup P;
    
	ForEach Instigator.TouchingActors(class'Pickup', P)
	{
		P.Touch(Instigator);
    }
}

simulated state AddingWec
{
    simulated function EndState()
    {
        FireMode[0].EndReload();
    }
    simulated function PlayIdle()
	{
	}
Begin:
    FireMode[0].StopFiring();
    FireMode[0].BeginReload();
	PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
	Sleep(0.3);
	if(WecUpSound != None)
	{
	    PlayOwnedSound(WecUpSound);
	}
	Sleep(0.8);
	SetupWecAttachments();
	PlayAnim(SelectAnim, SelectAnimRate, 0.0);	
	if(SelectSound != None)
	{
	    PlayOwnedSound(SelectSound);
	}
    Sleep(0.3);
    PlayIdle();
	GotoState('');
}

simulated state Reload
{
    simulated function EndState()
    {
        FireMode[0].EndReload();
    }
    simulated function PlayIdle()
	{
	}
Begin:
    FireMode[0].StopFiring();
    FireMode[0].BeginReload();
    Sleep(0.3); // allow fire anim to complete
	if(ReloadSound != None)
	{
	    PlayOwnedSound(ReloadSound);
	}
	PlayAnim(ReloadAnim, ReloadAnimRate);
    Sleep(ReloadTime);
    CompletedReload();

	if(Pawn(Owner).Physics == PHYS_Ladder)
	{
        ClientState = WS_Lowered;
	}
	else
	{
	    PlayIdle();
	    CheckTouchingPickups();
	}
	GotoState('');
}

function bool HandlePickupQuery( pickup Item )
{
    local Inventory Inv;
    local Weapon    W;
    
    if(Item.IsA('AmmoPack')) // ugh - try to prevent picking this up if we're already full
    {
        Inv = self; // linked list
        while(Inv != None)
        {
            if(Inv.IsA('Weapon'))
            {
                W = Weapon(Inv);
                if(W.bAmmoFromPack && W.Ammo[0] != None && W.Ammo[0].AmmoAmount < W.Ammo[0].MaxAmmo)
                {
                    return(false); // false means you want it... sigh.
                }
            }
            Inv = Inv.Inventory;
        }
        return(true);
    }
    else
    {
        return(Super.HandlePickupQuery(Item));
    }
}

defaultproperties
{
     ReloadTime=2.500000
     ReloadAnimRate=1.000000
     sndZoomIn=Sound'PariahWeaponSounds.QuickZoomIn'
     sndZoomOut=Sound'PariahWeaponSounds.QuickZoomOut'
     ZoomEdge=Texture'PariahInterface.InterfaceTextures.MenuOptionsBackground'
     WecUpSound=Sound'PariahWeaponSounds.AddWEC'
     WecNotActive=Shader'VehicleGamePickupsTex.WEC.WecEyeOff'
     ReloadAnim="Reload"
     WECPerLevel(0)=1
     WECPerLevel(1)=2
     WECPerLevel(2)=3
     WECMaxLevel=3
     ZoomFactor=1.500000
     FireModeClass(1)=Class'VehicleGame.ZoomFire'
     bNetNotify=True
}
