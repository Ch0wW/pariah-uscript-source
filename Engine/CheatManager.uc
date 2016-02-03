//=============================================================================
// CheatManager
// Object within playercontroller that manages "cheat" commands
// only spawned in single player mode
//=============================================================================

class CheatManager extends Object within PlayerController
	native
	transient;

var rotator LockedRotation;

/* Used for correlating game situation with log file
*/

exec function ReviewJumpSpots()
{
	Level.Game.ReviewJumpSpots();
}

exec function ListDynamicActors()
{
	local Actor A;
	local int i;
	
	ForEach DynamicActors(class'Actor',A)
	{
		i++;
		log(i@A);
	}
	log("Num dynamic actors: "$i);
}

exec function FreezeFrame(float delay)
{
	Level.Game.SetPause(true,outer);
	Level.PauseDelay = Level.TimeSeconds + delay;
}

exec function WriteToLog()
{
	log("NOW!");
}

exec function SetFlash(float F)
{
	FlashScale.X = F;
}

exec function SetFogR(float F)
{
	FlashFog.X = F;
}

exec function SetFogG(float F)
{
	FlashFog.Y = F;
}

exec function SetFogB(float F)
{
	FlashFog.Z = F;
}

exec function KillViewedActor()
{
    if( Level.Netmode!=NM_Standalone )
		return;
	if ( ViewTarget != None )
	{
		if ( (Pawn(ViewTarget) != None) && (Pawn(ViewTarget).Controller != None) )
			Pawn(ViewTarget).Controller.Destroy();	
		ViewTarget.Destroy();
		SetViewTarget(None);
	}
}

/* LogScriptedSequences()
Toggles logging of scripted sequences on and off
*/
exec function LogScriptedSequences()
{
	local AIScript S;

	ForEach AllActors(class'AIScript',S)
		S.bLoggingEnabled = !S.bLoggingEnabled;
}

/* Teleport()
Teleport to surface player is looking at
*/
exec function Teleport()
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
    if( Level.Netmode!=NM_Standalone )
		return;

	HitActor = Trace(HitLocation, HitNormal, ViewTarget.Location + 10000 * vector(Rotation),ViewTarget.Location, true);
	if ( HitActor == None )
		HitLocation = ViewTarget.Location + 10000 * vector(Rotation);
	else
		HitLocation = HitLocation + ViewTarget.CollisionRadius * HitNormal;

	ViewTarget.SetLocation(HitLocation);
}

/* 
Scale the player's size to be F * default size
*/
exec function ChangeSize( float F )
{
    if( Level.Netmode!=NM_Standalone )
		return;
	if ( Pawn.SetCollisionSize(Pawn.Default.CollisionRadius * F,Pawn.Default.CollisionHeight * F) )
	{
		Pawn.SetDrawScale(F);
		Pawn.SetLocation(Pawn.Location);
	}
}

exec function LockCamera()
{
	local vector LockedLocation;
	local rotator LockedRot;
	local actor LockedActor;
    if( Level.Netmode!=NM_Standalone )
		return;

	if ( !bCameraPositionLocked )
	{
		PlayerCalcView(LockedActor,LockedLocation,LockedRot);
		Outer.SetLocation(LockedLocation);
		LockedRotation = LockedRot;
		SetViewTarget(outer);
	}
	else
		SetViewTarget(Pawn);

	bCameraPositionLocked = !bCameraPositionLocked;
	bBehindView = bCameraPositionLocked;
	bFreeCamera = false;
}

exec function SetCameraDist( float F )
{
	CameraDist = FMax(F,2);
}

/* Stop interpolation
*/
exec function EndPath()
{
}

/* 
Camera and pawn aren't rotated together in behindview when bFreeCamera is true
*/
exec function FreeCamera( bool B )
{
	bFreeCamera = B;
	bBehindView = B;
}


exec function CauseEvent( name EventName )
{
	TriggerEvent( EventName, Pawn, Pawn);
}

exec function Amphibious()
{
    if( Level.Netmode!=NM_Standalone )
		return;
		
	Pawn.UnderwaterTime = +999999.0;
}
	
exec function Fly()
{
    if( Level.Netmode!=NM_Standalone )
		return;
		
	Pawn.UnderWaterTime = Pawn.Default.UnderWaterTime;	
	ClientMessage("You feel much lighter");
	Pawn.SetCollision(true, true , true);
	Pawn.bCollideWorld = true;
	bCheatFlying = true;
	Outer.GotoState('PlayerFlying');
}

