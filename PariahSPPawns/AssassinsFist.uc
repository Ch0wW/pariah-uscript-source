class AssassinsFist extends BotTitansFist;


function byte BestMode(){
	if ( Instigator.Controller.bFire != 0 )
		return 0;
	else if ( Instigator.Controller.bAltFire != 0 )
		return 1;
	return 0;
}


simulated function bool StartFire(int Mode){
	if(Mode==1)	{
		if(Super.StartFire(Mode))
		{
			FireMode[mode].StartFiring();
			return true;
		}
		return false;
	}
	else
		return Super.StartFire(Mode);
}

defaultproperties
{
     EffectClass=None
     ReloadTime=0.000000
     WeaponMessageClass=None
     SelectSound=None
     FireModeClass(0)=Class'PariahSPPawns.AssassinsFistFire'
     FireModeClass(1)=Class'PariahSPPawns.AssassinsFistFire'
     PickupClass=None
     AttachmentClass=None
}
