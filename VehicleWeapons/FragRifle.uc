class FragRifle extends PersonalWeapon;

simulated function WECLevelUp(optional bool bNoMessage)
{
	Super.WECLevelUp(bNoMessage);

    //-Servo Reloader (Fast reload)
    //-Magneto Concentrator (Frag pieces that fly in to target)
    //-Titanium Magnetos (Frag pieces sometimes survive even if they kill a target, last a bit longer)

	switch( WECLevel )
	{
		case 1:
			ReloadTime = default.ReloadTime * 0.5;
			ReloadAnim = 'Reload'; // !! needs new anim
			ReloadAnimRate = default.ReloadAnimRate / 0.5;
			break;
		case 2:
		    // weaponfire class handles this		
			break;
		case 3:
		    // weaponfire class handles this			
			break;
	}
}

// client
simulated function ClientAdjustPlayerDamage(int Damage)
{
}


//Note: The super function plays the end animation which we don't want to handle in AnimEnd
simulated event StopFire( int Mode )
{
    FireMode[Mode].bIsFiring = false;
    FireMode[Mode].StopFiring();
    if (!FireMode[Mode].bFireOnRelease)
        ZeroFlashCount(Mode);
}

simulated function int GetMagAmount()
{
    local AmmoClip Clip;
    
    Clip = AmmoClip(Ammo[0]);
    
    if(Clip != None )
    {
        return(Clip.MagAmount);
    }
    else
    {
        return(0);
    }
}

simulated function PlayIdle()
{
	switch(GetMagAmount())
	{
		case 0:
		case 1:
			LoopAnim('Breathe0', IdleAnimRate, 0.2);
			break;
		case 2:
			LoopAnim('Breathe1', IdleAnimRate, 0.2);
			break;
		case 3:
		case 4:
		case 5:
		case 6:
		    LoopAnim(IdleAnim, IdleAnimRate, 0.2);
			break;
	}
}

simulated function PlayFireAnim(name Sequence, optional float Rate, optional float TweenTime, optional int Channel)
{
	switch(GetMagAmount()) 
	{
		case 0:
			break;
		case 1:
			PlayAnim('Fire0', Rate, TweenTime, Channel);
			break;
		case 2:
			PlayAnim('Fire1', Rate, TweenTime, Channel);
			break;
		case 3:
			PlayAnim('Fire2', Rate, TweenTime, Channel);
			break;
		case 4:
		case 5:
		case 6:
			PlayAnim('Fire', Rate, TweenTime, Channel);
			break;
	}
}

simulated function PlayPutDown()
{
	switch(GetMagAmount())
	{
		case 0:
		case 1:
			PlayAnim('Down0', PutDownAnimRate, 0.0);
			break;
		case 2:
			PlayAnim('Down1', PutDownAnimRate, 0.0);
			break;
		case 3:
		case 4:
		case 5:
		case 6:
            PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
			break;
	}
}

simulated function bool PutDown()
{
    local PlayerController PC;
    
    PC = PlayerController(Instigator.Controller);
    
    if( PC != None )
    {
        PC.bNewCamShake = false; //return to normal shake (xmatt)
    }

	if( Super.PutDown() )
	{
		PlayPutDown();
		return true;
	}

	return false;
}

simulated function LowerWeapon()
{
    local int Mode;

	if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
	{
        if (Instigator.IsLocallyControlled())
        {
            for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
            {
                if (FireMode[Mode] != none && FireMode[Mode].bIsFiring)
                    ClientStopFire(Mode);
            }

            if (ClientState != WS_BringUp && HasAnim(PutDownAnim))
                PlayPutDown();
        }
        ClientState = WS_Lowered;
	}
}