exec function Walk()
{	
    if( Level.Netmode!=NM_Standalone )
		return;


	if ( Pawn != None )
	{
		bCheatFlying = false;
		Pawn.UnderWaterTime = Pawn.Default.UnderWaterTime;	
		Pawn.SetCollision(true, true , true);
		Pawn.SetPhysics(PHYS_Walking);
		Pawn.bCollideWorld = true;
		ClientReStart();
	}
}

exec function Ghost()
{
    if( Level.Netmode!=NM_Standalone )
		return;
		
	Pawn.UnderWaterTime = -1.0;	
	ClientMessage("You feel ethereal");
	Pawn.SetCollision(false, false, false);
	Pawn.bCollideWorld = false;
	bCheatFlying = true;
	Outer.GotoState('PlayerFlying');
}

exec function AllAmmo()
{		
	local Inventory Inv;
	
    if( Level.Netmode!=NM_Standalone )
		return;

	for( Inv=Pawn.Inventory; Inv!=None; Inv=Inv.Inventory ) 
		if (Ammunition(Inv)!=None) 
		{
			Ammunition(Inv).AmmoAmount  = 999;
			Ammunition(Inv).MaxAmmo  = 999;				
		}

}	

exec function Invisible(bool B)
{
    if( Level.Netmode!=NM_Standalone )
		return;

	Pawn.bHidden = B;

	if (B)
		Pawn.Visibility = 0;
	else
		Pawn.Visibility = Pawn.Default.Visibility;
}
	
exec function God()
{
    if( Level.Netmode!=NM_Standalone )
		return;

	if ( bGodMode )
	{
		bGodMode = false;
		ClientMessage("God mode off");
		return;
	}

	bGodMode = true; 
	ClientMessage("God Mode on");
}

exec function SloMo( float T )
{
    if( Level.Netmode!=NM_Standalone )
		return;
		
	Level.Game.SetGameSpeed(T);
	Level.Game.SaveConfig(); 
	Level.Game.GameReplicationInfo.SaveConfig();
}

exec function SetJumpZ( float F )
{
    if( Level.Netmode!=NM_Standalone )
		return;

	Pawn.JumpZ = F;
}

exec function SetGravity( float F )
{
    if( Level.Netmode!=NM_Standalone )
		return;
	PhysicsVolume.Gravity.Z = F;
}

exec function SetSpeed( float F )
{
    if( Level.Netmode!=NM_Standalone )
		return;
	Pawn.GroundSpeed = Pawn.Default.GroundSpeed * f;
	Pawn.WaterSpeed = Pawn.Default.WaterSpeed * f;
}

exec function KillAll(class<actor> aClass)
{
	local Actor A;
    if( Level.Netmode!=NM_Standalone )
		return;

	if ( ClassIsChildOf(aClass, class'Pawn') )
	{
		KillAllPawns(class<Pawn>(aClass));
		return;
	}
	ForEach DynamicActors(class 'Actor', A)
		if ( ClassIsChildOf(A.class, aClass) )
			A.Destroy();
}

// Kill non-player pawns and their controllers
function KillAllPawns(class<Pawn> aClass)
{
	local Pawn P;
    if( Level.Netmode!=NM_Standalone )
		return;
	
	ForEach DynamicActors(class'Pawn', P)
		if ( ClassIsChildOf(P.Class, aClass)
			&& !P.IsHumanControlled() )
		{
			if ( P.Controller != None )
				P.Controller.Destroy();
			P.Destroy();
		}
}

exec function KillPawns()
{
    if( Level.Netmode!=NM_Standalone )
		return;
	KillAllPawns(class'Pawn');
}

/* Avatar()
Possess a pawn of the requested class
*/
exec function Avatar( string ClassName )
{
	local class<actor> NewClass;
	local Pawn P;
		
    if( Level.Netmode!=NM_Standalone )
		return;
	if ( ClassName != "" )
		NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
	{
		Foreach DynamicActors(class'Pawn',P)
		{
			if ( (P.Class == NewClass) && (P != Pawn) )
			{
				if ( Pawn.Controller != None )
					Pawn.Controller.PawnDied(Pawn);
				Possess(P);
				break;
			}
		}
	}
}

exec function Summon( string ClassName )
{
	local class<actor> NewClass;
	local vector SpawnLoc;

    if( Level.Netmode!=NM_Standalone )
		return;
	log( "Fabricate " $ ClassName );
	if ( ClassName != "" )
		NewClass = class<actor>( DynamicLoadObject( ClassName, class'Class' ) );
	if( NewClass!=None )
	{
		if ( Pawn != None )
			SpawnLoc = Pawn.Location;
		else
			SpawnLoc = Location;
		Spawn( NewClass,,,SpawnLoc + 72 * Vector(Rotation) + vect(0,0,1) * 15 );
	}
}

