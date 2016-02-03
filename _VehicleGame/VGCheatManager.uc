class VGCheatManager extends CheatManager;

/*
	Test titan charging fx (msp)
*/
exec function warp( int state )
{
	local PlayerController PC;
	local WarpPostFXStage Warp;
	local float EffectScreenX;
	local float EffectScreenY;
	local int	AbsorptionRippleness;
	local int	AbsorptionSpeed;
	local float AbsorptionScreenScale;
	local float AborbingRippleMaxAmplitude;
	local float CompressedWavesScreenScale;
	local PostFXStage WarpPostFX;
	
	if( Level.Netmode!=NM_Standalone )
  		return;

	PC = Level.GetLocalPlayerController();

	if( state == 0 )
	{
		WarpPostFX = PC.FindPostFXStage( class'WarpPostFXStage' );
		PC.RemovePostFXStage( WarpPostFX );
		return;
	}
	
	Warp = new(Level) class'WarpPostFXStage';
	
	CompressedWavesScreenScale=0.8;
	AborbingRippleMaxAmplitude=0.008;
	AbsorptionRippleness=35;
	AbsorptionSpeed=20;
	AbsorptionScreenScale=0.7;
	
	EffectScreenX=0.3;
	EffectScreenY=-0.25;
	
	Warp.ScreenPosX = EffectScreenX;
	Warp.ScreenPosY = EffectScreenY;
	Warp.RippleAmplitude = AborbingRippleMaxAmplitude;
	Warp.Rippleness = AbsorptionRippleness;
	Warp.RippleSpeed = AbsorptionSpeed; 
	Warp.WarpType = 1;
	Warp.RippleType = 4;
	Warp.bRestart = true;
	Warp.RippleScreenScale = AbsorptionScreenScale;

	PC.AddPostFXStage( Warp );
}


/*
	To test the vision shader (msp)
*/
exec function vision( int state )
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	bEnhancedVisionIsOn = bool(state);
}


/*
	To test the sniper gun with enhanced vision on (msp)
*/
exec function sniper()
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	Pawn.GiveWeapon("VehicleWeapons.SniperRifle");
	Unlimitedammo();
	//AddWECLevel();
	God();
}


/*
	To test the titan gun (msp)
*/
exec function titan()
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	Pawn.GiveWeapon("VehicleWeapons.TitansFist");
	Unlimitedammo();
	God();
}


/*
	To test the grenade launcher gun (msp)
*/
exec function grenade()
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	Pawn.GiveWeapon("VehicleWeapons.GrenadeLauncher");
	Unlimitedammo();
	God();
}

//----------------------------------------------------------------------------

exec function showRelations()
{
	local int j;
	local ReachSpec R;
	
	if( Level.Netmode!=NM_Standalone )
  		return;

	for(j=0; j<Level.PathObstacles.Length; j++)
	{
		R = Level.PathObstacles[j].path;

		log("Relation:"@Level.PathObstacles[j].obstacle@R.Start@R.End);

	}
}

exec function testVal(float val)
{
	local Controller C, LC;
	
	if( Level.Netmode!=NM_Standalone )
  		return;

	LC = Level.GetLocalPlayerController();
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('DriveController'))
		{
			CarBot(C).testVal = val;
		}
	}
}

exec function StopBots()
{
	local Controller C, LC;
	
	if( Level.Netmode!=NM_Standalone )
  		return;

	LC = Level.GetLocalPlayerController();
	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('DriveController') && (!LC.SameTeamAs(C)))
		{
			C.Pawn.GroundSpeed = 0; 
		}
	}
}

exec function Wimp()
{
	local Controller C;
	
	if( Level.Netmode!=NM_Standalone )
  		return;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('DriveController') && (C.Pawn != None) )
		{
			CarBot(C).bWimp = true; 
		}
	}
}

exec function NotWimp()
{
	local Controller C;
	
	if( Level.Netmode!=NM_Standalone )
  		return;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('DriveController') && (C.Pawn != None) )
		{
			CarBot(C).bWimp = false;
			CarBot(C).TimedFireWeaponAtEnemy();
		}
	}
}

exec function Dumb()
{
	local Controller C;
	
	if( Level.Netmode!=NM_Standalone )
  		return;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('DriveController') && (C.Pawn != None) )
		{
			C.GotoState('Dumb');
		}
	}
}

exec function Smrt()
{
	local Controller C;
	
	if( Level.Netmode!=NM_Standalone )
  		return;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( C.IsA('DriveController') && (C.Pawn != None) )
		{
			DriveController(C).WhatToDoNext(0);
		}
	}
}
		
