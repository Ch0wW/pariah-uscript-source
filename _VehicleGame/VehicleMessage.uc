class VehicleMessage extends LocalMessage;

// OptionalObject is a PlayerController

var() localized String EnterAsDriverString;
var() localized String EnterAsPassengerString;
var() localized String EnterAsGunnerString;
var() localized String FlipString;
var() localized String UseTurretString;

var() localized String TheUseButtonString;

static function string GetString
(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
)
{
    local PlayerController PC;
    local VGPawn Pawn;
    local String BindingKeys;
    local String UseIcon;
    local String S;
    
    PC = PlayerController(OptionalObject);
    
    if( PC == None )
    {
        log("Could not GetString without a PlayerController OptionalObject", 'Error');
        return("");
    }

    Pawn = VGPawn(PC.Pawn);
    
    if( Pawn == None )
    {
        log("Could not GetString without a PlayerController OptionalObject", 'Error');
        return("");
    }
    
    if( (Pawn.PotentialTurret == None) && (Pawn.PotentialVehicle == None) )
    {
        log("Could not GetString without a PotentialTurret or a PotentialVehicle", 'Error');
        return("");
    }
    
    BindingKeys = PC.ConsoleCommand("BINDINGTOKEY ENTERVEHICLE");
    
    if( BindingKeys == "" )
    {
	    BindingKeys = PC.ConsoleCommand("BINDINGTOKEY ENTERVEHICLEOR");
		if( BindingKeys == "" )
		{
			`log("Could not find binding for <ENTERVEHICLE>", 'Error');
			return("");
        }
    }
    
    UseIcon = class'Fonts_rc'.static.DescribeBinding( BindingKeys, PC );
    
    if( UseIcon == "" )
    {
        //log("Could not find icon for" @ BindingKeys, 'Error');
        UseIcon = default.TheUseButtonString;
    }
    
    if( (Pawn.PotentialTurret != None) )
    {
        if( !Pawn.PotentialTurret.CanEnter(Pawn) )
        {
            return("");
        }
        
        S = default.UseTurretString;
    
        UpdateTextField( S, "<USE>", UseIcon );
        return( S );
    }
    
    Assert( Pawn.PotentialVehicle != None );
    
    //if( Pawn.PotentialVehicle.bIsDriven )
    //{
    //    return("");
    //}
    
    switch( Pawn.PotentialVehicle.GetPlayerVehicleAction(Pawn) )
    {
    	case PVA_Driver:
    	    S = default.EnterAsDriverString;
    	    break;

    	case PVA_Rider:
    	    S = default.EnterAsPassengerString;
    	    break;
        
    	case PVA_Gunner:
    	    S = default.EnterAsGunnerString;
    	    break;
    	    
    	case PVA_Flip:
    	    S = default.FlipString;
    	    break;
    	    
        default:
            return("");
    }

    UpdateTextField( S, "<USE>", UseIcon );
    UpdateTextField( S, "<VEHICLE>", Pawn.PotentialVehicle.class.default.VehicleName );
    return( S );
}

static function bool IsValid(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1, 
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    local PlayerController PC;
    local VGPawn Pawn;
    
    PC = PlayerController(OptionalObject);
    
    if( PC == None )
    {
        return(false);
    }

    Pawn = VGPawn(PC.Pawn);
    
    if( Pawn == None )
    {
        return(false);
    }
    
	if( (Pawn.PotentialTurret == None) && (Pawn.PotentialVehicle == None) )
    {
        return(false);
    }
   
    if( Pawn.PotentialTurret != None )
    {
        if( !Pawn.PotentialTurret.CanEnter(Pawn) )
        {
            return(false);
        }
        
        return(true);
    }
    
	if( Pawn.DrivenVehicle != None || Pawn.RiddenVehicle != None || Pawn.RiddenTurret != None )
	{
		return false;
	}

    Assert( Pawn.PotentialVehicle != None );
    
    if( Pawn.PotentialVehicle.GetPlayerVehicleAction(Pawn) == PVA_None )
    {
        return(false);
    }

    return(true);
}

defaultproperties
{
     EnterAsDriverString="<USE> to enter the <VEHICLE> as the driver."
     EnterAsPassengerString="<USE> to enter the <VEHICLE> as the passenger."
     EnterAsGunnerString="<USE> to enter the <VEHICLE> as the gunner."
     FlipString="<USE> to flip the <VEHICLE>."
     UseTurretString="<USE> to use the turret."
     TheUseButtonString="the use button"
     FontSize=1
     Lifetime=30000.000000
     PosX=0.980000
     PosY=0.120000
     DrawColor=(B=255,G=255,R=255)
     DrawPivot=DP_UpperRight
     StackMode=SM_Down
     bIsUnique=True
}