exec function PlayersOnly()
{
	Level.bPlayersOnly = !Level.bPlayersOnly;
}

exec function CheatView( class<actor> aClass, optional bool bQuiet )
{
    if( Level.Netmode!=NM_Standalone )
		return;
	ViewClass(aClass,bQuiet, true);
}

// ***********************************************************
// Navigation Aids (for testing)

// remember spot for path testing (display path using ShowDebug)
exec function RememberSpot()
{
	if ( Pawn != None )
		Destination = Pawn.Location;
	else
		Destination = Location;
}

// ***********************************************************
// Changing viewtarget

exec function ViewSelf(optional bool bQuiet)
{
	bBehindView = false;
	bViewBot = false;
	if ( Pawn != None )
		SetViewTarget(Pawn);
	else
		SetViewtarget(outer);
	if (!bQuiet )
		ClientMessage(OwnCamera, 'Event');
	FixFOV();
}

exec function ViewPlayer( string S )
{
	local Controller P;
    if( Level.Netmode!=NM_Standalone )
		return;

	for ( P=Level.ControllerList; P!=None; P= P.NextController )
		if ( P.bIsPlayer && (P.PlayerReplicationInfo.RetrivePlayerName() ~= S) )
			break;

	if ( P.Pawn != None )
	{
		ClientMessage(ViewingFrom@P.PlayerReplicationInfo.RetrivePlayerName(), 'Event');
		SetViewTarget(P.Pawn);
	}

	bBehindView = ( ViewTarget != Pawn );
	if ( bBehindView )
		ViewTarget.BecomeViewTarget();
}

exec function ViewActor( name ActorName)
{
	local Actor A;

	if( Level.Netmode!=NM_Standalone )
		return;

	ForEach AllActors(class'Actor', A)
		if ( A.Name == ActorName )
		{
			SetViewTarget(A);
			bBehindView = true;
			return;
		}
}

exec function ViewFlag()
{
	local Controller C;
    if( Level.Netmode!=NM_Standalone )
		return;

	For ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('AIController') && (C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo.HasFlag != None) )
		{
			SetViewTarget(C.Pawn);
			return;
		}
}
		
exec function ViewBot()
{
	local actor first;
	local bool bFound;
	local Controller C;

    if( Level.Netmode!=NM_Standalone )
		return;

	bViewBot = true;
	For ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('AIController') && (C.Pawn != None) )
	{
		if ( bFound || (first == None) )
		{
			first = C.Pawn;
			if ( bFound )
				break;
		}
		if ( C.Pawn == ViewTarget ) 
			bFound = true;
	}  

	if ( first != None )
	{
		SetViewTarget(first);
		bBehindView = true;
		ViewTarget.BecomeViewTarget();
		FixFOV();
	}
	else
		ViewSelf(true);
}

exec function ViewClass( class<actor> aClass, optional bool bQuiet, optional bool bCheat )
{
	local actor Other, first;
	local bool bFound;
	
	if( Level.NetMode == NM_StandAlone )
	{
	    return;
	}

	if ( !bCheat && (Level.Game != None) && !Level.Game.bCanViewOthers )
		return;

	first = None;

	ForEach AllActors( aClass, Other )
	{
		if ( bFound || (first == None) )
		{
			first = Other;
			if ( bFound )
				break;
		}
		if ( Other == ViewTarget ) 
			bFound = true;
	}  

	if ( first != None )
	{
		if ( !bQuiet )
		{
			if ( Pawn(first) != None )
				ClientMessage(ViewingFrom@First.RetrivePlayerName(), 'Event');
			else
				ClientMessage(ViewingFrom@first, 'Event');
		}
		SetViewTarget(first);
		bBehindView = ( ViewTarget != outer );

		if ( bBehindView )
			ViewTarget.BecomeViewTarget();

		FixFOV();
	}
	else
		ViewSelf(bQuiet);
}

exec function Loaded()
{
	if( Level.Netmode!=NM_Standalone )
		return;

    AllWeapons();
    AllAmmo();
}

// amb ---
exec function AllWeapons() 
{
	if( Level.Netmode!=NM_Standalone )
		return;
}
// --- amb

// enables unlimited ammo
exec function Unlimitedammo()
{
	//Pawn.AmmoAmount = 999;
	//Pawn.MaxAmmoAmount = 999;
}

exec function UnlockChapters()
{
    local GameProfile gProfile;
    gProfile = GetCurrentGameProfile();
    if(gProfile != None)
    {
        gProfile.UnlockChapters();
    }
}

defaultproperties
{
}
