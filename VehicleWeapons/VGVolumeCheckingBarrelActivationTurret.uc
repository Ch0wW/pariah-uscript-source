/*
	VGVolumeCheckingBarrelActivationTurret
	Desc: A VGBarrelActivationTurret that
			- Shoots any pawn that walks in a TurretLookoutVolume binded to it
	xmatt
*/

class VGVolumeCheckingBarrelActivationTurret extends VGBarrelActivationTurret
	placeable;


event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch( handler )
	{
	//If a pawn entered a volume monitored by this turret
	case 'PawnInTurretVolume':
		//log( "-> PawnInTurretVolume: " $ instigator );
		
		//Because the offensive dropship is not a VGPawn
		//Q: MattT lets fix that
		//if( instigator != None && Instigator.race != self.race)
		if( instigator != None && Instigator.race != self.race)
		{
			// only add if not of same "race"
			DetectedPawns[DetectedPawns.Length] = instigator;
			//log("********** ADDED "$Instigator$" to the hit list!!!!");
		}
		
		//log( "Pawn added to monitoring list... now " $ DetectedPawns.Length $ " pawns in list"  );
		//If the pawn that moved out of the monitored volume was the target, chose another target
		if( Target == None )
		{
			//log( "2" );
			if( bIsOn )
			{
				//log( "GetTarget called from pawn in event" );
				GetTarget();
			}
		}
		break;

	case 'PawnOutOfTurretVolume':
		//log( "<- PawnInTurretVolume" );
		RemoveDetected(instigator);
		//log( "Pawn removed to monitoring list... now " $ DetectedPawns.Length $ " pawns in list"  );
		//If the pawn that moved out of the monitored volume was the target, chose another target
		if( Target == None )
		{
			//log( "5" );
			if( bIsOn )
			{
				//log( "6" );
				//If the barrel was turning wind down
				if( BarrelState == BS_Turning )
				{
					//log( "BarrelState = BS_WindingDown" );
					BarrelState = BS_WindingDown;
				}
				//log( "GetTarget called from pawn out event" );
				GetTarget();
			}
		}
		break;
	default: 
		Super.TriggerEx(sender, instigator, handler, realevent);
		break;

	}
}

simulated function TurnItOff()
{
	Super.TurnItOff();
	StopFiringSound();
}

simulated function PlayFiringSound()
{
	AmbientSound = FiringSound;
	bPlayingBarrelFiring = true;
}


simulated function StopFiringSound()
{
	AmbientSound = None;
	bPlayingBarrelFiring = false;
}

defaultproperties
{
     race=TURRET_Clan
     EventBindings(0)=(EventName="PawnInTurretXVolume",HandledBy="PawnInTurretVolume")
     EventBindings(1)=(EventName="PawnOutOfTurretXVolume",HandledBy="PawnOutOfTurretVolume")
     EventBindings(2)=(EventName="TurretXSwitch",HandledBy="TurretSwitch")
}
