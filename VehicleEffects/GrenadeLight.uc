class GrenadeLight extends Effects;

var() Sound BeepSound;
var() Sound UrgentBeepSound;

simulated function ArmTimer(float t)
{
    LifeSpan = t;
    SetTimer(0.3, true);
    Texture = Texture'EmitterTextures.Flares.EFlareR';
}

simulated function Timer()
{
    if(LifeSpan > 2.0)
    {
        if(AmbientSound != BeepSound)
        {
            AmbientSound = BeepSound;
        }
        SetTimer(0.3, true);
        bHidden = !bHidden;
    }
    else
    {
        if(AmbientSound != UrgentBeepSound)
        {
            AmbientSound = UrgentBeepSound;
        }
        SetTimer(0.1, true);
        bHidden = !bHidden;
    }
}

defaultproperties
{
     BeepSound=Sound'PariahWeaponSounds.hit.GrenadeBeepLoopB'
     UrgentBeepSound=Sound'PariahWeaponSounds.hit.GrenadeBeepLoopA'
     DrawScale=1.800000
     Mass=0.000000
     Texture=Texture'EmitterTextures.Flares.EFlareB'
     PrePivot=(X=16.000000)
     Physics=PHYS_Trailer
     Style=STY_Additive
     SoundVolume=16
     bTrailerSameRotation=True
     bTrailerPrePivot=True
}
