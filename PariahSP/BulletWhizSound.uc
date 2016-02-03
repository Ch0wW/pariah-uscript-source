class BulletWhizSound extends Actor;

const arrayLength = 7;
var Sound BulletWhiz[7];

function PlayWhizSound(vector loc, int style)
{
    SetLocation(loc);
    if(style == 0)
    {
        PlaySound( BulletWhiz[Rand(arrayLength)],,0.6,,,,true, false);	
    }
    else if(style == 1)
    { 
        PlaySound( sound'PariahWeaponSounds.PlasmaMiss',,0.6,,,0.5 + FRand() * 1.0,true, false);	
    }
}

defaultproperties
{
     bulletWhiz(0)=Sound'PariahWeaponSounds.miss.MissWhiz'
     bulletWhiz(1)=Sound'PariahWeaponSounds.miss.MissWhiz'
     bulletWhiz(2)=Sound'PariahWeaponSounds.hit.SoulBulletWhiz1'
     bulletWhiz(3)=Sound'PariahWeaponSounds.hit.SoulBulletWhiz2'
     bulletWhiz(4)=Sound'PariahWeaponSounds.hit.SoulBulletWhiz3'
     bulletWhiz(5)=Sound'PariahWeaponSounds.hit.SoulBulletWhiz4'
     bulletWhiz(6)=Sound'PariahWeaponSounds.hit.SoulBulletWhiz5'
     bHidden=True
}
