//=============================================================================
//=============================================================================
class BogieLauncher extends VehicleWeapon;

var vector RocketStart;
var rotator RocketDir;
var bool bValidRocketStart;

replication
{
	reliable if(Role < ROLE_Authority)
		SpawnRocket;
}

simulated function Rotator GetAimRot(VehiclePlayer vp)
{
    local Vector StartTrace;
    local Vector HitLocation, HitNormal;
    local Actor Other;
	local rotator rot;

	StartTrace = VGWeaponAttachment(ThirdPersonActor).GetMuzzleLocation();

	if(vp != None)
    {
        rot = VGWeaponAttachment(ThirdPersonActor).GetAttachmentRotation();

		Other = Trace(HitLocation, HitNormal, StartTrace+2000*Vector(rot), StartTrace, true);

        if(Other == ThirdPersonActor.Base)
        {
            rot.Pitch = 0; 
        }
    }

    return rot;
}

function projectile SpawnRocket(Vector Start, int yaw, int pitch)
{
    local Projectile p;
	local Rotator Dir;

	if(Role < ROLE_Authority)
		return None;

    Dir.yaw = yaw;
	Dir.pitch = pitch;

	p = Spawn(class'VehicleWeapons.BogieRocket',,, Start, Dir);

    if( p == None )
        return None;

	p.ProjOwner = Instigator.Controller;
	p.Instigator = Instigator;
    p.Damage = Ceil(p.Damage);// * DamageAtten);

    return p;
}

function float GetAIRating()
{
	return AIRating;
}

simulated function vector GetFireStart(vector X, vector Y, vector Z)
{
    return(VGWeaponAttachment(ThirdPersonActor).GetMuzzleLocation());
}

defaultproperties
{
     WeaponMountName(0)="WP3"
     AIRating=0.400000
     CurrentRating=0.400000
     IdleAnim="Breathe"
     FireModeClass(0)=Class'VehicleWeapons.BogieLauncherFire'
     FireModeClass(1)=Class'VehicleWeapons.BogieLauncherMGFire'
     bCanThrow=False
     bHasWeaponBone=True
     AttachmentClass=Class'VehicleWeapons.BogieLauncherAttachment'
     ItemName="Bogie Launcher"
     InventoryGroup=6
     BarIndex=6
     bDrawingFirstPerson=True
     bHidden=False
     bOnlyOwnerSee=False
     bOnlyRelevantToOwner=False
}
