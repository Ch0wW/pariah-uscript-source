//This class is intended to override the tactical decision making code to include vehicle specific stuff.
//
class CarBot extends DriveController;

const MINREAPPROACHDISTANCE = 4000;		//When attacking a vehicle, if you collide, retreat this far,and reapproach

var bool bWimp;		//For debugging, if true, the AI won't check if it can shoot.


//AI Memory variables
var VGVehicle DesiredCar;			//Checked when NotifyEnterVehicle called to verify we want to get it a vehicle we bump
var EntryPoint  CarEntrySpot;       //You need to be in a particular spot to get in a vehicle, and we'd prefer that spot to be an actor
var bool bDesirePad;
var float EnemyFacingTime;			//How long has the enemy been facing us?
var Actor CurEnemy;					//make sure it's the same enemy we're keeping track of.
var bool bWaitingForPassenger;		//Are we currently waiting for a passenger, used for ignoring carstuck messages etc.
var float WaitForPassengerTime;		//How long have we been waiting.

var int testVal;					//Just a hookable value so cheat manager change change stuff on the fly while testing

function bool ShouldStrafeTo(Actor WayPoint)
{
	if(testVal > 0)
	{
		return true;
	}
	return Super.ShouldStrafeTo(WayPoint);
}

//overriding to show soak logs during regular play
function PostBeginPlay()
{
	//bSoaking=true;
	Super.PostBeginPlay();
}

function Destroyed()
{
    Super.Destroyed();
}

function SoakStop(string problem)
{
	log("SOAKSTOP ON: "$problem);
}

// cmr ---
function NotifyRestarted()
{
	local string startwithvehicles;
	local bool bURLStartWithVehicles;

	startwithvehicles=GetURLOption("StartWithVehicles");

	if(startwithvehicles!="")
		bURLStartWithVehicles = Caps(startwithvehicles)=="TRUE";
	else
		bURLStartWithVehicles = False;

	GivePlayerLoadOut();
	SwitchToBestWeapon();
	CalculateThreatLevel();
}

/**
 * Call to loadout bot possessing a homonid.
 **/
function GivePlayerLoadOut()
{
	local int x, rndSlot;
	local String strTemp;
	local String Weapons[6];

	Weapons[0]="VehicleWeapons.BotAssaultRifle";
	Weapons[1]="VehicleWeapons.BotRocketLauncher";
	Weapons[2]="VehicleWeapons.BotPlasmaGun";
	Weapons[3]="VehicleWeapons.BotGrenadeLauncher";
    Weapons[4]="VehicleWeapons.BotFragRifle";
    Weapons[5]="VehicleWeapons.BotSniperRifle";
	
	
	for(x = 0; x < ArrayCount(Weapons); x++)
	{
		rndSlot = x + (Rand(ArrayCount(Weapons) - x));
		strTemp = Weapons[x];
		Weapons[x] = Weapons[rndSlot];
		Weapons[rndSlot] = strTemp;
	}
	Pawn.GiveWeapon(Weapons[0]);
	Pawn.GiveWeapon(Weapons[1]);
}

/**
 * Call to loadout bot possessing a vehicle.
 **/
function GiveLoadOut()
{
	local int x, rndSlot;
	local String strTemp;
	local String Weapons[3];

	if(Pawn.IsA('VGVehicle'))
	{
		
		Weapons[0] = "VehicleWeapons.Puncher";
		Weapons[1] = "VehicleWeapons.Haser";
		Weapons[2] = "VehicleWeapons.SwarmLauncher";
		//Weapons[3] = "VehicleWeapons.SRMLauncher";
		//Weapons[4] = "VehicleWeapons.HellFireLauncher";
		//Weapons[5] = "VehicleWeapons.GuidedLauncher";
		
		for(x = 0; x < ArrayCount(Weapons); x++)
		{
			rndSlot = x + (Rand(ArrayCount(Weapons) - x));
			strTemp = Weapons[x];
			Weapons[x] = Weapons[rndSlot];
			Weapons[rndSlot] = strTemp;
		}

		Pawn.GiveWeapon(Weapons[0]);
		Pawn.GiveWeapon(Weapons[1]);
		Pawn.GiveWeapon(Weapons[2]);
		VGVehicle(Pawn).GiveDefaultWeapon();
		SwitchToBestWeapon();
	}
}

function CarDying()
{
	GotoState('vehCarDying');
}
// --- cmr

////////
//Overridden functions
/////////

function vector AdjustToss(float TSpeed, vector Start, vector End, bool bNormalize)
{
    return FindToss(TSpeed, Start, End);
}

function vector FindToss(float TSpeed, vector StartLocation, vector TargetLocation)
{
	local float ThetaLow, ThetaHigh, InterceptTimeLow, InterceptTimeHigh, Theta;
	
	local int NumSolutions;
	local Rotator LeapRotation;
    
	// set leap parameters
	LeapRotation = rotator(TargetLocation - StartLocation); // rotation to aim directly at target

	NumSolutions = class'TrajectoryCalculator'.static.GetInverseTrajectory(
			Pawn,
			Pawn.Weapon.FireMode[Pawn.Weapon.BotMode].ProjectileClass,
			TSpeed, 
			StartLocation, 
			TargetLocation, 
			ThetaLow, 
			ThetaHigh, 
			InterceptTimeLow, 
			InterceptTimeHigh );

	Theta = ThetaLow;

	// modify the pitch
	if( Theta < 0 )
		LeapRotation.Pitch =  class'TrajectoryCalculator'.static.RadianToRotation(-Theta);
	else
		LeapRotation.Pitch = 65535 - class'TrajectoryCalculator'.static.RadianToRotation(Theta);

    return Vector( LeapRotation );
}

/* called before start of navigation network traversal to allow setup of transient navigation flags
*/
event SetupSpecialPathAbilities()
{
	Super.SetupSpecialPathAbilities();
	bCanUseCar = bInCar || bIsRidingVehicle || FindCar();
}

function bool NeedWeapon()
{
	return false;
}

