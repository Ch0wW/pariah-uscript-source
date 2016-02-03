class WeaponEnergyCore extends VehiclePickupPlaceable
	native;

var	Controller Killer;

var() float WECAmmount;
var   float EnergyAmount;

//var() color	WECColour;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)


//Only desire earned WECs or WECs of fallen teamates
function float BotDesireability( pawn Bot )
{
	if(Bot.Controller == None)
	{	return -1;
	}

	//Grab earned WECS, or suicide-dropped
	if( Killer == Bot.Controller || Killer == None)
	{
		return MaxDesireability;
	}

	//Grab fallen teammates wecs
	if( !Bot.Controller.SameTeamAs(Killer) )
	{
		return MaxDesireability;
	}

	return -1;
}



simulated function PostBeginPlay()
{
	//local int i;
	//CreateStyle(class'ColorModifier');
	//for(i=0;i<StyleModifier.Length;i++)
	//{
	//	ColorModifier(StyleModifier[i]).Color.R = WECColour.R;
	//	ColorModifier(StyleModifier[i]).Color.G = WECColour.G;
	//	ColorModifier(StyleModifier[i]).Color.B = WECColour.B;
	//	ColorModifier(StyleModifier[i]).Color.A = WECColour.A;
	//}
	//	Physics=PHYS_Rotating
	//RotationRate=(Yaw=25000)
}


function GiveToPawn(Pawn Other)
{
	local Controller C;
	if(Other.Controller != none && Other.Controller.IsA('VehiclePlayer'))
	{
		if(Level.Game.IsA('SinglePlayer'))
		{
			// in singleplayer, a wec pickup is shared with all players
			for ( C=Level.ControllerList; C!=None; C=C.NextController ) 
			{
				if(VehiclePlayer(C) == None)
					continue;
				VehiclePlayer(C).AddWEC(WECAmmount);
			}
		}
		else
		{
			VehiclePlayer(Other.Controller).AddWEC(WECAmmount);
		}
	}
    else if (Other.Weapon != None && Other.Weapon.IsA('VGWeapon') )
    {
		VGWeapon(Other.Weapon).AddWEC(WECAmmount);
		if(Other.Controller != none)
			Other.Controller.CalculateThreatLevel();
    }
	AnnouncePickup(Other);
	SetRespawn();
}

static function int GetWECAmmount()
{
	return default.WECAmmount;
}

defaultproperties
{
     WECAmmount=1.000000
     EnergyAmount=20.000000
     RespawnEmitterClass=Class'VehicleEffects.ParticlePickupResHealth'
     bVehiclePickup=False
     bCharacterPickup=True
     MaxDesireability=2.500000
     RespawnTime=60.000000
     PickupMessage="You picked up a Weapon Energy Core"
     CantPickupMessage="WECs full."
     DrawScale=0.400000
     CollisionRadius=35.000000
     CollisionHeight=70.000000
     StaticMesh=StaticMesh'VehicleGamePickupMeshes.WEC.WEC'
     MessageClass=Class'VehicleGame.PickupMessage'
     bUnlit=True
}
