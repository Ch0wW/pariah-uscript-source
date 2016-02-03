//=============================================================================
//=============================================================================
class C8ZipDropShip extends HavokDropShip
	placeable;

var(Turret) LobTurret Turret;
var(Turret) vector TurretRelativePosition;

var bool bFiringDone;

var StaticMesh AltMesh;

//Zip lines
var		bool				bPreparingToDrop;
var()	name				StageToJoinName;
var		Stage				StageToJoin;
var()	bool				bUsesZipLines;
var		bool				bDroppingPawns;
var		bool				bDetachedPawns;
var		SPPawnZipLineDropper DroppedPawn[4];
var		MiniEdStaticMesh	ZipLine[4];
var		vector				ZipLineFallPoint[4];
var		byte				bDetachedFromZipLine[4];
var		byte				bZipLineBackUp[4];
var		int					ZipLineDropSpeed[4];
var		float				ZipLineHeight[4];
var		float				ZipLineMaxHeight[4];
var()	int					ZipLinesDropSpeed;
var		int					ZipLineDropSpeedVariance;
var		float				ZipLineRiseSpeed;
var()	int					ZipLineStartRiseSpeed;
var()	int					ZipLineRiseAcceleration;
var()	float				ZipLineRiseTimer[4];
var		int					bHitGround[4];
var()	float				UnhookingTime;
var		float				UnhookingTimer[4];
var		int					KillWaitTime;
var		bool				bKillWait;
var		bool				bTriggeredNext;
var		bool				bZipDone;

var		StaticMesh				ZipLineMesh;
var		NoiseVertexModifier		ZipLineNoiseTexture;

var		float		DroppingTimer;
var		name		GetReadyToHook;
var		name		HookingAnim;
var		name		DescentAnim;
var		DistortionShieldDecay MyShield;
var		int			DeathCount;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	//Place the turret
	Turret = Spawn(class'LobTurret',self);
	Turret.LobBase = Spawn(class'LobTurBase');
	Turret.SeekDistance = 15000;

	Turret.SetDrawScale(0.45);
	Turret.LobBase.SetDrawScale(0.45);

	//The location must take is in world space
	Turret.SetLocation( Location + (TurretRelativePosition >> Rotation) );
	Turret.LobBase.SetLocation(Location + (TurretRelativePosition >> Rotation) );
	
	//The base of the turret must be the ship
	Turret.SetBase( Self );
	Turret.LobBase.SetBase( Self);
	Turret.bVulnerable=False;
}

simulated function PostBeginPlay()
{
	local vector ZipLinePos;
	local rotator ZipLineRot;
	local vector DropperPos;
	local rotator DropperRot;
	local Stage S;
	
	Super.PostBeginPlay(); 

	bZipDone=False;
	SetTimer(55,False);
	bFiringDone=False;
	bTriggeredNext=False;

	//Zip lines
	if (Owner.MaxLights >=1)	
	{
		//Place the zip lines and droppers
		GetAttachPoint( 'zip01', ZiplinePos, ZiplineRot );
		SetupZipLine( 0, ZiplinePos );
		GetAttachPoint( 'p01', DropperPos, DropperRot );
		DropperPos.Z -= 15;
		SetFallPoint( 0, ZiplinePos, DropperPos );
		SetupDroppingPawn( 0, DropperPos, DropperRot );
	}
		
	if (Owner.MaxLights >=2)	
	{
		GetAttachPoint( 'zip02', ZiplinePos, ZiplineRot );
		SetupZipLine( 1, ZiplinePos );
		GetAttachPoint( 'p02', DropperPos, DropperRot );
		DropperPos.Z -= 15;
		SetFallPoint( 1, ZiplinePos, DropperPos );
		SetupDroppingPawn( 1, DropperPos, DropperRot );	
	}


	if (Owner.MaxLights  >=3)	
	{
		GetAttachPoint( 'zip03', ZiplinePos, ZiplineRot );
		SetupZipLine( 2, ZiplinePos );
		GetAttachPoint( 'p03', DropperPos, DropperRot );
		DropperPos.Z -= 15;
		SetFallPoint( 2, ZiplinePos, DropperPos );
		SetupDroppingPawn( 2, DropperPos, DropperRot );
	}
	
	if (Owner.MaxLights >=4)	
	{
		GetAttachPoint( 'zip04', ZiplinePos, ZiplineRot );
		SetupZipLine( 3, ZiplinePos );
		GetAttachPoint( 'p04', DropperPos, DropperRot );
		DropperPos.Z -= 15;
		SetFallPoint( 3, ZiplinePos, DropperPos );
		SetupDroppingPawn( 3, DropperPos, DropperRot );
	}

	if (Owner.MaxLights==0) bZipDone=True;

	//Find the stage to join
	//log( "Looking for this stage with tag name: " $ StageToJoinName );
	ForEach AllActors( class'Stage', S )
	{
		if( S.StageName == StageToJoinName )
		{
			StageToJoin = S;
			//log( "Droppers found a stage to join: " $ StageToJoinName );
			break;
		}
	}
	GettingReady();

	MyShield=Spawn( class'DistortionShieldDecay');
	MyShield.SetBase(self);

}


