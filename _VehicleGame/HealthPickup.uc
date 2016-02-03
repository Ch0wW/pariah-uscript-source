class HealthPickup extends VehiclePickupPlaceable
	abstract;

var() int HealingAmount;
var() bool bSuperHeal;

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
function float DetourWeight(Pawn Other,float PathWeight)
{
	local int Heal;
	
	if( (!bVehiclePickup && Other.IsA('VGVehicle')) ||
		(!bCharacterPickup && Other.IsA('VGPawn')) )
	{
		return 0;
	}

	if ( AIController(Other.Controller).PriorityObjective() && (Other.Health > 65) )
		return 0;
	Heal = Min(GetHealMax(Other),Other.Health + HealingAmount) - Other.Health;
	return (0.02 * Heal * MaxDesireability)/PathWeight;
}

function float BotDesireability( pawn Bot )
{
	local VGPawn driver;

	if( (bVehiclePickup && Bot.IsA('VGVehicle')) ||
		(!bVehiclePickup && Bot.IsA('VGPawn')))
	{
		if(Bot.Health < Bot.default.Health*0.5)
			return MaxDesireability;
		else if(Bot.Health < Bot.default.Health*0.9)
			return 1.0;
		else if(Bot.Health != Bot.default.Health)
			return 0.3;
	}
	else if( !bVehiclePickup && Bot.IsA('VGVehicle') )
	{
		driver = VGVehicle(Bot).Driver;
		if(driver.Health < driver.default.Health*0.5)
			return MaxDesireability - 0.2;
		else if(driver.Health < driver.default.Health*0.9)
			return 1.0 - 0.2;
		else if(driver.Health != driver.default.Health)
			return 0.3 - 0.2;
	}

	return 0.0;
}

function int GetHealMax(Pawn P)
{
	local int HealMax;
	
	HealMax = P.HealthMax;
	if (bSuperHeal) 
		HealMax = Min(P.default.Health * 2.0, HealMax * 2.0);
	return HealMax;
}

auto state Pickup
{
	function Touch( actor Other )
	{
		local Pawn P;
			
		if ( ValidTouch(Other) ) 
		{
			P = Pawn(Other);
            if (P.GiveHealth(HealingAmount, GetHealMax(P)))
            {
				AnnouncePickup(P);
                SetRespawn();
            }
		}
	}
	function bool ValidTouch( Actor Other )
	{
		local actor RealOther;

		RealOther = GetRealOther(Other);
		if(Super.ValidTouch(RealOther))
		{
			if((RealOther.IsA('VGPawn') && bCharacterPickup && (VGPawn(RealOther).Health >= GetHealMax(VGPawn(RealOther)))) ||
			   (RealOther.IsA('VGVehicle') && bVehiclePickup && (VGVehicle(RealOther).Health >= GetHealMax(VGVehicle(RealOther)))))
				return False;
			return True;
		}
		return False;
	}
}


static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.PickupMessage$Default.HealingAmount$".";
}

defaultproperties
{
     MaxDesireability=1.500000
     RespawnTime=15.000000
     MessageClass=Class'VehicleGame.PickupMessage'
}
