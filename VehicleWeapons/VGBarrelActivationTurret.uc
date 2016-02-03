/*
	VGBarrelActivationTurret
	Desc: VGActivationTurret that :
			- has a barrel that needs to roll the barrel to a certain
			  speed before being able to fire
	xmatt
*/

class VGBarrelActivationTurret extends VGActivationTurret
	notplaceable;

var() int	BarrelWindUpAcc;
var() int	BarrelWindDownAcc;
var() int	BarrelMaxSpeed;
var int		BarrelSpeed;
var Rotator BarrelRot;
var() sound BarrelWindingUp;
var() sound BarrelWindingDown;

var enum EBarrelState
{
	BS_AtRest,
	BS_WindingDown,
	BS_WindingUp,
	BS_Turning
} BarrelState;

function PreBeginPlay()
{
    super.PreBeginPlay();
}


simulated function TurnItOff()
{	
	if( AnimState != AS_NotActivated && AnimState != AS_DeActivating )
	{
		AnimState = AS_DeActivating;
        if(Level.NetMode != NM_DedicatedServer)
    		PlayAnim( DownAnim, 0.6, 0.1 );
		WindingDownSound();
	}
}


simulated function MoveParts( float dt )
{
	Super.MoveParts( dt );

	//
	//Barrel
	//
	if( BarrelState == BS_WindingUp )
	{
		BarrelSpeed = FClamp( BarrelSpeed + BarrelWindUpAcc * dt, 0, BarrelMaxSpeed );

		if( BarrelSpeed == BarrelMaxSpeed )
		{
			BarrelState = BS_Turning;
		}

        if( Level.NetMode != NM_DedicatedServer )
        {
		    BarrelRot.Roll += BarrelSpeed * dt;
		    SetBoneRotation( 'Barrel', BarrelRot, 0, 1.0 );
        }
	}
	else if( BarrelState == BS_WindingDown )
	{
		BarrelSpeed = FClamp( BarrelSpeed - BarrelWindDownAcc * dt, 0, BarrelMaxSpeed );
		BarrelRot.Roll += BarrelSpeed * dt;

		if( BarrelSpeed == 0 )
		{
			BarrelState = BS_AtRest;
		}

        if( Level.NetMode != NM_DedicatedServer )
        {
    		SetBoneRotation( 'Barrel', BarrelRot, 0, 1.0 );
        }
	}
	else if( BarrelState == BS_Turning )
	{
        if( Level.NetMode != NM_DedicatedServer )
        {
    		BarrelRot.Roll += BarrelSpeed * dt;
	    	SetBoneRotation( 'Barrel', BarrelRot, 0, 1.0 );
        }
	}

	//
	//Animation
	//
	if( AnimState == AS_Ready )
	{
		//log( "MoveParts - AnimState == AS_Ready" );

		if( BarrelState != BS_Turning && BarrelState != BS_WindingUp )
		{
			//log( "Setting BarrelState to BS_WindingUp" );
			BarrelState = BS_WindingUp;
		}
	}
}


simulated function WindingDownSound()
{
	bPlayingBarrelFiring = false;		
    AmbientSound = None;
    PlaySound( BarrelWindingDown, SLOT_Misc, TransientSoundVolume, , 2000 );    
}


simulated function WindingUpSound()
{
    AmbientSound = BarrelWindingUp;
}


function GetTarget()
{
	GetTargetCommon();

	if( NoTarget() )
	{
		Target = None;
		TurnItOff();
	}
	else
	{
		//Last check if for the case where the turret is still deactivating while the pawn enters another volume
		if( AnimState == AS_NotActivated || AnimState == AS_Activating || AnimState == AS_DeActivating )
		{
			//log( "AnimState = AS_Activating" );
			AnimState = AS_Activating;
            if(Level.NetMode != NM_DedicatedServer)
    			PlayAnim( UpAnim, 0.7, 0.1 );
			WindingUpSound();
		}
		else if( AnimState != AS_DeActivating )
		{
			//log( "Moving..." );
			AnimState = AS_Moving;
		}
	}

	if( bFire )
	{
		bFire = false;
	}
}


simulated function Timer()
{
	if( !bIsOn || bDisabled)
		return;

	if( Role == ROLE_Authority )
	{
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

	//Set the desired rotation
	//Note: when not activated, we pick the desired rotation differently
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


simulated function Destroyed()
{
	TurnItOff();
    Super.Destroyed();
}

defaultproperties
{
     BarrelWindUpAcc=200000
     BarrelWindDownAcc=200000
     BarrelMaxSpeed=200000
     BarrelWindingUp=Sound'SM-chapter03sounds.TurretSpinA'
     BarrelWindingDown=Sound'SM-chapter03sounds.TurretStopSpinng'
     bTurretPans=True
     TraceOffset=(X=150.000000,Z=24.000000)
     EventBindings(0)=(EventName="TurretXSwitch",HandledBy="TurretSwitch")
     EventBindings(1)=(EventName="PawnInTurretXVolume",HandledBy="PawnInTurretVolume")
     EventBindings(2)=(EventName="PawnOutOfTurretXVolume",HandledBy="PawnOutOfTurretVolume")
}