function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, 
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
	if( bDying )
		return;
	
	if(MyShield!=None)
	{
		MyShield.OnShield(EventInstigator);

	}


	Health -= Damage;

	if( Health < 0 && Health > -2200 )
	{
		Turret.bVulnerable=True;
		MyShield.Blow(EventInstigator);
	}
	else if( Health < -2200 && bZipDone )
	{
		bDying = true;
		BlowUpShip();
	}

//	Super.TakeDamage( Damage, EventInstigator, HitLocation, Momentum, DamageType, ProjOwner, bSplashDamage );
}




function AttachThis(Actor A, vector offset, rotator rotation)
{
	A.SetBase(self);
	A.SetRelativeLocation(offset);
	A.SetRelativeRotation(rotation);
}

simulated function SetFallPoint( int id, vector ZiplinePos, vector DropperPos )
{
	ZipLineFallPoint[id] = ZiplinePos;
	ZipLineFallPoint[id].Z -= (ZiplinePos.Z - DropperPos.Z);
}


simulated function SetupZipLine( int id, vector ZipLineLoc )
{
	//Spawn zip lines at the four attach points
	ZipLine[id] = Spawn( class'MiniEdStaticMesh' );
	
	//The base of the turret must be the ship
	AttachThis( ZipLine[id], ZipLineLoc, rot(0,0,0) );
	ZipLine[id].SetStaticMesh( ZipLineMesh );
	ZipLine[id].SetCollision( false, false, false );
	ZipLine[id].bCollideWorld = false;
	ZipLine[id].bHidden = false;
}

simulated function SetupDroppingPawn( int id, vector Loc, rotator Rot )
{



	DroppedPawn[id] = Spawn( class'SPPawnZipLineDropper', , , Location + Loc >> Rotation, Rot );
	if( DroppedPawn[id] != None )
		log( "Dropper " $ id $ " spawned correctly" );
	else
		log( "Dropper " $ id $ " spawned IN-correctly" );
	DroppedPawn[id].SetPhysics( Phys_None );
	DroppedPawn[id].SetCollision( false, false, false );
	DroppedPawn[id].bCollideWorld = false;
	AttachThis( DroppedPawn[id], Loc, Rot );
}


event TriggerEx( Actor sender, Pawn instigator, Name handler, Name realevent ) 
{
	Super.TriggerEx( sender, instigator, handler, realevent );
	
	switch( handler )
	{
	case 'DropGuys':
		//log("DropGuys was Triggered");
		if (Owner.MaxLights!=0) GoToState('DroppingPawns');
		break;
	}
}