simulated function PlaySelect()
{
	switch(GetMagAmount())
	{
		case 0:
		case 1:
			PlayAnim('Up0', SelectAnimRate, 0.0);
			break;
		case 2:
			PlayAnim('Up1', SelectAnimRate, 0.0);
			break;
		case 3:
		case 4:
		case 5:
		case 6:
            PlayAnim(SelectAnim, SelectAnimRate, 0.0);
			break;
	}
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    local PlayerController PC;
    
    if (ClientState == WS_Hidden)
    {
		if(PrevWeapon != none)
		{
			PlayOwnedSound(SelectSound, SLOT_Interact, 0.5,,,, false);

			if (Instigator.IsLocallyControlled())
			{
				if (HasAnim(SelectAnim))
					PlaySelect();
			}
		}
        ClientState = WS_BringUp;
        SetTimer(0.3, false);
    }
    
    PC = PlayerController(Instigator.Controller);
    
    if( PC != None )
    {
        PC.bNewCamShake = true; //use new cam shake (xmatt)
    }
    Super.BringUp(PrevWeapon);
}

simulated function RaiseWeapon()
{
    if (ClientState == WS_Lowered)
    {
		PlayOwnedSound(SelectSound, SLOT_Interact, 0.5,,,, false);
		if (Instigator.IsLocallyControlled())
		{
			if (HasAnim(SelectAnim))
				PlaySelect();
		}
		if(Instigator.PendingWeapon !=none)
			Timer();
		else
	        SetTimer(0.3, false);
    }
}

defaultproperties
{
     ReloadTime=4.000000
     WeaponDynLightRelPos=(X=15.000000,Y=-5.000000)
     WecAttachDescs(0)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.030000,WecRelativeLoc=(X=-33.000000,Y=-2.500000,Z=5.500000),WecRelativeRot=(Pitch=12000,Yaw=16384),AttachPoint="FX1")
     WecAttachDescs(1)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.030000,WecRelativeLoc=(X=-38.500000,Y=-2.500000,Z=5.500000),WecRelativeRot=(Pitch=12000,Yaw=16384),AttachPoint="FX1")
     WecAttachDescs(2)=(WecMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WecLight',DrawScale=0.030000,WecRelativeLoc=(X=-43.000000,Y=-2.500000,Z=5.500000),WecRelativeRot=(Pitch=12000,Yaw=16384),AttachPoint="FX1")
     WeaponMessageClass=Class'VehicleWeapons.FragRifleMessage'
     BulletsStartingOffsetX=-10
     BulletsStartingOffsetY=8
     BulletsPerRow=6
     BulletSpaceDX=12
     BulletSpaceDY=10
     CrosshairIndex=2
     SelectAnimRate=1.000000
     PutDownAnimRate=2.000000
     BulletsScale=1.100000
     AIRating=0.400000
     CurrentRating=0.400000
     AutoAimFactor=1.000000
     DisplayFOV=50.000000
     AmmoClipTexture=Texture'PariahInterface.HUD.Assets'
     BulletTexture=Texture'PariahInterface.HUD.Assets'
     SelectSound=Sound'PariahWeaponSounds.FR_Select'
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.FragRifleFireTrace'
     BulletCoords=(X1=76,Y1=29,X2=85,Y2=46)
     EffectOffset=(X=80.000000,Y=16.000000,Z=-9.000000)
     bCanThrow=False
     BobDamping=1.650000
     IconMaterial=Texture'PariahInterface.HUD.Assets'
     PickupClass=Class'VehicleWeapons.FragRiflePickup'
     AttachmentClass=Class'VehicleWeapons.FragRifleAttachment'
     PlayerViewOffset=(X=12.000000,Y=3.500000,Z=-18.000000)
     PlayerViewPivot=(Pitch=250,Yaw=-500)
     IconCoords=(X1=320,Y1=128,X2=383,Y2=191)
     ItemName="Frag Rifle"
     InventoryGroup=3
     BarIndex=11
     bExtraDamping=True
     Mesh=SkeletalMesh'PariahPlayerWeaponAnimations.FragRifle'
}
