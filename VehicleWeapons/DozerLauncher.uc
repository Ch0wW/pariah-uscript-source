class DozerLauncher extends VehicleWeapon;

// this is how much havok impulse is applied to the vehicle per rocket fired
//
const havokImpulseStrengthPerRocket = 100000;

var vector RocketStart;
var rotator RocketDir;
var bool bValidRocketStart;

replication
{
	reliable if(Role < ROLE_Authority)
		SpawnRocket;
}

function projectile SpawnRocket(Vector Start, int yaw, int pitch)
{
    local Projectile p;
	local Rotator Dir;

	Dir.yaw = yaw;
	Dir.pitch = pitch;

	if(Level.NetMode == NM_Client)
		return none;

	p = Spawn(class'VehicleWeapons.DozerGrenade',,, Start, Dir);

    if( p == None )
        return None;

	p.ProjOwner = Instigator.Controller;
	p.Instigator = Instigator;
    p.Damage = Ceil(p.Damage);
    
	if ( Role == ROLE_Authority ) {
		VGHavokRaycastVehicle(ThirdPersonActor.Base).HAddImpulse(
			Normal(p.Velocity)*(-havokImpulseStrengthPerRocket),
			ThirdPersonActor.Location
		);
	}

	return p;
}

function float GetAIRating()
{
	return AIRating;
}

defaultproperties
{
     WeaponMountName(0)="WP1"
     AIRating=0.400000
     CurrentRating=0.400000
     FireModeClass(0)=Class'VehicleWeapons.DozerLauncherFire'
     bCanThrow=False
     bDontDrawVehicleReticle=True
     bHasWeaponBone=True
     AttachmentClass=Class'VehicleWeapons.DozerLauncherAttachment'
     ItemName="Dozer Launcher"
     InventoryGroup=6
     BarIndex=6
     bDrawingFirstPerson=True
     bHidden=False
     bOnlyOwnerSee=False
     bOnlyRelevantToOwner=False
}