function StopFiring()
{
	if ( (Pawn != None) && (Pawn.Weapon != None) && Pawn.Weapon.IsFiring() )
	{
		Pawn.Weapon.ServerStopFire(Pawn.Weapon.BotMode);
		bStoppedFiring = true;
	}
	if ( (Pawn != None) && (Pawn.DefaultWeapon != None) && Pawn.DefaultWeapon.IsFiring() )
	{
		Pawn.DefaultWeapon.ServerStopFire(Pawn.DefaultWeapon.BotMode);
		bStoppedFiring = true;
	}
	bCanFire = false;
	bFire = 0;
	bAltFire = 0;
}

function CalculateThreatLevel()
{
	if(Pawn != none && Pawn.Weapon != none && Pawn.Weapon.IsA('PersonalWeapon'))
	{
		PlayerReplicationInfo.ThreatLevel = PersonalWeapon(Pawn.Weapon).WECLevel;
	}
}

function float RelativeStrength(Pawn Other)
{
	local float compare;
	local int adjustedOther;
	local float testCompare;

	if ( Pawn == None )
	{
		warn("Relative strength with no pawn in state "$GetStateName());
		return 0;
	}
	adjustedOther = 0.3 * (Other.health + Other.Default.Health);	
	compare = 0.01 * float(adjustedOther - Pawn.health);
	compare = compare - Pawn.AdjustedStrength() + Other.AdjustedStrength();
	
	testCompare = float(adjustedOther) / float(Other.Default.Health);
	testCompare = testCompare - float(Pawn.health) / float(Pawn.Default.health) ;
	//add in car advantage
	if(bInCar)
		testCompare -= 0.2;
	if( VGVehicle(Other) != None)
		testCompare += 0.1;
	
	compare = testCompare;
	
	if ( Pawn.Weapon != None )
	{
		compare -= 0.5 * Pawn.DamageScaling * Pawn.Weapon.CurrentRating;
		if ( Pawn.Weapon.AIRating < 0.5 )
		{
			compare += 0.3;
			if ( (Other.Weapon != None) && (Other.Weapon.AIRating > 0.5) )
				compare += 0.3;
		}
	}
	if ( Other.Weapon != None )
		compare += 0.5 * Other.DamageScaling * Other.Weapon.AIRating;
	
	if ( Other.Location.Z > Pawn.Location.Z + TACTICALHEIGHTADVANTAGE )
		compare += 0.2;
	else if ( Pawn.Location.Z > Other.Location.Z + TACTICALHEIGHTADVANTAGE )
		compare -= 0.15;
	
	return compare;
}

function bool DoWaitForLanding()
{
	//if(bIsRidingVehicle)
	//	log("MIKEH : DoWaitForLanding()");
	
	return Super.DoWaitForLanding();

}

//If we're in a car, don't roam to a spot that requires getting out.
function bool FindRoamDest()
{
	local bool returnVal;

	if(bInCar)
	{	
		if ( Pawn.FindAnchorFailedTime == Level.TimeSeconds )
		{	
			if ( Pawn.LastValidAnchorTime > 5 )
			{	
				if ( bSoaking )
					SoakStop("NO PATH AVAILABLE!!!");
			}
			return false;
		}

		Car.bWillWalk = false;
		returnVal = Super.FindRoamDest();
		Car.bWillWalk = true;
	}
	else if(bIsRidingVehicle)
	{
		if( VGPawn(Pawn).RiddenVehicle.Driver == None)
		{
			ExitVehicle();
			returnVal = Super.FindRoamDest();
		}
	}
	else
	{
		returnVal = Super.FindRoamDest();
	}

	return returnVal;
}

function bool FindInventoryGoal(float BestWeight)
{
	local bool returnVal;

	if(bInCar)
	{	
		//Will get a jump in-out bug if you can roam in car to places that aren't drivable
		Car.bWillWalk	= false;
		returnVal = Super.FindInventoryGoal(BestWeight);
		Car.bWillWalk = true;
	}
	else
	{
		returnVal = Super.FindInventoryGoal(BestWeight);
	}

	return returnVal;
}

