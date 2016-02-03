/*
 WeaponDynLight.uc
 Desc: Light that illuminates weapon bumps when the muzzle flash is on. It has to be attaches to a weapon
	   bone.
 Author: Matthieu
 */
class WeaponDynLight extends DynamicLight
    native;


simulated function PostBeginPlay()
{
	AddLightTag('FPWEAPON');
	Super.PostBeginPlay();
}

defaultproperties
{
     LightBrightness=0.000000
     LightRadius=20.000000
     LightEffect=LE_QuadraticNonIncidence
     RemoteRole=ROLE_None
     bMatchLightTags=True
     bNoDelete=False
}
