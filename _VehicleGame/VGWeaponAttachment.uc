class VGWeaponAttachment extends WeaponAttachment;


// player animation specification
var() bool bHeavy;
var() bool bRapidFire;
var() bool bAltRapidFire;

// muzzle flash
var() class<MuzzleFlash> MuzFlashClass;
var() bool bFlashForPrimary;
var() bool bFlashForAlt;
var() bool bFlashLight;
var MuzzleFlash MuzFlash;

var() class<AltMuzzleFlash> AltMuzFlashClass;
var AltMuzzleFlash AltMuzFlash;

//XJ
// static mesh dummy points or bone references
var	Name					MuzzleRef;
var	Name					SFXRef1;
var	Name					SFXRef2;
// backup if no dummy point for muzzle
var	vector	MuzzleOffset;
var	rotator	MuzzleRotation;

//var	class<Actor>	TracerClass;

simulated function PostNetBeginPlay()
{
	//XJ don't have xPawn, have VGPawn
    if (Instigator != None && VGPawn(Instigator) != none)
    {
        VGPawn(Instigator).SetVGWeaponAttachment(self);
    }
}

simulated function Destroyed()
{
    if (MuzFlash != None)
        MuzFlash.Destroy();
    if (AltMuzFlash != None)
        AltMuzFlash.Destroy();
    Super.Destroyed();
}

simulated event ThirdPersonEffects()
{
    //local Rotator R;
	//local vector v;

    if (Level.NetMode == NM_DedicatedServer || Instigator == None)
        return;

    if (FlashCount == 0)
    {
        bDynamicLight = false;
		if(AltMuzFlash != none) {
			AltMuzFlash.StopFlash();
		}
    }
    if (FlashCount > 0 && MuzFlashClass != None)
    {
        if (FiringMode == 0 && bFlashForPrimary || FiringMode == 1 && bFlashForAlt)
        {
            if (MuzFlash == None)
            {
                MuzFlash = Spawn(MuzFlashClass);
				AttachToWeaponAttachment(MuzFlash, MuzzleRef);
            }
            FlashFlash(FiringMode);
        }
    }
	else if(FlashCount > 0 && AltMuzFlashClass != none)
    {
		if(FiringMode == 0 && bFlashForPrimary || FiringMode ==1 && bFlashForAlt)
        {
			if(AltMuzFlash == None || AltMuzFlash.bOnceOnly)
            {
				if(AltMuzFlash != none)
                {
					AltMuzFlash.Destroy();
					AltMuzFlash = none;
				}
				AltMuzFlash = Spawn(AltMuzFlashClass);
				AttachToWeaponAttachment(AltMuzFlash, MuzzleRef);
			}

			FlashFlash(FiringMode);
		}
	}
}

simulated function FlashFlash(byte mode)
{
	if(AltMuzFlash != none) {
		AltMuzFlash.StartFlash();
	}

	if(MuzFlash != none)
		MuzFlash.Flash(mode);

    if (bFlashLight && !Level.bDropDetail && Level.bHighDetailMode)
        bDynamicLight = true;
}

//XJ get muzzle of weapon
simulated function GetMuzzle(out vector vect, out rotator rot)
{
	local Coords coords;
	if(DrawType == DT_StaticMesh)
	{
		if(!GetAttachPoint(MuzzleRef,vect,rot))
		{
			vect = MuzzleOffset;
			rot = MuzzleRotation;
		}
	}
	if(DrawType == DT_Mesh)
	{
		coords = GetBoneCoords(MuzzleRef);
		rot = GetBoneRotation(MuzzleRef);
		rot -= Rotation;

		vect = (coords.Origin - Location) << Rotation;
	}
}

simulated function vector GetMuzzleLocation()
{
	local vector MuzOffset;
	local rotator MuzRotation;

	GetMuzzle(MuzOffset, MuzRotation);
	return (MuzOffset >> Rotation) + Location;
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
			GetMuzzle(vect, rot);
		}
		actor.SetBase(self);
		actor.SetRelativeLocation(vect);
		actor.SetRelativeRotation(rot);
	}
}

// use by hud for drawing crosshairs
simulated function Rotator GetAttachmentRotation()
{
	if(bHasWeaponBone)
		return GetBoneRotation('Weapon');
	else
		return Rotation;
}

defaultproperties
{
     MuzzleRef="FX1"
     SFXRef1="FX2"
     SFXRef2="FX3"
     DrawType=DT_StaticMesh
     AmbientGlow=50
}
