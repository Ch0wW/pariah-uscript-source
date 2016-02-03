class UnrealPawn extends Pawn
	native
	abstract;

var	() bool		bNoDefaultInventory;	// don't spawn default inventory for this guy
var bool		bAcceptAllInventory;	// can pick up anything
var(AI) bool	bIsSquadLeader;			// only used as startup property
var bool		bSoakDebug;				// use less verbose version of debug display
var byte		LoadOut;		

var config byte SelectedEquipment[16];	// what player has selected (replicate using function)
var()	string	RequiredEquipment[16];	// allow L.D. to modify for single player
var		string	OptionalEquipment[16];	// player can optionally incorporate into loadout

var		float	AttackSuitability;		// range 0 to 1, 0 = pure defender, 1 = pure attacker

var eDoubleClickDir CurrentDir;
var name			GameObjBone;
var vector			GameObjOffset;
var rotator			GameObjRot;
var(AI) name		SquadName;			// only used as startup property

// allowed voices
var string VoiceType;

var config bool bPlayerShadows;
var config bool bRagdollCorpses; // gam

/* DisplayDebug()
list important actor variable on canvas.  Also show the pawn's controller and weapon info
*/
simulated function DisplayDebug(Canvas Canvas, out float YL, out float YPos)
{
	local string T;
	local float XL;

	if ( !bSoakDebug )
	{
		Super.DisplayDebug(Canvas, YL, YPos);
		return;
	}

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.StrLen("TEST", XL, YL);
	YPos = YPos + 8*YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(255,255,0);
	T = GetDebugName();
	if ( bDeleteMe==1 )
		T = T$" DELETED (bDeleteMe == true)";
	Canvas.DrawText(T);
	YPos += 3 * YL;
	Canvas.SetPos(4,YPos);

	if ( Controller == None )
	{
		Canvas.SetDrawColor(255,0,0);
		Canvas.DrawText("NO CONTROLLER");
		YPos += YL;
		Canvas.SetPos(4,YPos);
	}
	else
		Controller.DisplayDebug(Canvas,YL,YPos);

	YPos += 2*YL;
	Canvas.SetPos(4,YPos);
	Canvas.SetDrawColor(0,255,255);
	Canvas.DrawText("Anchor "$Anchor$" Serpentine Dist "$SerpentineDist$" Time "$SerpentineTime);
	YPos += YL;
	Canvas.SetPos(4,YPos);

	T = "Floor "$Floor$" DesiredSpeed "$DesiredSpeed$" Crouched "$bIsCrouched$" Try to uncrouch "$UncrouchTime;
	if ( (OnLadder != None) || (Physics == PHYS_Ladder) )
		T=T$" on ladder "$OnLadder;
	Canvas.DrawText(T);
	YPos += YL;
	Canvas.SetPos(4,YPos);
}

/* BotDodge()
returns appropriate vector for dodge in direction Dir (which should be normalized)
*/
function vector BotDodge(Vector Dir)
{
	local vector Vel;
	
	Vel = GroundSpeed*Dir;
	Vel.Z = JumpZ;
	return Vel;
}

function HoldGameObject(Decoration gameObj)
{
	AttachToBone(gameObj,GameObjBone);
	gameObj.SetRelativeRotation(GameObjRot);
	gameObj.SetRelativeLocation(GameObjOffset);
}

function EndJump();	// Called when stop jumping

simulated function ShouldUnCrouch();	

simulated event SetAnimAction(name NewAction)
{
	AnimAction = NewAction;
	PlayAnim(AnimAction);
}

function String GetDebugName()
{
	if ( (Bot(Controller) != None) && Bot(Controller).bSoaking && (Level.Pauser != None) )
		return RetrivePlayerName()@Bot(Controller).SoakString;
	if ( PlayerReplicationInfo != None )
		return PlayerReplicationInfo.RetrivePlayerName();
	return GetItemName(string(self));
}

function LogOut();	
function FootStepping(int side);

function name GetWeaponBoneFor(Inventory I)
{
	return 'weapon_bone';
}

function CheckBob(float DeltaTime, vector Y)
{
	local float OldBobTime;
	local int m,n;

	OldBobTime = BobTime;
	Super.CheckBob(DeltaTime,Y);
	
	if ( (Physics != PHYS_Walking) || (VSize(Velocity) < 10)
		|| ((PlayerController(Controller) != None) && PlayerController(Controller).bBehindView) )
		return;
	
	m = int(0.5 * Pi + 9.0 * OldBobTime/Pi);
	n = int(0.5 * Pi + 9.0 * BobTime/Pi);

	if ( (m != n) && !bIsWalking && !bIsCrouched )
		FootStepping(0);
}