function CheckForOnFootDetours()
{
	local float driveDist;
	
	//We've already got our goal, but we can check for some detours
	if(FindCar() && CarWorthGetting(DesiredCar))
	{
		//FindBestPathToward(DesiredCar,false,true);
		//MoveTarget = DesiredCar;
        MoveTarget = CarEntrySpot;
		RouteGoal = DesiredCar;
		DrivableDistance(driveDist);
		`GoalString = "Faster to grab car: Dist:"@driveDist@GoalString;
	}
	else
	{
		DesiredCar = None;
		bDesirePad = false;
	}

}

function SetAttractionState()
{
	if(bInCar)
	{
		GotoState('vehDriveToGoal');
	}
	else if(bIsRidingVehicle)
	{	
		if( VGPawn(Pawn).RiddenVehicle.Driver == None)
		{
			ExitVehicle();
			WhatToDoNext(61);
			
		}
		else if( !WorthDriving() )
		{
			ExitVehicle();
			SetAttractionState();
		}
		else
		{
			GotoState('RidingVehicle');
		}
	}
	else
	{
		CheckForOnFootDetours();
		Super.SetAttractionState();
	}
}


function FightEnemy(bool bCanCharge, float EnemyStrength)
{
	if(bInCar)
	{
        if( Pawn.Weapon == None )
        {
            // Holy fucking shit! We're supposedly in a car but we have no weapon!
			ExitVehicle();
			Super.FightEnemy(bCanCharge,EnemyStrength);
			return;
        }

		//FIXME: decide if we should get out of car to fight?
		vehFightEnemy();
	}
	else if(bIsRidingVehicle)
	{
		if( VGPawn(Pawn).RiddenVehicle.Driver != None)
		{
			GotoState('RidingVehicle');
		}
		else	//no driver
		{
			if( LostContact(1.0 + 2.0*Frand()) )
			{
				ExitVehicle();
				Super.FightEnemy(bCanCharge,EnemyStrength);
			}
			else
			{
				GotoState('RidingVehicle');
			}
		}
	}
	else
	{	
		Super.FightEnemy(bCanCharge,EnemyStrength);
	}
	
}

function DoRetreat()
{
	if(bInCar)
	{
		vehDoRetreat();
	}
	else if(bIsRidingVehicle)
	{
		GotoState('RidingVehicle');
	}
	else
	{
		Super.DoRetreat();
	}
}

function bool PickRetreatDestination()
{
	if(!bInCar)
	{
		
	}
	
	return Super.PickRetreatDestination();
}

function WanderOrCamp(bool bMayCrouch)
{
	if(bInCar)
	{
		GotoState('vehRestFormation');;
	}
	else if(bIsRidingVehicle)
	{
		GotoState('RidingVehicle');
	}
	else
	{
		Super.WanderOrCamp(bMayCrouch);
	}
	
}


function bool TryToDuck(vector duckDir, bool bReversed)
{
	if(bInCar || bIsRidingVehicle)
		return false;

	return Super.TryToDuck(duckDir, bReversed);

}

function DoRangedAttackOn(Actor A)
{
	if(bInCar)
	{
		ExitVehicle();
	}


	Super.DoRangedAttackOn(A);
}

//////
///		Xavier's Autoaim stuff get's called instead of AdjustAim
///		I hacked it a bit so the UC AI can still use AdjustAim
//////////////
function rotator AutoAim(vector ProjStart, Weapon FiredWeapon)
{
	local Ammunition Ammo;
	local vector fireDir, LookDir;
	local Rotator aimDir;

	//Oh my god, I have to be able to combine this crap with NeedToTurn, and factor out the leading junk
	if(bInCar)
	{	
		if(VGVehicle(Target) == None)
			return Car.Rotation;

		if(currentlyLeading() && (FiredWeapon != Pawn.DefaultWeapon) )
		{	
			fireDir = (Destination - ProjStart);	
		}
		else
		{	fireDir = (Target.Location - ProjStart);
		}
		aimDir = Rotator(fireDir);
		
		LookDir = Vector(Car.Rotation);
		LookDir.Z = 0;
		LookDir = Normal(LookDir);
		fireDir.Z = 0;
		fireDir = Normal(fireDir);
		if( (LookDir Dot fireDir) < 0.93f)
		{
			return Car.Rotation;
		}
		else
		{
			return aimDir;
		}
	}
	
	// stuff Ammo with AI info
    Ammo = FiredWeapon.Ammo[FiredWeapon.BotMode];
    if (Ammo == None)
    {
        Log("warning:"@FiredWeapon@self@"needs an ammo class for nefarious AI purposes");
        return Instigator.Rotation;
    }
    else
    {
        Ammo.bTossed = FiredWeapon.FireMode[FiredWeapon.BotMode].bTossed;
        Ammo.bTrySplash = FiredWeapon.FireMode[FiredWeapon.BotMode].bRecommendSplashDamage;
        Ammo.bLeadTarget = FiredWeapon.FireMode[FiredWeapon.BotMode].bLeadTarget;
        Ammo.bInstantHit = FiredWeapon.FireMode[FiredWeapon.BotMode].bInstantHit;
        Ammo.ProjectileClass = FiredWeapon.FireMode[FiredWeapon.BotMode].ProjectileClass;
		Ammo.WarnTargetPct = FiredWeapon.FireMode[FiredWeapon.BotMode].WarnTargetPct;
        Ammo.MaxRange = FiredWeapon.FireMode[FiredWeapon.BotMode].MaxRange(); //amb: for autoaim
        Ammo.AutoAim = FiredWeapon.FireMode[FiredWeapon.BotMode].AutoAim;
        return AdjustAim(Ammo, ProjStart, FiredWeapon.FireMode[FiredWeapon.BotMode].AimError);
    }
}

///////////////////////////////////////////////////////////////////////////////////
//New functions
///////////////////////////////////////////////////////////////////////////////////

event Touch( Actor Other )
{
    if(Other == CarEntrySpot && !(bInCar || bIsRidingVehicle) )
    {
        Pawn.Bump(Other.Owner);
        NotifyEnterVehicle( VGVehicle(Other.Owner) );
    }
}


function bool AdjustAround(Pawn Other)
{
	local float speed;
	local vector VelDir, OtherDir, SideDir;

    speed = VSize(Pawn.Acceleration);
    if( VGVehicle(Other) == None)
    {
        if ( speed < Pawn.WalkingPct * Pawn.GroundSpeed )
	    	return false;
        VelDir = Pawn.Acceleration/speed;
	    VelDir.Z = 0;
        OtherDir = Other.Location - Pawn.Location;
	    OtherDir.Z = 0;
	    OtherDir = Normal(OtherDir);
	    if ( (VelDir Dot OtherDir) > 0.8 )
	    {
            bAdjusting = true;
		    SideDir.X = VelDir.Y;
		    SideDir.Y = -1 * VelDir.X;
		    if ( (SideDir Dot OtherDir) > 0 )
			    SideDir *= -1;
		    AdjustLoc = Pawn.Location + 1.5 * Other.CollisionRadius * (0.5 * VelDir + SideDir);
	    }
    }
    else //Other is vehicle
    {
        if ( speed < Pawn.WalkingPct * Pawn.GroundSpeed )
            VelDir = Destination - Pawn.Location;
        else
            VelDir = Pawn.Acceleration/speed;
	    VelDir.Z = 0;
        OtherDir = Other.Location - Pawn.Location;
	    OtherDir.Z = 0;
	    OtherDir = Normal(OtherDir);
	    bAdjusting = true;
		SideDir.X = VelDir.Y;
		SideDir.Y = -1 * VelDir.X;
		if ( (SideDir Dot OtherDir) > 0 )
			SideDir *= -1;
		AdjustLoc = Pawn.Location + 1.5 * Other.CollisionRadius * (0.5 * VelDir + SideDir);
    }
}

event NotifyCarStuck()
{
	GotoState('vehCarStuck');
	Super.NotifyCarStuck();
}

function NotifyEnterVehicle(VGVehicle veh)
{
    //log("NOTIFY ENTER VEHICLE:"@veh@DesiredCar@VSize(CarEntrySpot.Location - Pawn.Location));

    if ( veh == DesiredCar && veh.isMobile() &&
        ( CarDrivable(veh) || (CanHopOnCar(veh)) ) &&
        VSize(CarEntrySpot.Location - Pawn.Location) <= 200 )
	{
        VGPawn(Pawn).EnterVehicle();
		SwitchToBestWeapon();
		Pawn.Weapon.BringUp();
	}
}

function bool leadTarget(Weapon curWeapon)
{
	if(curWeapon == None)
		return false;
	return curWeapon.FireMode[curWeapon.BotMode].bLeadTarget;
}

function bool currentlyLeading()
{
	return false;
}

//can we indefinitely hold the weapon charged?
function bool ChargeWeapon()
{
	local WeaponFire fireMode;

	fireMode = Pawn.Weapon.FireMode[Pawn.Weapon.BotMode];
	return ( fireMode.bFireOnRelease && fireMode.MaxHoldTime == 0.0f);
		
}


//Is the reachspec drivable
function bool IsRoadPath(Actor Start, Actor End)
{
	local int i;
	local NavigationPoint N;
	
	N = NavigationPoint(Start);
	if(N == None)
		return false;

	//find the reachspec
	for(i = 0; i<N.PathList.Length; i++)
	{
		if( End == N.PathList[i].End )
		{
			return N.PathList[i].bDriveable;
		}
	}

	return false;
}

//Returns true if there is a break in the road
function bool DrivableDistance(out float totalDist)
{
	local int i;
	
	totalDist = 0;

	if( Pawn.Anchor == None || RouteCache[0] == None)
	{
		return true;
	}
	else
	{
		if(Pawn.Anchor != RouteCache[0])
		{
			if( IsRoadPath(Pawn.Anchor, RouteCache[0]) )
			{
				totalDist += VSize(Pawn.Anchor.Location - RouteCache[0].Location);
			}
			else
			{	
				//First path isn't a road.
				return true;
			}
		}
		else	//anchor same as first cached node, is it (on) a road?
		{
			if(	Pawn.Anchor.IsA('RoadPathNode')	)
			{
				//Anchored to road
				return false;
			}
			else
			{
				//any drivable path means it's on a road
				for(i = 0; i<Pawn.Anchor.PathList.Length; i++)
				{
					if( Pawn.Anchor.PathList[i].bDriveable )
						return false;
				}
				//No path, not anchored to road
				return true;
			}
		}
	}
	

	for(i=1; i<16; i++)
	{
		if( RouteCache[i-1] == None || RouteCache[i] == None)
		{
			//End of path, not road
			return false;
		}
		if( IsRoadPath(RouteCache[i-1], RouteCache[i]) )
			totalDist += VSize( RouteCache[i-1].Location - RouteCache[i].Location);
		else
		{
			//Break in road.
			return true;
		}
	}

	//End of cache, not road.
	return false;
}

function bool WorthDriving()
{
	local float driveDist;
	local bool bRoadEnds;

	bRoadEnds = DrivableDistance(driveDist);
	if (driveDist > 1000) 
		return true;
	
	//If we're already driving we can drive right to our goal if the road doesn't end.
	if( (bInCar || bIsRidingVehicle) && !bRoadEnds)
	{
		return true;
	}

	return false;
}

//We are on foot, and there is a car reachable from here, we get in it en route if the cost of walking to the car is offset
//by the time gained by driving the path?
//Of course, some of the path must be covered by road.
function bool CarWorthGetting(VGVehicle c)
{
	local float carDist, pathDist, walkSpeed, carSpeed;
	
	carDist = VSize(c.Location - Pawn.Location);
	DrivableDistance(pathDist);
	carSpeed = c.getMaxSpeed();
	walkSpeed = Pawn.GroundSpeed;

	//sanity check
	if(pathDist < 1000)
		return false;

	//if(( pathDist / carSpeed ) < ((pathDist - carDist) / walkSpeed ))
	//	log("MIKEH: Car is worth getting: Anchor: "@Pawn.Anchor@"Cache0:"@RouteCache[0]@"driveDist:"@pathDist@"carDist:"@carDist);
	return ( pathDist / carSpeed ) < ((pathDist - carDist) / walkSpeed );

}


function bool CarDrivable(VGVehicle veh)
{
	return ( veh != None && veh.IsDrivable());
}

function bool CanHopOnCar(VGVehicle veh)
{
	if (veh == None)
		return false;

	//FIXME: Make sure they're going the same place we are!!
	if( veh.Driver == None || veh.Controller == None || !veh.FreePassengerPoint() || !SameTeamAs(veh.Controller) )
		return false;

	return true;
}

//find a car that is reachable from the curent "road segment"
function bool FindCar()
{
	local NavigationPoint N;
	local VGVehicle veh, chosen;
	local float dist, tmpDist;
    
	if( Pawn.Anchor == None)
		return false;
	
	chosen = None;
	dist = 999999;
	foreach DynamicActors(class 'VGVehicle', veh)
	{	if(veh.isMobile() && (CarDrivable(veh) || CanHopOnCar(veh)) )
		{
			for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
			{
				if( !N.IsA('RoadPathNode') || (VSize(Pawn.Anchor.Location - N.Location) > N.CollisionRadius) || (VSize(veh.Location - N.Location) > N.CollisionRadius))
					continue;
			
				tmpDist = VSize(veh.Location - Pawn.Location);
				if(tmpDist < dist)
				{
					chosen = veh;
					dist = tmpDist;
				}
			}
		}
	}
	DesiredCar = chosen;
	if(chosen != None)
        SetCarEntrySpot(chosen);
    return (chosen != None);
}

function SetCarEntrySpot(VGVehicle chosen)
{
    if(CarDrivable(chosen))
	{
		chosen.GetDriverEntryPoint(CarEntrySpot);
	}
    else
    {
        chosen.GetPassengerEntryPoint(CarEntrySpot);
    }
}

//FIXME: This ought to be abstracted somewhere, and Demeter would not be happy.
function bool VehicleAvailable()
{
	local int vehiclesavailable;

	if(Level.Game.bTeamGame)
	{
 		vehiclesavailable = Level.VehiclesPerTeam - Level.Game.GameReplicationInfo.VehicleCount[PlayerReplicationInfo.Team.TeamIndex];
 	}
 	else
 	{
 		vehiclesavailable = Level.VehiclesPerTeam*2 - Level.Game.GameReplicationInfo.VehicleCount[0];
 	}

	return (vehiclesavailable > 0);
}

function bool CarSpawnerWorthGetting()
{
	local float driveDist;

	if ( VehicleAvailable() )
	{
		DrivableDistance(driveDist);
		`GoalString = "VehAvailalable, DriveDist"@ driveDist@GoalString;
		if( WorthDriving() )
			return true;
	}
	
	return false;
}

