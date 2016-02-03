class DetonatedGrenadeLight extends GrenadeLight;

var() bool bArmed;

simulated function PostBeginPlay()
{
    Super.PostBeginPlay();
    SetTimer(0.1, true);
}

simulated function ArmTimer(float t)
{
    Super.ArmTimer(t);
    bArmed = true;
}

simulated function Timer()
{
    if(bArmed == true)
    {
        Super.Timer();
    }
    else
    {
        bHidden = !bHidden;
        if(bHidden)
        {
            SetTimer(0.1, true);
        }
        else
        {
            SetTimer(0.3, true);
        }
    }
}

defaultproperties
{
     Texture=Texture'EmitterTextures.Flares.EFlareR'
     bHidden=True
}