exec function ViewSelf(optional bool bQuiet)
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	bBehindView = false;
	bViewBot = false;
	if ( Pawn != None )
		SetViewTarget(Pawn);
	else
		SetViewtarget(outer);
	if (!bQuiet )
		ClientMessage(OwnCamera, 'Event');
	FixFOV();
	
	if(myHUD.bShowDebugInfo)
		myHUD.bShowDebugInfo = false;
	if( VehiclePlayer(outer) != None )
			VehiclePlayer(outer).bNoCam = false;
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
		//mh
		if( !myHUD.bShowDebugInfo )
			myHUD.bShowDebugInfo = true;
		if( VehiclePlayer(outer) != None )
		{
			//incar
			if(VGVehicle(outer.Pawn) != None)
			{
				if( VGVehicle(ViewTarget) != None)
					VehiclePlayer(outer).bNoCam = false;
				else
					VehiclePlayer(outer).bNoCam = true;
			}

		}

		//mh
	}
	else
		ViewSelf(true);
}

function fAllAmmo(Pawn p)
{
	local Inventory Inv;
	
	if( Level.Netmode!=NM_Standalone )
  		return;

	for( Inv=p.Inventory; Inv!=None; Inv=Inv.Inventory ) 
		if (Ammunition(Inv)!=None) 
		{
			Ammunition(Inv).AmmoAmount  = 999;
			Ammunition(Inv).MaxAmmo  = 999;				
		}
}

exec function BL()
{
	local Controller C;
	
	if( Level.Netmode!=NM_Standalone )
  		return;

	For ( C=Level.ControllerList; C!=None; C=C.NextController )
		if ( C.IsA('AIController') && (C.Pawn != None) )
	{
			if( C.Pawn.IsA('VGVehicle') )
			{
				//C.Pawn.GiveWeapon("VehicleWeapons.Machinegun");
				C.Pawn.GiveWeapon("VehicleWeapons.PlasmaGun");
			}
			fAllAmmo(C.Pawn);
	}
}

//XJ making life easier for myself!
exec function VehicleWeapons()
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	if( Pawn.IsA('VGVehicle') )
	{	
		Pawn.GiveWeapon("VehicleWeapons.Puncher");
		Pawn.GiveWeapon("VehicleWeapons.Haser");
		Pawn.GiveWeapon("VehicleWeapons.SwarmLauncher");
	}
}

exec function Everything()
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	Loaded();
	Unlimitedammo();
	God();
}


exec function Loaded()
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	if( !Pawn.IsA('VGVehicle') )
	{
		Pawn.GiveWeapon("VehicleWeapons.HealingTool");
		Pawn.GiveWeapon("VehicleWeapons.VGAssaultRifle");
		Pawn.GiveWeapon("VehicleWeapons.FragRifle");
		Pawn.GiveWeapon("VehicleWeapons.VGRocketLauncher");
		Pawn.GiveWeapon("VehicleWeapons.PlayerPlasmaGun");
		Pawn.GiveWeapon("VehicleWeapons.GrenadeLauncher");
		Pawn.GiveWeapon("VehicleWeapons.SniperRifle");
		if(PlayerController(Pawn.Controller) != none && PlayerController(Pawn.Controller).bAllowTitans)
			Pawn.GiveWeapon("VehicleWeapons.PlayerTitansFist");
		Pawn.GiveWeapon("VehicleWeapons.BoneSaw");
        VehiclePlayer(outer).WECCount = 50;
	}
	else
	{
		VehicleWeapons();
	}
}

exec function DestroyWeapon()
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	// destroy the current weapon (if any)
	if(Pawn != none && Pawn.IsA('VGPawn') && Pawn.Weapon != none)
		Pawn.Weapon.RemoveFrom();

	Pawn.Controller.ClientSwitchToBestWeapon();
	Pawn.CheckCurrentWeapon();
}

exec function AddWECLevel()
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	if(Pawn.IsA('VGPawn') && Pawn.Weapon.IsA('VGWeapon'))
		VGWeapon(Pawn.Weapon).WECLevelUp();
}

exec function SetWECLevel(int weclevel)
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	if(Pawn.IsA('VGPawn') && Pawn.Weapon.IsA('VGWeapon'))
		VGWeapon(Pawn.Weapon).SetWECLevel(weclevel);
}

exec function NoOverheat()
{
	if( Level.Netmode!=NM_Standalone )
  		return;

	Pawn.bNoOverheat = true;
}

defaultproperties
{
}