//  Note: Don't delete self completely as it causes crash in
//  SceneManager if his has no affectedactor.
//
//
simulated function BlowUpShip()
{

	local int i;
	local DropShipChunks SM;
	
	if (Turret!=None)
		Turret.Explode();


	if( Level != None && Level.GetLocalPlayerController() != None )
		Level.GetLocalPlayerController().PlayOwnedSound( ShipBlowupSound,, TransientSoundVolume );
	
	if( ExplosionBurst2Class != None )
		spawn( ExplosionBurst2Class, , , Location );

	if ( Smoke1 != None )
		Smoke1.Kill();
	
	if ( Smoke2 != None )
		Smoke2.Kill();
		
	for( i=0; i<10; i++ )
	{
		SM = Spawn( SMeshClass[i],Self );

		if ( SM!=None )
			SM.SetLocation( Location + SM.ELoc );
	}

	for( i=0; i<LiveEmitters.Length; i++ )
		if ( LiveEmitters[i]!=None )
			LiveEmitters[i].Destroy();

	GotoState('Death');
}



simulated function Timer()
{

	if (bFiringDone)
		DeleteShip();

	if (Turret!=None)
		Turret.bStopFiring=True;
	bFiringDone=True;
	SetTimer(6,True);
}


simulated function DeleteShip()
{
	local int i;


	if (Turret!=None)
		Turret.Explode();

	if ( Smoke1 != None )
		Smoke1.Kill();
	
	if ( Smoke2 != None )
		Smoke2.Kill();
		
	for( i=0; i<LiveEmitters.Length; i++ )
		if ( LiveEmitters[i]!=None )
			LiveEmitters[i].Destroy();


	GotoState('Death');
				
}


state Death
{

simulated function Tick(Float DeltaTime)
{

}

function TakeDamage( int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, 
					 class<DamageType> DamageType, optional Controller ProjOwner, optional bool bSplashDamage )
{
}

simulated function Timer()
{
	DeathCount++;

	if (bKillWait)
	{
		KillWaitTime++;
		if (KillWaitTime>20) Destroy();  
	}

	If (DeathCount>60)   //If, after a 4 minutes, the next ship doesn't come... force the death of the guys to keep the level alive
	{
		if (DroppedPawn[0]!=None) DroppedPawn[0].TakeDamage( 1000, Instigator, Vect(0,0,0) ,Vect(0,0,1), class'Crushed');
		if (DroppedPawn[1]!=None) DroppedPawn[1].TakeDamage( 1000, Instigator, Vect(0,0,0) ,Vect(0,0,1), class'Crushed');
		if (DroppedPawn[2]!=None) DroppedPawn[2].TakeDamage( 1000, Instigator, Vect(0,0,0) ,Vect(0,0,1), class'Crushed');
		if (DroppedPawn[3]!=None) DroppedPawn[3].TakeDamage( 1000, Instigator, Vect(0,0,0) ,Vect(0,0,1), class'Crushed');
	}

	if (DroppedPawn[0]!=None && DroppedPawn[0].Health>=1)
		Return;

	if (DroppedPawn[1]!=None && DroppedPawn[1].Health>=1)
		Return;

	if (DroppedPawn[2]!=None && DroppedPawn[2].Health>=1)
		Return;

	if (DroppedPawn[3]!=None && DroppedPawn[3].Health>=1)
		Return;

	// Send a death event out 
	if (!bTriggeredNext) TriggerEvent( OnDeathEvent, self, None );   //Only Trigger Once.
	bTriggeredNext=True;

	bKillWait=True;   //Wait 70 seconds before destroying to make SURE ship had got to end of matinee path;		
}

Begin:
	KillWaitTime=0;
	bKillWait=False;
	SetStaticMesh(AltMesh);
	bHidden=True;
	SetCollision(False,False,False);
	bDying=False;
	SetTimer(4,true);
	DeathCount=0;
}



//
// Desc: drops pawns that come down on zip lines
//

