//This class provides the native latent function that are necessary for controlling a vehicle
// it DOES NOT actually implement behaviour/decision making etc.

class DriveController extends vgBot
	native;

//AI flags
var bool	bArrive;
var bool	bAvoidAll;		//Set to true if you should steer to avoid enemy while driving

//AI memory variables
var VGVehicle LastCar;	//The last car I was in (perhaps I left it to grab a pickup)	

//Driving status
var bool bInCar;			//Am I currently possessing a vehicle (as opposed to a dude)
var VGVehicle Car;		//The car I am currently possessing (avoid casting pawn all the time)

//Car stats
var float maxCarSpeed;		//The maximum speed of the car currently being driven.
var float minTurnRadius;	//The tightest turning circle the vehicle can make.

//Latent helper variable
var float	leadWithProjectileSpeed;	//how fast our current projectile is (for leading during Drivetoward)
var vector	segNormal;
var float	segLength;
var bool	bThrottleForAim;
var bool	bAimInReverse;
var bool	bAvoidFire;

//Latent functions
native latent function FollowPath();
native latent function DriveToward(Actor target, optional FLOAT approachDist, optional bool throttleForAim, optional float weaponProjectileSpeed, optional bool bReverse, optional bool bAvoidFire);

//called during a latent DriveTo to inform that we are getting close to the target
//may be used to avoid actually colliding with it, 
event NotifyApproachingDestination();
event NotifyCarStuck()
{
	Car.ResetStuck();
}

/////////
//FUNCTIONS TO OVERRIDE
// The following Template Functions are called by variou AI related classes, and should be overridden to
// account for in-vehicle behaviour.
//////

event float Desireability(Pickup P)
{
	if(bInCar)
	{
		//log("MIKE: Shit."@P.BotDesireability(Pawn));
		return P.BotDesireability(Pawn);
	}
	else if(bIsRidingVehicle)
	{
		//log("Need to override Desireability");
		return 0;
	}
	else
		return Super.Desireability(P);
}

function SetAttractionState()
{
	if(!bInCar)
		Super.SetAttractionState();
}

function DoRetreat()
{
	if(!bInCar)
		Super.DoRetreat();
}

function WanderOrCamp(bool bMayCrouch)
{
	if(!bInCar)
		Super.WanderOrCamp(bMayCrouch);
}

function FightEnemy(bool bCanCharge, float EnemyStrength)
{
	if(!bInCar)
	{
		Super.FightEnemy(bCanCharge,EnemyStrength);
	}
	
}

function ClearPathFor(Controller C)
{
	if(bInCar || bIsRidingVehicle)
	{	
		log("MIKE: Must override ClearPathFor");
	}
	else
		Super.ClearPathFor(C);
}


//////////////
/// New functions

function CarSetup()
{
//	local float unreal2Rad;
	Car = VGVehicle(Pawn);
	Car.ResetStuck();
	
	if(Car.VehicleType == VT_Wheeled)
	{
		maxCarSpeed = Car.getMaxSpeed();
		minTurnRadius = 1.8f * Car.getTurningRadius();
	}
	else //Hovercraft tweaks
	{
		maxCarSpeed = 2000;
		minTurnRadius = 0;
	}
	
	bInCar = true;
	bAvoidAll = false;
	bArrive = false;
	Pawn.bRotateToDesired = false;
	Car.bWillWalk = true;
}

function ResetCar()
{
	Car = None;
	bInCar = false;
}

function ExitVehicle()
{
	if(bInCar)
	{
		Car.Throttle = 0;
		LastCar = Car;
		Car.DriverExits();
	}
	else if(bIsRidingVehicle)
	{
		VGPawn(Pawn).RiddenVehicle.EndRide(VGPawn(Pawn));
		bIsRidingVehicle=False;
		Pawn.SetPhysics(PHYS_Falling);
		Pawn.SetBase(None);
		EndRiding();
	}

}

function BeginRiding( VGVehicle veh)
{
	//Car = VGCar(veh);
	Car =veh;
	GotoState('RidingVehicle');
	MoveTimer = -1;
}

function EndRiding()
{
	Car = None;
	GotoState('Limbo');
	WhatToDoNext(59);
}

function Possess( Pawn possessee )
{
	local VGVehicle	Vehicle;
	
	if ( possessee!=None && possessee.Controller != self )
	{
		// if we are currently controlling vehicle,
		// tell the vehicle it is free
		//
		Vehicle = VGVehicle( Pawn );
		if ( Vehicle != None )
		{
			Vehicle.EndControlOfVehicle( self );
		}

		Super.Possess( possessee );

		// if we are now controlling a vehicle, tell it
		// we are taking over
		//
		Vehicle = VGVehicle( Pawn );
		if ( Vehicle != None )
		{
			Vehicle.BeginControlOfVehicle( self );
			CarSetup();
		}
		else
		{	
			Pawn.SetMovementPhysics(); 
			if (Pawn.Physics == PHYS_Walking)
				Pawn.SetPhysics(PHYS_Falling);
			ResetCar();
		}
	}
}

function UnPossess(optional bool bTemporary)
{
	local VGVehicle	Vehicle;

	// if we are currently controlling vehicle,
	// tell the vehicle it is free
	
	Vehicle = VGVehicle( Pawn );
	if ( Vehicle != None )
	{
		Vehicle.EndControlOfVehicle( self );
		ResetCar();
	}

	if ( Pawn != None )
	{
		SetLocation(Pawn.Location);
		Pawn.RemoteRole = ROLE_SimulatedProxy;
		Pawn.UnPossessed();
	}
	Pawn = None;

	// Is there some state we should go to that is
	// similar to Spectating for PlayerControllers (RJ)
	//
	GotoState('Limbo');
}

//Similar to playerController's Spectating state, we're not dead, but we're "between pawns" as it were.
state Limbo
{	
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump,NotifyRunOver;
	
}

state RidingVehicle
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump,NotifyRunOver;

}

defaultproperties
{
}
