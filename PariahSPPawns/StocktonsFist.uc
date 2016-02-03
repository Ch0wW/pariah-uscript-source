class StocktonsFist extends BotTitansFist;

function byte BestMode()
{
	if ( Instigator.Controller.bFire != 0 )
		return 0;
	else if ( Instigator.Controller.bAltFire != 0 )
		return 1;

	return 0;
}


simulated function bool StartFire(int Mode)
{
	log("STARTFIRE "$MODE);
	if(Mode==1)
	{
		if(Super.StartFire(Mode))
		{
	//		EnableAutoAim();
	//		EffectOffset = default.EffectOffset;
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
     FireModeClass(0)=Class'PariahSPPawns.StocktonsFistFire'
     FireModeClass(1)=Class'PariahSPPawns.StocktonsFistAltFire'
     AttachmentClass=Class'PariahSPPawns.StocktonsFistAttachment'
}
