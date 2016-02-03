//=============================================================================
// JumpSpot.
// specifies positions that can be reached with greater than normal jump
// forced paths will check for greater than normal jump capability
//=============================================================================
class JumpSpot extends JumpDest
	placeable;

var() bool bOnlyTranslocator;
var   bool bRealOnlyTranslocator;
var() bool bNeverImpactJump;
var() name TranslocTargetTag;			// target to transloc toward
var() float TranslocZOffset;
var Actor TranslocTarget;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	bRealOnlyTranslocator = bOnlyTranslocator; // used for JumpSpot testing
}

function bool CanMakeJump(Pawn Other, Float JumpHeight, Float GroundSpeed, Int Num, Actor Start)
{
	local vector V,S;
	
	if ( PhysicsVolume.Gravity.Z == PhysicsVolume.Default.Gravity.Z )
		return ( NeededJump[Num].Z < JumpHeight );
	S = Start.Location;
	S.Z = S.Z - Start.CollisionHeight + Other.CollisionHeight;
	V = SuggestFallVelocity(Location, S, 2*JumpHeight, GroundSpeed);
	//log(self$" jumpZ "$JumpHeight$" groundSpeed "$groundspeed$" suggested Z "$V.Z$" from "$Start);
	return ( V.Z < JumpHeight );	
}	
function bool CanDoubleJump(Pawn Other)
{
	return ( Other.bCanDoubleJump || (PhysicsVolume.Gravity.Z > PhysicsVolume.Default.Gravity.Z) );
}
		
event int SpecialCost(Pawn Other, ReachSpec Path)
{
	local int Num;
	local vector DodgeV;
	local float AllowedJumpZ;
	
	if ( Other.Controller.bAllowedToTranslocate )
		return 200;
	if ( bOnlyTranslocator )
		return 10000000;
			
	Num = GetPathIndex(Path);
	
	if ( CanDoubleJump(Other) )
		AllowedJumpZ = 1.5 * Other.JumpZ;
	else
		AllowedJumpZ = Other.JumpZ;
		
	if ( CanMakeJump(Other,AllowedJumpZ,Other.GroundSpeed,Num,Path.Start) ) 
		return 100;

	if ( (Path.Distance > 1000)
		&& (PhysicsVolume.Gravity.Z > PhysicsVolume.Default.Gravity.Z)
		&& (UnrealPawn(Other) != None) )
	{
		DodgeV = UnrealPawn(Other).BotDodge(vect(1,0,0));
		
		if ( CanMakeJump(Other,DodgeV.Z + Other.JumpZ,DodgeV.X,Num,Path.Start) )
			return 100;
	}
	if ( !bNeverImpactJump && (NeededJump[Num].Z <= 1100) && Other.Controller.bAllowedToImpactJump )
		return 3500;

	return 10000000;
}

event bool SuggestMovePreparation(Pawn Other)
{
	local int Num;
	local bot B;
	local float RealJumpZ, RealGroundSpeed;
	local vector DodgeV;
	
	if ( Other.Controller == None )
		return false;

	Num = GetPathIndex(Other.Controller.CurrentPath);
	// try translocator if landing would hurt
	if ( (Other.MaxFallSpeed < Other.Controller.CurrentPath.MaxLandingVelocity) && TryTranslocator(Other) )
		return true;
	
	if ( !bOnlyTranslocator && CanMakeJump(Other,Other.JumpZ,Other.GroundSpeed,Num,Other.Controller.CurrentPath.Start) )
	{
		//log("regular jump");
		DoJump(Other);
		return false;
	}

	B = Bot(Other.Controller);
	if ( B == None )
		return false;

	if ( bOnlyTranslocator )
		return TryTranslocator(Other);
		
	if ( (Other.Controller.CurrentPath.Distance > 1000)
		&& (PhysicsVolume.Gravity.Z > PhysicsVolume.Default.Gravity.Z)
		&& (UnrealPawn(Other) != None) )
	{
		//log("TRY DODGE JUMP");
		DodgeV = UnrealPawn(Other).BotDodge(vect(1,0,0));
		
		if ( CanMakeJump(Other,DodgeV.Z + 0.5 * Other.JumpZ,DodgeV.X,Num,Other.Controller.CurrentPath.Start) )
		{
			//log("dodge jump");
			RealJumpZ = Other.JumpZ;
			RealGroundSpeed = Other.GroundSpeed;
			Other.GroundSpeed = DodgeV.X;
			Other.JumpZ = DodgeV.Z + 0.5 * Other.JumpZ;
			UnrealPawn(Other).CurrentDir = DCLICK_Forward;
			DoJump(Other);
			Other.GroundSpeed = RealGroundSpeed;
			Other.JumpZ = RealJumpZ;
			Other.Velocity.Z = FMax(0.7*Other.JumpZ, Other.Velocity.Z - 0.5 * Other.JumpZ);
			B.bNotifyApex = true;
			B.bPendingDoubleJump = true;
			return false;
		}
	}
	
	if ( CanDoubleJump(Other) && CanMakeJump(Other,1.5*Other.JumpZ,Other.GroundSpeed,Num,Other.Controller.CurrentPath.Start) ) 
	{
		//log("double jump");
		RealJumpZ = Other.JumpZ;
		Other.JumpZ = 1.5*Other.JumpZ;
		DoJump(Other);
		Other.JumpZ = RealJumpZ;
		Other.Velocity.Z = FClamp(Other.Velocity.Z - 0.5 * Other.JumpZ,0.7*Other.JumpZ,Other.JumpZ);
		B.bNotifyApex = true;
		B.bPendingDoubleJump = true;
		return false;
	}

	if ( TryTranslocator(Other) )
		return true;

	if ( !bNeverImpactJump && (NeededJump[Num].Z < 1100) && B.CanImpactJump() )
	{
		Other.Acceleration = vect(0,0,0);
		B.bPreparingMove = true;
		B.ImpactTarget = self;
		B.Focus = None;
		B.FocalPoint = B.Location - vect(0,0,100);
		if ( Other.Weapon.IsA('ShieldGun') )
			B.ImpactJump();	
		else
			B.SwitchToBestWeapon();
		return true;
	}
	return false;
}

function bool TryTranslocator(Pawn Other)
{
	local bot B;
	
	B = Bot(Other.Controller);
	B.TranslocationTarget = None;
	B.RealTranslocationTarget = None;
	if ( B.CanUseTranslocator() )
	{
		Other.Acceleration = vect(0,0,0);
		B.bPreparingMove = true;
		B.TranslocationTarget = self;
		B.RealTranslocationTarget = self;
		if ( TranslocTargetTag != '' )
		{
			if ( TranslocTarget == None )
				ForEach AllActors(class'Actor',TranslocTarget,TranslocTargetTag)
					break;
			if ( TranslocTarget != None )
				B.TranslocationTarget = TranslocTarget;
		}
		B.ImpactTarget = self;
		B.Focus = self;
		if ( Other.Weapon.IsA('TransLauncher') )
		{
			Other.PendingWeapon = None;
			Other.Weapon.SetTimer(0.2,false);
		}
		else
			B.SwitchToBestWeapon();
		return true;
	}
	return false;
}

defaultproperties
{
}