function vehFightEnemy()
{
	if(ActorReachable(Enemy) )
	{ 	
		DoAttackStyle();
	}
	else if(CanAttack(Enemy) && (VGVehicle(Enemy) != None) ) //line of sight regardless of sector
	{
		`GoalString = "LOS vehStandoff";
  		GotoState('vehStandoff');
	}
	else
	{
		`GoalString = "Hunting";
		GotoState('vehHunting');
	}
}


function vehDoRetreat()
{
	if ( Squad.PickRetreatDestination(self) )
	{
		SetAttractionState();
		`GoalString = "RETREAT"@GoalString;
		return;
	}

	// if nothing, then tactical move
	if ( EnemyVisible() )
	{
		`GoalString= "No retreat because frustrated";
		bFrustrated = true;
		vehFightEnemy();
		return;
	}
	`GoalString = "vehStandoff because no retreat dest";
	GotoState('vehStandoff');
}

function DoAttackStyle()
{
	local String tmpString;
	local Vector carDir, enemyDir;
	local bool bEnemyMovingAway, bEnemyFacingUs;
	local float enemyDist;
	
	enemyDir = (Enemy.Location - car.Location);
	enemyDist = VSize(enemyDir);
	
	//enemy not in car
	if( VGVehicle(Enemy) == None)
	{
		if(enemyDist < minTurnRadius && (enemyDir dot Car.Velocity) < 0.93f)
		{
			tmpString = "REAPPROACH for RUNOVER";
			GotoState('vehReApproach');
		}
		else
		{
			tmpString = "RUNOVER";
			GotoState('vehChargeAttack', 'RAM');
		}
	}
	else	//enemy in car
	{
		//FIXME: Should also account for type of weapon.
		carDir = vector(Car.Rotation);
		bEnemyMovingAway = (Enemy.Velocity dot enemyDir) > 0.0f;
		bEnemyFacingUs = EnemyFacingTime > 2.0f + frand() * 2.0f; // enemy has faced us between 2 and 4 seconds
		
		if( (carDir dot enemyDir) > 0.0f ) //enemy in front of us
		{
			if(enemyDist > 5000)	//far enough away from enemy
			{
				if(bEnemyFacingUs)
				{
					//FIXME We may want to ram here as well.
					//or find a spot to hide behind
					tmpString = "AVOID 1";
					GotoState('vehAvoidFire');
				}
				else if(bEnemyMovingAway)	//med away + distance opening => charge
				{
					tmpString = "CHARGE";
					GotoState('vehChargeAttack', 'ATTACK');
				}
				else if(frand() < 0.25 )	//med away + distance closing  => RAM
				{
					// FIXME increase chance of ramming if we have the power up.
					tmpString = "RAM";
					GotoState('vehChargeAttack', 'RAM');
				}
				else//med away + distance closing + 50%, => standoff
				{
					tmpString = "STANDOFF";
					GotoState('vehStandoff');
				}
				
			}
			else	//pretty close to enemy
			{
				if(bEnemyFacingUs && frand() < 0.5)
				{
					tmpString = "AVOID 2";
					GotoState('vehAvoidFire');
				}
				else if(bEnemyMovingAway)	//close + distance opening	=>standoff
				{
					tmpString = "STANDOFF";
					GotoState('vehStandoff');
				}
				else if(frand() < 0.8)	//close + distance closing + 80%, => standoff
				{
					tmpString = "STANDOFF";
					GotoState('vehStandoff');
				}
				else	 //close + distance closing	=>reapproach
				{	
					tmpString = "REAPPROACH";
					GotoState('vehReApproach');
				}
			}
		}
		else	//enemy behind us
		{
			//FIXME perhaps put in stuff for when enemy is facing us
			tmpString = "STANDOFF";
			GotoState('vehStandoff');
		}
	}
	`GoalString = tmpString@GoalString;
	return;
}