/* IsInLoadout()
return true if InventoryClass is part of required or optional equipment
*/
function bool IsInLoadout(class<Inventory> InventoryClass)
{
	local int i;
	local string invstring;

	if ( bAcceptAllInventory )
		return true;
		
	invstring = string(InventoryClass);

	for ( i=0; i<16; i++ )
	{
		if ( RequiredEquipment[i] ~= invstring )
			return true;
		else if ( RequiredEquipment[i] == "" )
			break;
	}

	for ( i=0; i<16; i++ )
	{
		if ( OptionalEquipment[i] ~= invstring )
			return true;
		else if ( OptionalEquipment[i] == "" )
			break;
	}
	return false;
}

function AddDefaultInventory()
{
	local int i;

	if ( IsLocallyControlled() )
	{
		for ( i=0; i<16; i++ )
			if ( RequiredEquipment[i] != "" )
				CreateInventory(RequiredEquipment[i]);

		for ( i=0; i<16; i++ )
			if ( (SelectedEquipment[i] == 1) && (OptionalEquipment[i] != "") )
				CreateInventory(OptionalEquipment[i]);

	    Level.Game.AddGameSpecificInventory(self);
	}
	else
	{
	    Level.Game.AddGameSpecificInventory(self);

		for ( i=15; i>=0; i-- )
			if ( (SelectedEquipment[i] == 1) && (OptionalEquipment[i] != "") )
				CreateInventory(OptionalEquipment[i]);

		for ( i=15; i>=0; i-- )
			if ( RequiredEquipment[i] != "" )
				CreateInventory(RequiredEquipment[i]);
	}

	// HACK FIXME
	if ( inventory != None )
		inventory.OwnerEvent('LoadOut');

    if( Controller != None )
    {
	    Controller.ClientSwitchToBestWeapon();
	}
}

function CreateInventory(string InventoryClassName)
{
	local Inventory Inv;
	local class<Inventory> InventoryClass;

	InventoryClass = Level.Game.BaseMutator.GetInventoryClass(InventoryClassName);
	if( (InventoryClass!=None) && (FindInventoryType(InventoryClass)==None) )
	{
		Inv = Spawn(InventoryClass);
		if( Inv != None )
		{
			Inv.GiveTo(self);
			Inv.PickupFunction(self);
		}
	}
}

function bool Dodge(eDoubleClickDir DoubleClickMove)
{
	local vector X,Y,Z;

	if ( bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking) )
		return false;

    GetAxes(Rotation,X,Y,Z);
	if (DoubleClickMove == DCLICK_Forward)
		Velocity = 1.5*GroundSpeed*X + (Velocity Dot Y)*Y;
	else if (DoubleClickMove == DCLICK_Back)
		Velocity = -1.5*GroundSpeed*X + (Velocity Dot Y)*Y; 
	else if (DoubleClickMove == DCLICK_Left)
	{
		Velocity = -1.5*GroundSpeed*Y + (Velocity Dot X)*X; 
	}
	else if (DoubleClickMove == DCLICK_Right)
	{
		Velocity = 1.5*GroundSpeed*Y + (Velocity Dot X)*X; 
	}

	Velocity.Z = 350;
	CurrentDir = DoubleClickMove;
	SetPhysics(PHYS_Falling);
	return true;
}

simulated function PostBeginPlay()
{
	local SquadAI S;

	Super.PostBeginPlay();
//	if ( Level.NetMode != NM_DedicatedServer )
//		Shadow = Spawn(class'PlayerShadow',self);
	if ( Level.bStartup && !bNoDefaultInventory )
		AddDefaultInventory();
	if ( Level.bStartup )
	{
		if ( UnrealMPGameInfo(Level.Game) == None )
		{
			if ( Bot(Controller) != None )
			{
			ForEach DynamicActors(class'SquadAI',S,SquadName)
				break;
			if ( S == None )
				S = spawn(class'SquadAI');
			S.Tag = SquadName;
			if ( bIsSquadLeader || (S.SquadLeader == None) )
				S.SetLeader(Controller);
			S.AddBot(Bot(Controller));
		}
		}
		else
			UnrealMPGameInfo(Level.Game).InitPlacedBot(Bot(Controller));
	}
}

function SetMovementPhysics()
{
	if ( Physics == PHYS_Falling || Physics == PHYS_Havok || Physics == PHYS_HavokSkeleton )
		return;
	if ( PhysicsVolume.bWaterVolume )
		SetPhysics(PHYS_Swimming);
	else
		SetPhysics(PHYS_Walking); 
}

