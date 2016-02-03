class PersonalWeaponAttachment extends VGWeaponAttachment;

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	AddLightTag( 'TPWEAPON' );
	if ( Level.bThirdPersonWeaponsExclusivelyLit )
	{
		bMatchLightTags=True;
	}
}

simulated event ThirdPersonEffects()
{
	Super.ThirdPersonEffects();

    if (Level.NetMode == NM_DedicatedServer || Instigator == None)
        return;

    if (FlashCount == 0)
    {
        xPawn(Instigator).StopFiring();
    }
    else
    {
		//log("thirdpersoneffects start firing");
		xPawn(Instigator).StartFiring(bHeavy, bRapidFire,WeaponType);
    }
}

simulated function AttachToWeaponAttachment(Actor actor, name Reference)
{
	local vector vect;
	local rotator rot;
	// if it's a mesh it's reference must be a bone
	if(DrawType == DT_Mesh)
	{
		if(!AttachToBone(actor, Reference))
			log("XJ: AttachToBone failed, actor: "$actor$" bone: "$Reference);
		actor.SetRelativeLocation(actor.default.RelativeLocation);
		actor.SetRelativeRotation(actor.default.RelativeRotation);
	}
	// if it's a static mesh, assume reference is a dummy point
	else if(DrawType == DT_StaticMesh)
	{
		if(!GetAttachPoint(Reference,vect,rot))
		{
			//if no reference, the only option is the Muzzle
			GetMuzzle(vect, rot);
		}
		//attaching directly to the attachment doesn't work need to base on the bone the attachment uses
		if(Instigator != none)
			Instigator.AttachToBone(Actor, AttachmentBone); // attach flash to the same bone that this attachment is attached to
		actor.SetRelativeLocation(vect);
		actor.SetRelativeRotation(rot);
	}
}

defaultproperties
{
}