/////////////////////////////////////////
// New Changes for DefaultWeapon Firing code
/////////////////////////////////////////

//tighten the firing cone, and add clause for "leading"
//(since the car can't just "shoot" in a leading direction without facing it)
function bool NeedToTurnForWeapon(vector targ, Weapon curWeapon)
{
	local vector LookDir,AimDir;
	
	if(leadTarget(curWeapon) && currentlyLeading())
		return NeedToTurnToLead();

	LookDir = Vector(Pawn.Rotation);
	LookDir.Z = 0;
	LookDir = Normal(LookDir);
	AimDir = targ - Pawn.Location;
	AimDir.Z = 0;
	AimDir = Normal(AimDir);
	return ((LookDir Dot AimDir) < 0.98);
}

//check if we're facing our Lead destination, rather than bot
function bool NeedToTurnToLead()
{
	local vector LookDir,AimDir;

	LookDir = Vector(Pawn.Rotation);
	LookDir.Z = 0;
	LookDir = Normal(LookDir);
	AimDir = Destination - Pawn.Location;
	AimDir.Z = 0;
	AimDir = Normal(AimDir);
	
	return ((LookDir Dot AimDir) < 0.98);
}

function bool DefaultWeaponFireAgain(float RefireRate, bool bFinishedFire)
{
	LastFireAttempt = Level.TimeSeconds;
	if ( Target == None )
		Target = Enemy;
	if ( Target != None )
	{
		if ( !Pawn.DefaultWeapon.IsFiring() )
		{
			if ( Pawn.DefaultWeapon.bMeleeWeapon || (!NeedToTurnForWeapon(Target.Location, Pawn.DefaultWeapon) &&  Pawn.DefaultWeapon.CanAttack(Target)))
			{
				Focus = Target;
				bCanFire = true;
				bStoppedFiring = false;
				bFireSuccess = Pawn.DefaultWeapon.BotFire(bFinishedFire);
				return bFireSuccess;
			}
			else
			{
				bCanFire = false;
			}
		}
		else 
		{
			if (bCanFire && (FRand() < RefireRate))
			{
				if ( Target != None && Focus == Target )
				{
					bStoppedFiring = false;
					bFireSuccess = Pawn.DefaultWeapon.BotFire(bFinishedFire);
					
					return bFireSuccess;
				}
			}
		}
	}
	
	StopFiring();
	return false;
}