function TakeDrowningDamage()	
{	
	TakeDamage(5, None, Location + CollisionHeight * vect(0,0,0.5)+ 0.7 * CollisionRadius * vector(Controller.Rotation), vect(0,0,0), class'Drowned'); 
}

//-----------------------------------------------------------------------------

/* 
Pawn was killed - detach any controller, and die
*/
simulated function ChunkUp( Rotator HitRotation, float ChunkPerterbation, optional Controller Killer, optional vector HitLocation ) // gam
{
	if ( (Level.NetMode != NM_Client) && (Controller != None) )
	{
		if ( Controller.bIsPlayer )
			Controller.PawnDied(self);
		else
			Controller.Destroy();
	}

	bTearOff = true;
	HitDamageType = class'Gibbed'; // make sure clients gib also
	if ( (Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer) )
		GotoState('TimingOut');
	if ( Level.NetMode == NM_DedicatedServer ) 
		return;
	if ( class'GameInfo'.Default.GoreLevel > 0 )
	{
		Destroy();
		return;
	}
	SpawnGibs(HitRotation,ChunkPerterbation,Killer.Pawn,HitLocation);

	if ( Level.NetMode != NM_ListenServer )
		Destroy();
}

// spawn gibs (local, not replicated)
simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation, optional Pawn Killer, optional vector HitLocation);

event bool EncroachingOn( actor Other )
{
    // sjs - don't encroach team mates, still broken?
    if ( Level != None && Level.Game != None && Level.Game.bTeamGame && (Pawn(Other) != None)
		&& (Pawn(Other).PlayerReplicationInfo != None)
		&& (Pawn(Other).PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
	{
		if ( (Role == ROLE_Authority) && Level.Game.bWaitingToStartMatch )
			return Super.EncroachingOn(Other);
		else
			return true;
	}
	return Super.EncroachingOn(Other);
}

/* TimingOut - where gibbed pawns go to die (delay so they can get replicated)
*/
State TimingOut
{
ignores BaseChange, Landed, AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
	}

	function BeginState()
	{
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
        bHidden = true;
		LifeSpan = 1.0;
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied(self);
			else
				Controller.Destroy();
		}
	}
}

State Dying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer;

	function Landed(vector HitNormal)
	{
		LandBob = FMin(50, 0.055 * Velocity.Z); 
		if ( Level.NetMode == NM_DedicatedServer )
			return;
		if ( Shadow != None )
			Shadow.Destroy();

		// FIXME
		//if ( UTBloodPool2(Shadow) == None )
		//	Shadow = Spawn(class'UTBloodPool2',,,Location, rotator(HitNormal));
	}

	singular function BaseChange()
	{
		Super.BaseChange();
		// fixme - wake up karma
	}

	function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation, 
							Vector momentum, class<DamageType> damageType, optional Controller ProjOwner, optional bool bSplashDamage)
	{
		if ( bInvulnerableBody )
			return;
		Damage *= DamageType.Default.GibModifier;
		Health -=Damage;
		if ( (Damage > 40) && (Health < -60) )
		{
        	ChunkUp( Rotation, DamageType.default.GibPerterbation ); // gam
			return;
		}
	}

	function BeginState()
	{
		if ( (LastStartSpot != None) && (Level.TimeSeconds - LastStartTime < 7) )
			LastStartSpot.LastSpawnCampTime = Level.TimeSeconds;
		SetCollision(true,false,false);
        if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(12.0, false);
        SetPhysics(PHYS_Falling);
		bInvulnerableBody = true;
		if ( Controller != None )
		{
			if ( Controller.bIsPlayer )
				Controller.PawnDied(self);
			else
				Controller.Destroy();
		}
	}
}

defaultproperties
{
     AttackSuitability=0.500000
     GameObjBone="FlagHand"
     SquadName="Squad"
     LoadOut=255
     bAcceptAllInventory=True
     SightRadius=12000.000000
     MeleeRange=20.000000
     GroundSpeed=600.000000
     AirSpeed=600.000000
     AirControl=0.350000
     WalkingPct=0.300000
     BaseEyeHeight=60.000000
     EyeHeight=60.000000
     CrouchHeight=39.000000
     UnderWaterTime=20.000000
     ControllerClass=Class'UnrealGame.Bot'
     bCanCrouch=True
     bCanSwim=True
     bCanClimbLadders=True
     bCanStrafe=True
     bCanPickupInventory=True
     bMuffledHearing=True
     LightBrightness=70.000000
     LightRadius=6.000000
     Buoyancy=99.000000
     ForceRadius=100.000000
     ForceScale=2.500000
     RotationRate=(Pitch=0,Roll=2048)
     LightHue=40
     LightSaturation=128
     AmbientGlow=17
     ForceType=FT_DragAlong
     bStasis=False
}
