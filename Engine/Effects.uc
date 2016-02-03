//=============================================================================
// Effects, the base class of all gratuitous special effects.
// 
//=============================================================================
class Effects extends Actor;

var() sound 	EffectSound1;

simulated function SendHitNotify()
{
    local WeaponAttachment wa;

    wa = WeaponAttachment(Owner);
    if (wa != None)
        wa.HitEffectNotify(self);
}

defaultproperties
{
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     RemoteRole=ROLE_None
     bNetTemporary=True
     bNetInitialRotation=True
     bUnlit=True
     bGameRelevant=True
}