////////////////////////////////
//States
////////////////////////////////

state RidingVehicle
{
ignores EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
	NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;


	event NotifyRunOver(Pawn car) {}

	function Timer()
	{
		TimedFireWeaponAtEnemy();
	}

	function float AdjustAimError(float aimerror, float TargetDist, bool bDefendMelee, bool bInstantProj, bool bLeadTargetNow )
	{
		return Super.AdjustAimError(aimerror*2.0f, TargetDist, bDefendMelee, bInstantProj, bLeadTargetNow );
	}

	function BeginState()
	{
		//Pawn.SetPhysics(PHYS_None);
	}

	function EndState()
	{
		DesiredCar = None;
		Pawn.SetPhysics(PHYS_Falling);
	}

	function Tick(float dT)
	{
		Super.Tick(dT);
		if(Enemy != None)
		{
			Focus = Enemy;
			Pawn.DesiredRotation = Rotator(Focus.Location - Pawn.Location);
		}
		else
		{
			Focus = None;
			FocalPoint = Vector(VGPawn(Pawn).RiddenVehicle.Rotation)* 100;
			Pawn.DesiredRotation = VGPawn(Pawn).RiddenVehicle.Rotation;
		}
		Pawn.FaceRotation(Pawn.DesiredRotation , dT );
	}


BEGIN:
	
	`GoalString = "Riding Car, shooting dudes.";
	MoveTimer = 0;
	Sleep(2*FRand());
	WhatToDoNext(60);
}


state BaseVehicleState
{
	event NotifyRunOver(Pawn car) {}
	event bool NotifyBump(actor Other)	{return false;}

	//override to make sure we don't keep shooting when we've lost our bead
	function bool WeaponFireAgain(float RefireRate, bool bFinishedFire)
	{
		local bool facingTarget;

		LastFireAttempt = Level.TimeSeconds;
		if ( Target == None )
			Target = Enemy;
		if ( Target != None )
		{
			if ( !Pawn.Weapon.IsFiring() )
			{
				if ( Pawn.Weapon.bMeleeWeapon || (!NeedToTurn(Target.Location) && CanAttack(Target)) || ChargeWeapon() )
				{
					Focus = Target;
					bCanFire = true;
					bStoppedFiring = false;
					bFireSuccess = Pawn.Weapon.BotFire(bFinishedFire);
					return bFireSuccess;
				}
				else
				{
					bCanFire = false;
				}
			}
			else 
			{
				facingTarget = !NeedToTurn(Target.Location);
				//Charge weapon holds trigger while not facing target or by chance if facing target
				//Regular weapons holds trigger while facing target and by chance
				if ( (ChargeWeapon() && !facingTarget ) ||
					(bCanFire && (FRand() < RefireRate)) )
				{
					if ( Target != None && Focus == Target )
					{
						//don't let go and re-pull trigger when the combat timer is faster than the refire rate
						//and we're still facing the target
						if(bFinishedFire == false && facingTarget)
						{
							return true;
						}
						bStoppedFiring = false;
						bFireSuccess = Pawn.Weapon.BotFire(bFinishedFire);

						return bFireSuccess;
					}
				}
			}
		}
		StopFiring();
		return false;
	}

	function bool NeedToTurn(vector targ)
	{
		return NeedToTurnForWeapon(targ, Pawn.Weapon);
	}

	function Timer()
	{
		Focus = Enemy;
		TimedFireWeaponAtEnemy();
	}

	function Tick(float dT)
	{
		if(CurEnemy != Enemy)
		{
			CurEnemy = Enemy;
			EnemyFacingTime = 0.0f;
		}
		if(CurEnemy != None && ( vector(Enemy.Rotation)dot(car.location - Enemy.Location) > 0.95f )	)
			EnemyFacingTime += dT;
		else
			EnemyFacingTime = 0;
	}

}

state vehRestFormation extends BaseVehicleState
{
	ignores EnemyNotVisible;


BEGIN:
	if(Car.Anchor == None && Car.LastAnchor != None)
	{	
		DriveToward(Car.LastAnchor);
	}
	else
	{
		Car.bBrake = true;
		Car.Throttle = 0;
		Sleep(1+Frand());
		Car.bBrake = false;
	}
	WhatToDoNext(55);
}


state vehDriveToGoal extends BaseVehicleState
{

	event NotifyCarStuck()
	{
		if(!bWaitingForPassenger)
		{
			Global.NotifyCarStuck();
		}
	}

	function ContinueOnFoot()
	{
		local NavigationPoint tmpAnchor;
		
		//Remember why we're getting out of the car, and when we get there (or decide not to go there afterall)
		//we head back to our last car
		DesiredCar = None;
		tmpAnchor = Pawn.Anchor;
		ExitVehicle();
		Pawn.Anchor = tmpAnchor;
		
		GotoState('vehDriveToGoal', 'CONTINUEONFOOT');	
	}

	function bool IsPotentialPassenger(VGPawn Other)
	{
		return ( Other != None && Other.RiddenVehicle == None);
	}

	function bool WorthWaitingFor(Pawn Other)
	{
		local float dist, FOV, approach;

		dist = VSize(Other.Location - Pawn.Location);
		if(dist < 2000)
		{
			FOV = Normal(Pawn.Location - Other.Location) Dot vector(Other.Rotation);
            approach = Normal(Pawn.Location - Other.Location) Dot Normal(Other.Velocity);
			if(FOV > 0.9 && approach > 0.707)
			{
				return true;
			}
		}

	}

	function bool ShouldWaitForPassenger()
	{
		local Controller C;

		if( ! Car.FreePassengerPoint())
			return false;

		//So close to goal it's not worth waiting
		if( VSize(RouteGoal.Location - Pawn.Location) < 3500 )
		{
			return false;
		}

		//Check if teamates might want rides.
		for(C=Level.ControllerList; C!= None; C=C.NextController)
		{
			if(SameTeamAs(C) && IsPotentialPassenger( VGPawn(C.Pawn) ) )
			{
				if( WorthWaitingFor( C.Pawn ) )
					return true;
			}
		}
		return false;
	}

	function BeginState()
	{
		WaitForPassengerTime = Level.TimeSeconds;
	}

	function grrLog()
	{
		local float dist;
		DrivableDistance(dist);
		`GoalString = self@"VehDriveToGoal DriveDist:"@dist@ "WorthDriving:"@WorthDriving()@GoalString;
		//log(GoalString);

	}

