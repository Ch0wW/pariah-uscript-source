// an auto turret placeable in the mini editor that uses a radius check to pick targets
class MiniEdAutoTurret extends VGBarrelActivationTurret
	placeable;

// valid attacking distance
var float AttackRadius;
var float FindTargetFreq;
var StaticMesh ColMesh;

simulated function PostBeginPlay()
{
	local SpecialStaticMesh SSM;

	Super.PostBeginPlay();
	SetTimer(FindTargetFreq, true);

	SSM = Spawn( class'SpecialStaticMesh',,, Location, Rotation );
	SSM.SetStaticMesh(ColMesh);
	SSM.SetDrawScale(0.5);
}

// check if a pawn is already detected
function bool AlreadyDetected(Pawn victim)
{
	local int n;

	for(n = 0; n < DetectedPawns.Length; n++) {
		if(DetectedPawns[n] == victim)
			return true;
	}

	return false;
}

// check for new victims at regular intervals
simulated function Timer()
{
	local VGPawn victim;
    local VGVehicle vehiclevictim;
	local int n;
    local int numDetected;

	if( !bIsOn || bDisabled)
		return;

	if( Role == ROLE_Authority )
	{
        numDetected = DetectedPawns.Length;

	    // scan for victims
	    foreach VisibleCollidingActors(class'VGPawn', victim, AttackRadius, Location) 
        {
		    if(!AlreadyDetected(victim) && (Normal(victim.Location-Location) dot vector(HeadRot) ) > 0.2) 
            {
			    DetectedPawns[numDetected] = victim;
                //log("victim:  " $victim);
		    }
        }
        foreach VisibleCollidingActors(class'VGVehicle', vehiclevictim, AttackRadius, Location) 
        {
	        if(!AlreadyDetected(vehiclevictim) && (Normal(vehiclevictim.Location-Location) dot vector(HeadRot) ) > 0.2
                && vehiclevictim.bIsDriven ) 
            {
			    DetectedPawns[numDetected] = vehiclevictim;
                //log("vehiclevictim:  " $vehiclevictim);
		    }
	    }

	    // check if any of our victims have left our attack range
	    for(n = 0; n < numDetected; n++) 
        {
		    if(DetectedPawns[n] != None)
            {
                if(VSize(DetectedPawns[n].Location-Location) > AttackRadius)
                {
			        RemoveDetected(DetectedPawns[n]);
                }
                // make sure vehicle can still be shot at
                else
                {
                    vehiclevictim = VGVehicle(DetectedPawns[n]);
                    if(vehiclevictim != None && !vehiclevictim.bIsDriven)
                    {
			            RemoveDetected(DetectedPawns[n]);
                    }
                }
            }
	    }

		if( NoTarget() )
		{
			//log( "no target" );

			//If the barrel was turning wind down
			if( BarrelState == BS_Turning )
			{
				//log( "BarrelState = BS_WindingDown" );
				BarrelState = BS_WindingDown;
			}
			
			//log( "GetTarget called from Timer" );
			GetTarget();
		}
	}
    // jjs - client simulated version of above block
    else
    {
        if( Target == None )
        {
            TurnItOff();
			if( BarrelState == BS_Turning )
			{
				BarrelState = BS_WindingDown;
			}
        }
        else
        {
		    if( AnimState == AS_NotActivated || AnimState == AS_DeActivating )
		    {
			    AnimState = AS_Activating;
			    PlayAnim( UpAnim, 0.7, 0.1 );
			    WindingUpSound();
		    }
		    else if( AnimState != AS_DeActivating )
		    {
			    AnimState = AS_Moving;
		    }
	    }
	    if( bFire )
	    {
		    bFire = false;
	    }

    }
    // - jjs

	if( bTurretPans && AnimState != AS_NotActivated )
		SetDesiredRotation();

	if( BarrelState == BS_Turning && Target != none )
	{
		//log( "bFire!" );
		bFire = true;
	}
	else if( bFire )
	{
		//log( "bFire = FALSE" );
		bFire = false;
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
     AttackRadius=2000.000000
     FindTargetFreq=0.150000
     ColMesh=StaticMesh'JamesMiniEd.Collision.PlayerTurretStaticCollision'
     bIsOn=True
     VehicleDamage=15
     CollisionRadius=80.000000
     CollisionHeight=90.000000
     EventBindings(0)=(EventName="TurretXSwitch",HandledBy="TurretSwitch")
     EventBindings(1)=(EventName="PawnInTurretXVolume",HandledBy="PawnInTurretVolume")
     EventBindings(2)=(EventName="PawnOutOfTurretXVolume",HandledBy="PawnOutOfTurretVolume")
     bWorldGeometry=True
     bUseCylinderCollision=True
     bBlockKarma=True
}
