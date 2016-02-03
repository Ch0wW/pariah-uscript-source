class VehicleWeapon extends VGWeapon
	abstract;

// 0=small, 1=large... currently only the two sizes
// corresponds to the size of the mount
//var		int					WeaponSize;
//var		WeaponMount			WeaponMount;
var		Weapon				PreviousWeapon;

/* Vehicle Only stuff */
var Actor ThirdPersonActor2;	// a second third person actor (for the bogie dirver gun)
var () Name WeaponMountName[3];
var class<InventoryAttachment> AttachmentClass2;

var int whichFiredLast;

replication
{
	reliable if(Role == ROLE_Authority)
		ThirdPersonActor2;
}

simulated function OutOfAmmo()
{
}

// the starting location of any projectiles
// for vehicles all based on 3rd person
simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
	local vector vect;
	local rotator rot;

	if(whichFiredLast == 0 && ThirdPersonActor2 != none) {
		whichFiredLast = 1;
		VGWeaponAttachment(ThirdPersonActor2).GetMuzzle(vect,rot);
//		log("TPA2 vect = "$vect$", rot = "$rot);
		return (ThirdPersonActor2.Location + vect.X * X + vect.Y * Y + vect.Z * Z);
	}

	if(ThirdPersonActor == none)
		return (Owner.Location + vect.X * X + vect.Y * Y + vect.Z * Z);

	whichFiredLast = 0;
	VGWeaponAttachment(ThirdPersonActor).GetMuzzle(vect,rot);
//	log("TPA vect = "$vect$", rot = "$rot);
	return (ThirdPersonActor.Location + vect.X * X + vect.Y * Y + vect.Z * Z);
}
/*
function byte BestMode()
{
	//XJ: all weapons only use primairy fire mode except defaults which only use secondary
	//note: WeaponSize == 1 idicates default weapon.
	if(WeaponSize == 1)
		return 1;
	return 0;
}
*/

simulated function Destroyed()
{
	if ( ThirdPersonActor != None )
	{
		ThirdPersonActor.Destroy();
		ThirdPersonActor = None;
	}
	if ( ThirdPersonActor2 != None )
	{
		ThirdPersonActor2.Destroy();
		ThirdPersonActor2 = None;
	}
	Super.Destroyed();
}

function DropFrom(vector StartLocation)
{
	if ( ThirdPersonActor != None )
	{
		ThirdPersonActor.Destroy();
		ThirdPersonActor = None;
	}
	if ( ThirdPersonActor2 != None )
	{
		ThirdPersonActor2.Destroy();
		ThirdPersonActor2 = None;
	}
	Super.DropFrom(StartLocation);
}

simulated static function AttachActorTo(Actor BaseActor, Actor Attachment, vector offset, rotator rotation)
{
    //log("Attaching:"@BaseActor@Attachment@offset@rotation);
	Attachment.SetBase(BaseActor);
	Attachment.SetRelativeLocation(offset);
	Attachment.SetRelativeRotation(rotation);
}

// don't need to Attach/Detach from vehicles right now.
simulated function AttachToPawn(Pawn P) 
{
	local vector v;
	local rotator r;
	if(P.IsA('VGVehicle'))
	{
		if ( ThirdPersonActor == None )
		{
			ThirdPersonActor = Spawn(AttachmentClass,self);
			InventoryAttachment(ThirdPersonActor).InitFor(self);
		}

		if(ThirdPersonActor != none) 
		{
			if(!P.GetAttachPoint(WeaponMountName[0], v,r) )
			{
				P.GetAttachPoint(VGVehicle(P).WeaponMountName[0], v, r);
            }
            AttachActorTo(P, ThirdPersonActor, v, r);
		}

		if(ThirdPersonActor2 == None && AttachmentClass2 != none) 
		{
			ThirdPersonActor2 = Spawn(AttachmentClass2, self);
			InventoryAttachment(ThirdPersonActor2).InitFor(self);
		}

		if(ThirdPersonActor2 != none) 
		{
			P.GetAttachPoint(WeaponMountName[1], v, r);
			AttachActorTo(P, ThirdPersonActor, v, r);
		}
	}
}

//////////////
//Animation and Rendering
//don't need any animation, or first person rendering.

simulated event RenderOverlays( canvas Canvas )
{
	// XJ: it's important that the location and rotation of the
	// weapon still be correct.
	if(Instigator != none)
	{
		SetLocation( Instigator.Location );
		SetRotation( Instigator.GetViewRotation() );
	}
}
simulated function DrawCrossHair( canvas Canvas){}
simulated function DrawMuzzleFlash(Canvas Canvas){}

simulated function PlayThirdAnim(name Anim, optional float AnimRate, optional float TweenTime, optional int Channel)
{
	if(ThirdPersonActor!=None && ThirdPersonActor.DrawType==DT_Mesh && ThirdPersonActor.HasAnim(Anim))
	{
		ThirdPersonActor.PlayAnim(Anim,AnimRate,TweenTime,Channel);
		return;
	}
}

simulated function LoopThirdAnim(name Anim, optional float AnimRate, optional float TweenTime, optional int Channel)
{
	if(ThirdPersonActor!=None && ThirdPersonActor.DrawType==DT_Mesh && ThirdPersonActor.HasAnim(Anim))
	{
		ThirdPersonActor.LoopAnim(Anim,AnimRate,TweenTime,Channel);
	}
}
simulated function BringUp(optional Weapon PrevWeapon)
{
	if(ClientState == WS_None)
		return;
    if (ClientState == WS_Hidden && ThirdPersonActor != none)
    {
		GotoState('Hidden');
        PlayOwnedSound(SelectSound, SLOT_Interact, 0.5,,,, false);
		PlayThirdAnim(SelectAnim, SelectAnimRate);
        ClientState = WS_BringUp;
        SetTimer(0.3, false);
    }
	else if(ThirdPersonActor == none)
	{
		PreviousWeapon=PrevWeapon;
		GotoState('PendingBringUp');
	}
}

simulated function bool PutDown()
{
    local int Mode;

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
        for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
        {
            if (FireMode[Mode] != none && FireMode[Mode].bIsFiring)
                ClientStopFire(Mode);
        }

        if (ClientState != WS_BringUp)
            PlayThirdAnim(PutDownAnim, PutDownAnimRate, 0.0);

        ClientState = WS_PutDown;

        SetTimer(0.3, false);
    }
    return true;
}


//function AnimEnd(int channel) {}
simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

    if (ClientState == WS_ReadyToFire)
    {
        if (FireMode[0] != none && anim == FireMode[0].FireAnim && ThirdPersonActor.HasAnim(FireMode[0].FireEndAnim)) // rocket hack
        {
            PlayThirdAnim(FireMode[0].FireEndAnim, FireMode[0].FireEndAnimRate, 0.0);
        }
        else if (FireMode[1] != none && anim == FireMode[1].FireAnim && ThirdPersonActor.HasAnim(FireMode[1].FireEndAnim))
        {
            PlayThirdAnim(FireMode[1].FireEndAnim, FireMode[1].FireEndAnimRate, 0.0);
        }
        else if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
        {
            PlayIdle();
        }
    }
}


simulated function PlayIdle()
{
	LoopThirdAnim(IdleAnim, IdleAnimRate, 0.2);
}

state PendingBringUp
{
	simulated function Tick(float dt)
	{
		if(ThirdPersonActor != none)
			BringUp(PreviousWeapon);
	}
}

defaultproperties
{
     bOnlyTargetVehicles=True
     bIsVehicleWeapon=True
     bAlwaysRelevant=True
     bReplicateMovement=True
     bOnlyDirtyReplication=False
}