CONTINUEONFOOT:
	WaitForLanding();
	Super.SetAttractionState();

BEGIN:

	grrLog();
		
	if( WorthDriving() )
	{
		Car.bBrake = false;
		
		if( ShouldWaitForPassenger() && Level.TimeSeconds < WaitForPassengerTime + 5.0)
		{
			Car.bBrake = true;
			`GoalString = "Waiting For Passenger";
			bWaitingForPassenger = true;
			Sleep(1);
			Car.ResetStuck();
			bWaitingForPassenger = false;
			Goto('BEGIN');
		}
		WaitForPassengerTime = Level.TimeSeconds;
			

        FollowPath();
        //@@@  TEST ONLY
		//if(testVal == 0) FollowPath();
        //else if (testVal == 1) DriveToward(MoveTarget);
        //else MoveToward( MoveTarget );

		WhatToDoNext(50);
	}
	else
	{
		ContinueOnFoot();	
	}
}



state vehHunting extends BaseVehicleState
{
	function SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			Focus = Enemy;
			WhatToDoNext(51);
		}
		else
			Global.SeePlayer(SeenPlayer);
	} 

	function PickDestination()
	{
		// If no enemy, or I should see him but don't, then give up	
		if ( LostContact(9) && LoseEnemy() )
			return;
		if ( (Enemy == None) || (Enemy.Health <= 0) )
		{
			WhatToDoNext(51);
			return;
		}
		
		if ( ActorReachable(Enemy) )
		{
			BlockedPath = None;
			if ( (LostContact(6) && (((Enemy.Location - Pawn.Location) Dot vector(Pawn.Rotation)) < 0)) 
				&& LoseEnemy() )
				return;

			Destination = Enemy.Location;
			MoveTarget = None;
			return;
		}

		if ( FindBestPathToward(Enemy, true, true) )
			return;

		MoveTarget = None;

		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);
	}	

Begin:
	PickDestination();
SpecialNavig:
	if(Enemy == None)
	{
		WhatToDoNext(51);
	}
	if ( (MoveTarget == None) && ActorReachable(Enemy) )	//this really should never happen
		DriveToward(Enemy);
	else if (MoveTarget == None)
	{
		//FIXME, this should work better
		GotoState('vehRestFormation');
		Sleep(0.1);
	}
	else
		FollowPath();

	WhatToDoNext(51);
	if ( bSoaking )
		SoakStop("STUCK IN HUNTING!");
}




state vehChargeAttack extends BaseVehicleState
{

	function bool currentlyLeading()
	{
		return leadTarget(Pawn.Weapon);
	}

	event bool NotifyBump(actor Other)
	{
		if ( (VGVehicle(Other) != None) && (Enemy == Other) )
			GotoState('vehReApproach');
		return Global.NotifyBump(Other);
	}

	event NotifyApproachingDestination()
	{
		WhatToDoNext(52);
	}

BEGIN:
	//log("MIKEH: State vehChargeAttack");
ATTACK:
	if(Enemy == none)
	{
		WhatToDoNext(52);
	}
	if(Pawn.Weapon != None && leadTarget(Pawn.Weapon))
		DriveToward(Enemy, 5000, false, Pawn.Weapon.FireMode[Pawn.Weapon.BotMode].ProjectileClass.default.speed );
	else
		DriveToward(Enemy, 5000, false, 0.7 * maxCarSpeed);
	WhatToDoNext(52);
RAM:
	DriveToward(Enemy, , false, 0.7 * maxCarSpeed );
	Sleep(0.1);
	WhatToDoNext(52);
}



//try to keep a bead on enemy as opposed to driving at it.
state vehStandoff extends BaseVehicleState
{

	function bool currentlyLeading()
	{
		return leadTarget(Pawn.Weapon);
	}

	//Since the attack style involves not moving, don't assume vehicle is stuck
	event NotifyCarStuck()	{}

	function EndState()
	{
		Car.ResetStuck();
		Car.bBrake = false;
	}

	function bool AimInReverse()
	{
		local bool bDistanceClosing;
		local vector enemyDir;
		local float enemyDist;
		local vector testLocation;

		if(Car.Anchor == None || !Car.Anchor.IsA('RoadPathNode'))
		{
			return false;
		}
		else // anchor is a road, see if reversing would take us off it.
		{
			testLocation = Car.Location - 3.0f * Car.CollisionRadius * vector(Car.Rotation);
			if( VSize(testLocation - Car.Anchor.Location) > Car.Anchor.CollisionRadius )
				return false;

		}
		enemyDir = Enemy.Location - car.Location;
		enemyDist = VSize(enemyDir);
		enemyDir = Normal(enemyDir);

		bDistanceClosing = (Enemy.Velocity dot enemyDir) - (Car.Velocity dot enemyDir) <  0.0f;
	
		//if we're going fast enough, we can handbrake turn instead of reverse
		if( (Car.Throttle > 0) && (VSize(car.Velocity) > 750) )
			return false;

		//if we're too close, the distance is closing, or i'm not facing directly enough
		//I ought to keep a bead in reverse	
		if (enemyDist < 3000 || (bDistanceClosing && enemyDist < 5000) || (vector(Car.Rotation) dot enemyDir) < 0.7f)
		{
			`GoalString = "REV"@GoalString;
			return true;
		}

		return false;
	}

