class BoneSaw extends PersonalWeapon;

var bool bBladeScaling;
var float ScaleTime;
var float CutTime;

replication {
	reliable if(Role < ROLE_Authority)
		ServerSlash;
}

// skip the BONE SAW when cycling the weapons
simulated function Weapon PrevWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.PrevWeapon(CurrentChoice,CurrentWeapon);
}

simulated function Weapon NextWeapon(Weapon CurrentChoice, Weapon CurrentWeapon)
{
    if ( Inventory == None )
        return CurrentChoice;
    else
        return Inventory.NextWeapon(CurrentChoice,CurrentWeapon);
}

simulated function float RateSelf()
{
	return -2.0;
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

	if(anim == 'Fire01' || anim == 'Fire02' || anim == 'Fire03')
		LoopAnim(IdleAnim);

	if(anim == 'PutDown' ) {
		if(ClientState != WS_Lowered)
			Instigator.Controller.StopMelee();
		SetBoneScale(0, 1.0, 'Blade');
		bBladeScaling = false;
		bDoMelee = false;
	}
}

simulated function LowerWeapon()
{
    Super.LowerWeapon();
    bBladeScaling = true;
    ScaleTime = 0;
}

simulated function RaiseWeapon()
{
    Super.RaiseWeapon();
	SetBoneScale(0, 1.0, 'Blade');
	bBladeScaling = false;
}

simulated function bool PutDown()
{
    local int Mode;
    
    log("PutDown: "@ClientState);

    if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
    {
        if (Instigator.PendingWeapon == None || !Instigator.PendingWeapon.bForceSwitch)
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if (FireMode[Mode] != none && FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring)
                    return false;
            }
        }

        if (Instigator.IsLocallyControlled())
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if (FireMode[Mode] != none && FireMode[Mode].bIsFiring)
                    ClientStopFire(Mode);
            }

			if (ClientState != WS_BringUp && HasAnim(PutDownAnim)) {
				if(bDoMelee) {
	                PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
					bBladeScaling = true;
					ScaleTime = 0;
					return false;
				}
			}
        }

        ClientState = WS_PutDown;

        SetTimer(0.3, false);
    }
    return true; // return false if preventing weapon switch
}

simulated function Tick(float dt)
{
	Super.Tick(dt);

	if(bBladeScaling) {
		ScaleTime += dt;
		if(ScaleTime > CutTime) {
			SetBoneScale(0, 0, 'Blade');
			bBladeScaling = false;
			bDoMelee = false;
		}
	}
}

function ServerSlash()
{
	if(FireMode[0] != none)
		FireMode[0].ModeDoFire();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	local PlayerController pc;
	
	// sjs - workaround for picking up this weapon when I only have the healing tool (chapter1)
	pc = PlayerController(Instigator.Controller);
	if(pc.LastWeaponGroup == 0)
	{
		pc.LastWeaponGroup = pc.HealingToolGroup;
	}
	
    if (ClientState == WS_Hidden)
    {
		if(PrevWeapon != none)
		{
			PlayOwnedSound(SelectSound, SLOT_Interact, 0.5,,,, false);

			if (Instigator.IsLocallyControlled())
			{
				if(HasAnim(SelectAnim) ) {
					if(FireMode[0] != none) {
						bDoMelee = true;
						FireMode[0].ModeDoFire();
						if(Role < ROLE_Authority)
							ServerSlash();
					}
					else
			            PlayAnim(SelectAnim, SelectAnimRate, 0.0);
				}
			}
		}
        ClientState = WS_BringUp;
        SetTimer(0.3, false);
    }

	SetBoneScale(0, 1.0, 'Blade');
	bBladeScaling = false;
	Super.BringUp(PrevWeapon);
}

defaultproperties
{
     CutTime=0.550000
     CrosshairIndex=-1
     SelectAnimRate=1.000000
     PutDownAnimRate=0.600000
     AIRating=0.200000
     DisplayFOV=60.000000
     SelectAnim="Fire01"
     PutDownAnim="PutDown"
     FireModeClass(0)=Class'VehicleWeapons.BoneSawFire'
     FireModeClass(1)=None
     bMeleeWeapon=True
     bCanThrow=False
     PickupClass=Class'VehicleWeapons.BoneSawPickup'
     AttachmentClass=Class'VehicleWeapons.BoneSawAttachment'
     PlayerViewOffset=(X=15.000000,Y=5.000000,Z=-19.000000)
     PlayerViewPivot=(Pitch=375)
     ItemName="Bonesaw"
     InventoryGroup=14
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.BoneSaw'
     bReplicateInstigator=True
}
