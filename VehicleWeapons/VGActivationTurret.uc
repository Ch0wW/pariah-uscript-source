/*
	VGActivationTurret
	Desc: A Turret that :
			- has an activation time where it animates to its 'ready to track' position
	xmatt
*/

class VGActivationTurret extends Turret
	notplaceable;

//Animation
var Name	UpAnim;
var Name	DownAnim;
var() Material ActivatedTexture;

//Panning
var() bool	bTurretPans; //Rotates horizontally as if searching for player
var bool	bPanningInit;
var() int	MaxPanningDegrees; //[degrees]
var int		PanningUDegree; //[unreal degrees]
var() int	PanningSpeed; //[degrees/second]

//debug
var rotator PrevDesiredRotation;

var enum EAnimationState
{
	AS_NotActivated,
	AS_Activating,
	AS_DeActivating,
	AS_Moving,
	AS_Ready
} AnimState;


function PreBeginPlay()
{
    super.PreBeginPlay();
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if( bIsOn )
	{
		//log( "PostBeginPlay - Setting to actived texture" );
		SetSkin(0,ActivatedTexture);	//removed to save texture memory.
	}
	
	//Orient the head of the turret in the same direction as the turret actor
	HeadRot = DefaultRotation;
	SetBoneDirection( 'Head01', HeadRot, vect(0,0,0), 1.0, 1 );
}


event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	switch( handler )
	{
	case 'TurretSwitch':
		bIsOn = !bIsOn;
		
		if( bIsOn )
		{
			//Set to active texture
			//log( "setting to actived texture" );
			SetSkin(0,ActivatedTexture);	//removed to save texture memory
		}
		else
		{
			TurnItOff();
			if( bFire )
			{
				bFire = false;
			}
			
			//Set to inactive texture
			//log( "setting to inactived texture" );
			Skins.Remove( 0, Skins.Length );
		}
		break;
	default: 
		Super.TriggerEx(sender, instigator, handler, realevent);
		break;
	}
}

		
simulated function TurnItOff()
{
	//log( "Called TurnItOff" );
	if( AnimState != AS_NotActivated && AnimState != AS_DeActivating )
	{
		//log( "AnimState = AS_DeActivating" );
		//log( "Pawns in list= " $ DetectedPawns.Length );
		AnimState = AS_DeActivating;
        if(Level.NetMode != NM_DedicatedServer)
    		PlayAnim( DownAnim, 0.6, 0.1 );
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
			GetTarget();
		}
	}
	
	//Set the desired rotation
	//Note: when not activated, we pick the desired rotation differently
	if( bTurretPans && AnimState != AS_NotActivated )
		SetDesiredRotation();

	if( Target != none )
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


simulated function MakeTurretPan( float dt )
{
	local Coords HeadCoords;
	local vector HeadPos;
	local int	 HalfMaxPanningUDegrees;
	local int	 PanningUSpeed;
	local rotator temp;
	
	HeadCoords = GetBoneCoords( 'head' );
	HeadPos = HeadCoords.Origin;
	
	//Turn the max panning degrees in unreal rotation units
	HalfMaxPanningUDegrees = 0.5f * MaxPanningDegrees * 65536 / 360;
	PanningUSpeed = PanningSpeed * 65536 / 360;
	
	//To handle the case where the head is outside the panning area
	if( !bPanningInit )
	{
		bPanningInit = true;
	
		if( HeadRot.Yaw ClockwiseFrom DefaultRotation.Yaw )
		{
			//Turn counter-clockwise
			if( PanningSpeed > 0 )
				PanningSpeed *= -1;

			DesiredRotation = DefaultRotation;
			DesiredRotation.Yaw -= HalfMaxPanningUDegrees;
			
			PrevDesiredRotation.Yaw = DesiredRotation.Yaw + 2.0*HalfMaxPanningUDegrees;
		}
		else
		{
			//Turn clockwise
			if( PanningSpeed < 0 )
				PanningSpeed *= -1;

			DesiredRotation = DefaultRotation;
			DesiredRotation.Yaw += HalfMaxPanningUDegrees;
			
			PrevDesiredRotation.Yaw = DesiredRotation.Yaw - 2.0*HalfMaxPanningUDegrees;		
		}
	}

	HeadRot.Yaw = CircularAddToDesired( HeadRot.Yaw, DesiredRotation.Yaw, PanningUSpeed * dt );

	if( (HeadRot.Yaw & 65535) == (DesiredRotation.Yaw & 65535) )
	{
		temp = PrevDesiredRotation;
		PrevDesiredRotation = DesiredRotation;
		PanningSpeed = -PanningSpeed;
		DesiredRotation = temp;
	}
	
	SetBoneDirection( 'Head01', HeadRot, vect(0,0,0), 1.0, 1 );
	
	if( bShowDebug )
	{
		//Previous desired and new desired rotation
		drawdebugline( HeadPos,  HeadPos + 400*Vector(DesiredRotation), 0, 255, 0 );	
		drawdebugline( HeadPos,  HeadPos + 400*Vector(PrevDesiredRotation), 255, 0, 0 );	
	}
}


simulated function MoveParts( float dt )
{
	//
	//Head
	//
	if( AnimState == AS_NotActivated )
	{
		//Make the turret pan
		if( bTurretPans && PanningSpeed != 0.0 )
			MakeTurretPan( dt );
	}
	else
	{
		if( bTurretPans && bPanningInit )
		{
			//log( "bPanningInit = false" );
			bPanningInit = false;
		}
		
		if( AnimState == AS_DeActivating )
		{
			//log( "Deactivating to rotation: " $ DefaultRotation );
			//DesiredRotation = DefaultRotation;
			DesiredRotation = Rot(0,0,0);
		}

		UpdateHeadRotation( dt );
	}

	//
	//Animation
	//
	if( AnimState == AS_DeActivating )
	{
		if( HeadRot == rot(0,0,0) )
		{
			//log( "AnimState = AS_NotActivated" );
			AnimState = AS_NotActivated;
		}
	}
	else if( AnimState == AS_Activating || AnimState == AS_Moving )
	{
		if( AreEqual( HeadRot, DesiredRotation ) )
		{
			//log( "AnimState = AS_Ready" );
			AnimState = AS_Ready;
		}
	}
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


simulated function Destroyed()
{
	//if( BulletShells != none )
	//{
	//	BulletShells.Destroy();
	//}
	Super.Destroyed();
}

defaultproperties
{
     MaxPanningDegrees=45
     PanningSpeed=20
     ActivatedTexture=Texture'PariahWeaponTextures.TurretChapter3.GunTurretON'
     UpAnim="Up"
     DownAnim="Down"
     EventBindings(0)=(EventName="TurretXSwitch",HandledBy="TurretSwitch")
     bHasHandlers=True
}