state DroppingPawns
{
	function BeginState()
	{
		DroppingTimer = 0;
	}
	
	function EndState()
	{

		if (ZipLine[0]!=None) ZipLine[0].Destroy();
		if (ZipLine[1]!=None) ZipLine[1].Destroy();
		if (ZipLine[2]!=None) ZipLine[2].Destroy();
		if (ZipLine[3]!=None) ZipLine[3].Destroy();
	}

	function Tick( float dt )
	{
		local int	 i;
		local bool	 done;
					
		Global.Tick(dt);

		//If the animations for preparing the droppers to drop is done
		if( !bPreparingToDrop )
		{
			//If the ship has reached its destination it drops the pawns
			if( bDroppingPawns )
			{
				DroppingTimer += dt;
				
				if( !bDetachedPawns )
				{
					for( i=0; i < 4; i++ )
					{
						DroppedPawn[i].SetBase( none );
					}
					bDetachedPawns = true;
				}
				
				done = true;
				for( i=0; i < 4; i++ )
				{
					if( DroppedPawn[i] != None && bZipLineBackUp[i] == 0 )
					{
						UpdateZipLine( i, dt );
						done = false;
					}
					if( DroppedPawn[i] != None && bDetachedFromZipLine[i] == 0 )
						UpdateDropped( i, dt );
				}

				//If the zip lines are back up
				if( done )
				{
					bZipDone=True;
					log("zip lines are back up");
					GoToState( 'None' );
				}
			}
		}
	}
	

BEGIN:
	//log( "GETREADY" );
	bPreparingToDrop = true;

//	GettingReady();
//	sleep(1.46); //hardcoding the length of animation: is there a better way?
	
//	Hooking();
	sleep(0.8); //hardcoding the length of animation: is there a better way?		
	
	bPreparingToDrop = false;
	SetupDescent();
}


simulated function GettingReady()
{
	local int i;
	//Play the getting ready to hook animation
	for( i=0; i < 4; i++ )
	{
		//log( "yep" );
		//DroppedPawn[i].AnimBlendParams( 1, 1.0, 0.0, 0.5, DroppedPawn[i].RootBone );
		DroppedPawn[i].PlayAnim( GetReadyToHook, , 0.1, 1 );
	}
}


simulated function Hooking()
{
	local int i;
	//Then play the getting hooked animation
	for( i=0; i < 4; i++ )
		DroppedPawn[i].PlayAnim( HookingAnim, , 0.1, 1 );
}

	
simulated function SetupDescent()
{
	local int i;
	local VGSPAIController C;

	Velocity.X = 0;
	Velocity.Y = 0;
	bDroppingPawns = true;
	//log( "bDroppingPawns = true" );
	
	for( i=0; i < 4; i++ )
	{
		//Choose a speed
		ZipLineDropSpeed[i] = ZipLinesDropSpeed + ZipLineDropSpeedVariance*(2.0*FRand() - 1.0);
		
		//Animation for the descent
		DroppedPawn[i].LoopAnim( DescentAnim, , 0.0, 1 );
			
		//Make a controller for the pawn
		C = Spawn( class'SPAIPlasmaGun',,,, );
		C.Possess( DroppedPawn[i] );
		
//		DroppedPawn[i].SetLocation( Location + (ZipLineFallPoint[i] >> Rotation) );
		DroppedPawn[i].bCollideWorld = true;
		DroppedPawn[i].SetCollision( true, true, true );
	}
}


simulated function UpdateZipLine( int id, float dt )
{
	local vector scale;
	local float ZipLineSpeed;
	
	scale.X = 1.0;
	scale.Y = 1.0;
	
	//If the guy has hit the ground
	if( bHitGround[id] == 1 )
	{
		//If the guy is detached from the zip line
		if( bDetachedFromZipLine[id] == 1 )
		{
			ZipLineRiseTimer[id] += dt;
			ZipLineSpeed = ZipLineStartRiseSpeed + ZipLineRiseAcceleration * ZipLineRiseTimer[id];
			ZipLineHeight[id] = ZipLineMaxHeight[id] - (1.0/200.0) * ZipLineSpeed * ZipLineRiseTimer[id];
			
			//If the line has rolled back up
			if( ZipLineHeight[id] < 0 )
			{
				ZipLineHeight[id] = 0;
				bZipLineBackUp[id] = 1;
				ZipLine[id].Destroy();
			}
		}
		else
		{
			ZipLineHeight[id] = ZipLineMaxHeight[id];
		}
	}
	//If the dropper is still going down
	else
	{
		ZipLineHeight[id] = (1.0/200.0) * (ZipLine[id].Location.Z - DroppedPawn[id].Location.Z);
		//ZipLineHeight[id] = (1.0/200.0) * ZipLineDropSpeed[id] * DroppingTimer;
	}
 
	scale.Z = ZipLineHeight[id];
	ZipLine[id].SetDrawScale3D( scale );
}