BEGIN:
	if (Enemy == None)
	{
		WhatToDoNext(53);
	}

	if(Pawn.Weapon != None && leadTarget(Pawn.Weapon))
		DriveToward(Enemy, 0, true, Pawn.Weapon.FireMode[Pawn.Weapon.BotMode].ProjectileClass.default.speed, AimInReverse() );
	else
		DriveToward(Enemy, 0, true, , AimInReverse());
	WhatToDoNext(53);
}



state vehReApproach extends BaseVehicleState
{
	ignores EnemyNotVisible;

	function BeginState()
	{
		bAvoidAll = true;

	}
	function EndState()
	{
		Car.ResetStuck();
		Car.bBrake = false;
		bAvoidAll = false;
	}

	event NotifyApproachingDestination()
	{
		WhatToDoNext(54); 
	}

	function PickDestination()
	{
		local NavigationPoint N;
		N = FindRandomDest();
		if(N != None)
		{
			MoveTarget = None;
			MoveTarget = FindPathToward(N);
		}
		
		if(MoveTarget == None)
		{
		    // If we can't back up any more, RAMMING SPEED!
			GotoState('vehChargeAttack', 'RAM');
	    }

	}

	//calculate how far from the random node we need to be (approximately)4000 units farther from enemy 
	function float calcApproachDist()
	{
		local float dist;
		dist = VSize(Pawn.Location - MoveTarget.Location) - MINREAPPROACHDISTANCE;
		if( dist < 0)
			return 0;
		else
			return dist;
	}

BEGIN:
	//log("MIKE: State vehReApproach.");
	PickDestination();

LEAVE:
	if (Enemy == None)
	{
        if ( ChooseAttackCounter > 3 )
            log("REAPPROACH ENEMY Enemy==None");
		WhatToDoNext(54);
	}
	else if ( (MoveTarget != None) && (VSize(Enemy.Location - Pawn.Location) < MINREAPPROACHDISTANCE) )
    {
        if ( ChooseAttackCounter > 3 )
            log("REAPPROACH ENEMY PreDriveToward" @Level.TimeSeconds);
        DriveToward(MoveTarget, calcApproachDist());
        if ( ChooseAttackCounter > 3 )
            log("REAPPROACH ENEMY PostDriveToward" @Level.TimeSeconds);
    }

	WhatToDoNext(54);
}

state vehAvoidFire extends BaseVehicleState
{
ignores EnemyNotVisible;

BEGIN:
	DriveToward(Enemy, , , , , true );
	WhatToDoNext(57);
}

state vehCarStuck extends BaseVehicleState
{
ignores EnemyNotVisible;

	function setSteeringAndThrottle()
	{
		//reverse direction
		Car.bBrake = false;
		if(Car.Throttle > 0)
			Car.Throttle = -1;
		else
			Car.Throttle = 1;

		Car.Steering *= -1;
	}

	function EndState()
	{
		Car.ResetStuck();
		Car.Steering *= -1;
	}

BEGIN:
	setSteeringAndThrottle();
	//FIXME: Test UnStuck Direction.
	Sleep(1);
	WhatToDoNext(56);
}

//The car is dead, and disabled, and waiting to explode.
state vehCarDying extends BaseVehicleState
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
	NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

	function Timer() {}

BEGIN:
	if(frand()< 0.33)
	{
		Sleep(frand()*3.0);
		ExitVehicle();
		WhatToDoNext(58);
	}
	//else wait for our car to die.
}


/////////////////////////////// miscellaneous
state Dumb
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
	NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

	event NotifyCarStuck()
	{
	}
	function BeginState()
	{
		StopFiring();
		SetTimer(0, false);
	}

	function EndState()
	{
		TimedFireWeaponAtEnemy();
	}

BEGIN:
	if(bInCar)
	{
		Car.Throttle = 0.1;
		Car.Steering = 1;
	}
	else
	{
		Pawn.Velocity.X = 0.1;
		Pawn.Velocity.Y = 0.1;
		Pawn.Velocity.Z = 0.0;
	}
	Sleep(0.0);
	Goto('Begin');
}

function TimedFireWeaponAtEnemy()
{
	if(bWimp)
	{
		StopFiring();
		SetTimer(0, false);
	}
	else
	{
		Super.TimedFireWeaponAtEnemy();
	}
}

function bool FireWeaponAt(Actor A)
{
	local bool returnValA, returnValB;

	if(bWimp)
		return false;	
	
	if ( A == None )
		A = Enemy;
	if ( (A == None) || (Focus != A) )
		return false;
	Target = A;
	if ( (Pawn.Weapon != None) && Pawn.Weapon.HasAmmo() )
	{
		returnValA = WeaponFireAgain(Pawn.Weapon.RefireRate()*RefireAtten,false); // sjs - tweaked refire rate of bots
	}
	if ( (Pawn.DefaultWeapon != None) && Pawn.DefaultWeapon.HasAmmo() )
	{
		Pawn.DefaultWeapon.BotMode = 1;
		returnValB = DefaultWeaponFireAgain(Pawn.DefaultWeapon.RefireRate()*RefireAtten,false);
	}
	return returnValA || returnValB;
}

defaultproperties
{
}