simulated function UpdateDropped( int id, float dt )
{
	//If the guy hit the ground wait before letting the rope back up
	//change: get Dennis to make the animation send a notification instead
	if( bHitGround[id] == 1 )
	{
		UnhookingTimer[id] += dt;
		if( bDetachedFromZipLine[id] == 0 && (UnhookingTimer[id] > UnhookingTime) )
		{
			bDetachedFromZipLine[id] = 1;
			DroppedPawn[id].Controller.ClientSwitchToBestWeapon();
			StageToJoin.JoinStage( VGSPAIController(DroppedPawn[id].Controller) );
		}
	}
	else
	{
		//To detect if the pawn went through the terrain, if this time the distance to it
		//is bigger, it must have gone through			
		if( DroppedPawn[id].bDetached )
		{
			ZipLine[id].SetSkin(0,ZipLineNoiseTexture); //watch out
			bHitGround[id] = 1;
			ZipLineMaxHeight[id] = ZipLineHeight[id];
		}
		else
		{
			//DrawDebugLine( Location + (ZipLineFallPoint[id] >> Rotation), Location + (ZipLineFallPoint[id] >> Rotation) + 1500*vect(0,0,-1), 0, 255, 0 );
			DroppedPawn[id].SetLocation( Location + (ZipLineFallPoint[id] >> Rotation) - vect(0,0,1)*ZipLineDropSpeed[id]*DroppingTimer );
		}
	}
}

defaultproperties
{
     ZipLinesDropSpeed=600
     ZipLineDropSpeedVariance=300
     ZipLineStartRiseSpeed=300
     ZipLineRiseAcceleration=50
     UnhookingTime=3.000000
     AltMesh=StaticMesh'JamesPrefabs.Chapter12.DropTurBase'
     ZipLineMesh=StaticMesh'PariahDropShipMeshes.SmallDropShip.zip_line01'
     ZipLineNoiseTexture=NoiseVertexModifier'MannyTextures.vertex_shaders.zip_linemove1'
     StageToJoinName="Car1"
     GetReadyToHook="GRToJump"
     HookingAnim="JumpOnLine"
     DescentAnim="IdleOnLIne"
     TurretRelativePosition=(X=-220.000000,Z=-490.000000)
     ShipBlowupSound=Sound'PariahDropShipSounds.Millitary.DropshipExplosionA'
     OnDeathEvent="DropShipDead"
     Emitters(0)=(AttachPoint="PEmitter01",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     Emitters(1)=(AttachPoint="PEmitter02",EmitterClass=Class'VehicleEffects.shipthruster_flame')
     Emitters(2)=(AttachPoint="ThrusterFrontLeft",EmitterClass=Class'VehicleEffects.shipthruster_Side')
     Emitters(3)=(AttachPoint="ThrusterFrontRight",EmitterClass=Class'VehicleEffects.shipthruster_Side')
     CullDistance=20000.000000
     Begin Object Class=HavokParams Name=HavokParams37
         Mass=40.000000
         LinearDamping=0.300000
         AngularDamping=0.300000
         StartEnabled=True
         Restitution=1.000000
         ImpactThreshold=100000.000000
     End Object
     HParams=HavokParams'PariahSPPawns.HavokParams37'
     EventBindings(0)=(EventName="DoDrop",HandledBy="DropGuys")
     bHasHandlers=True
}
