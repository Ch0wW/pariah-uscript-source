class MiniEdInfo extends GameInfo
	exportstructs
	native;

const DAY_DEFAULT_BRIGHTNESS = 170;
const NIGHT_DEFAULT_BRIGHTNESS = 100;

var bool		bTryingMap;
var int			Transportation; //An index that tells which transportation was requested (onfoot,wasp,...)
var vector		SpawnLocation;
var vector		BirdEyeCameraLoc;	//Location of camera when entering editing mode
var rotator		BirdEyeCameraRot;	//Angle (yaw) of the camera when entering editing mode
var string		MenuEditorArgs;
var bool		bInitWasDone;		//Was MenuEditor->Init called already? Prevents to go over INT files again
var VGVehicle	TryMapVehicle;

//General information
var String					EditorModeType;
var bool					bSnapping;
var int						LayersNumVersions[3];
var int						HiddenVersions[9];
var int						NumVehiclesInMap;
var int						NumDynamicObjectsInMap;

//Information about the theme
var String					ThemeName;
var array<int>				MeshMemory;
var array<String>			MeshNames;
var array<String>			MeshThumbs;
var array<String>			MeshDesc;
var array<xUtil.MiniEdLayerSetRecord> LayerSetsRecords;

//Layers
var int						CurrentLayer[3]; //Which version is currently used for each layer set (starts at version 0)

var array<int>				SkiesIndices;
var array<xUtil.MiniEdSkyRecord> SkiesRecords;

//Information about the map
var xUtil.MiniEdMapRecord	MapRecord;

//Light
var bool					IsDay;
var color					LightRGBColors[3];

//Sound
var array<String>			SoundNames;
var array<String>			SoundFileNames;

//Usage
var int						FreeMemory;
var int						TotalFreeMemory;
var	int						NumActors;

var bool					EnoughMemoryForPlacing;
var int						MemoryForSelectedObject;
var int						eMemObjectType;
var int						UsageFromTryMode;
//var float					UsageRatio;

var int MemUsage[11];

//Menu data saved
var struct T_TerrainEditData
{
} TerrainData;

var struct T_FXBrowserData
{
	var int NearFogSliderValue;
	var int FarFogSliderValue;
	var int SelectedWeatherIndex;
	var int FogColorSliderPercentage;
	var int SelectedColorIndex;
} FXBrowserData;

var struct T_FXBrowserDataTwo
{
	var int SkyButtonSelected;
	var int SoundSelectedIndex;
} FXBrowserDataTwo;

var struct T_LightingData
{
	var int LightColorSelected;
	var int BrightnessSliderValue;
} LightingData;

var struct T_PhysicMenuData
{
} PhysicMenuData;
var bool bPhysicsMenuInitialized;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
native simulated function int GetFreeMemory(); //[bytes]

simulated function InfoStart()
{	//Usage is in bytes 
	//MemInfo[0].MemType=OT_Mesh;
	MemUsage[0]=0;
	//MemInfo[1].MemType=OT_Drone;			Doubled Static mesh memory.
	MemUsage[1]=100000;
	//MemInfo[2].MemType=OT_Mine;			Doubled Static mesh memory.
	MemUsage[2]=24000;
	//MemInfo[3].MemType=OT_Turret;			Memory from animation browser info tab.
	MemUsage[3]=750000;
	//MemInfo[4].MemType=OT_Barrel;			Doubled Static mesh memory
	MemUsage[4]=64000;
	//MemInfo[5].MemType=OT_AmmoStation;	Static Mesh
	MemUsage[5]=125000;
	//MemInfo[6].MemType=OT_Bogie;			Tripled (static mesh req + weap anim)
	MemUsage[6]=1179000;
	//MemInfo[7].MemType=OT_Dart;			
	MemUsage[7]=1074000;
	//MemInfo[8].MemType=OT_Dozer;			
	MemUsage[8]=1218000;
	//MemInfo[9].MemType=OT_Wasp;			
	MemUsage[9]=1236000;
	//MemInfo[10].MemType=OT_None;
	MemUsage[10]=0;
}


simulated event int GetNumVersions( int Layer )
{
	local string TexName1, TexName2, TexName3;
	local int num;
	
	TexName1 = GetLayerVersionTexName( Layer, 0 );
	TexName2 = GetLayerVersionTexName( Layer, 1 );
	TexName3 = GetLayerVersionTexName( Layer, 2 );
	
	if( (TexName1 == TexName2) && (TexName1 == TexName3) )
		num = 1;
	else if( (TexName1 != TexName2) && (TexName1 != TexName3) && (TexName2 != TexName3) )
		num = 3;
	else
		num = 2;

	return num;
}


simulated event String GetLayerTextureThumb( int Layer )
{
	return LayerSetsRecords[Layer].VersionsThumbs[CurrentLayer[Layer]];
}


simulated event String GetLayerTexture( int Layer )
{
	return LayerSetsRecords[Layer].Versions[CurrentLayer[Layer]];
}


simulated function String GetLayerVersionTexName( int Layer, int Version )
{
	return LayerSetsRecords[Layer].Versions[Version];
}


simulated function bool IsNextVersionDifferent( int curLayer )
{
	local int WantedVersionIndex;
	local string LayerTexture, WantedTexture;
	
	LayerTexture = GetLayerVersionTexName( curLayer, CurrentLayer[curLayer] );
	WantedVersionIndex = (CurrentLayer[curLayer] + 1)%3;
	WantedTexture = GetLayerVersionTexName( curLayer, WantedVersionIndex );

	if( LayerTexture == WantedTexture )
		return false;

	CurrentLayer[curLayer] = WantedVersionIndex;
	return true;
}


simulated event bool GetNextDifferentVersion( int curLayer )
{
	local int VersionIndex;
	local string LayerTexture, WantedTexture;
	local int i;
	
	LayerTexture = GetLayerVersionTexName( curLayer, CurrentLayer[curLayer] );

	for( i=1; i<3; i++ )
	{
		VersionIndex = (CurrentLayer[curLayer] + i)%3;
		WantedTexture = GetLayerVersionTexName( curLayer, VersionIndex );

		if( LayerTexture != WantedTexture )
		{
			CurrentLayer[curLayer] = VersionIndex;
			return true;
		}
	}
	return false;
}


simulated function SetToNextVersion( int Layer )
{
	CurrentLayer[Layer] = (++CurrentLayer[Layer])%3;
}


event int GetDayDefaultBrightness()
{
	return DAY_DEFAULT_BRIGHTNESS;
}


event int GetNightDefaultBrightness()
{
	return NIGHT_DEFAULT_BRIGHTNESS;
}


// Other classes extending GameInfo don't override Login 
// msp_todo: get rid of some stuff
//
event PlayerController Login
(
    string Portal,
    string Options,
    out string Error
)
{
	local PlayerController		NewPlayer;
    local NavigationPoint		StartSpot;
    local string				InName, InAdminName, InPassword;
    local bool					bAdmin;
    local bool					bInvited;
    
    //bSpectator = bool(ParseOption( Options, "SpectatorOnly" ));
	bAdmin = AccessControl.CheckOptionsAdmin(Options);

	// gam ---
    bInvited = bAdmin || bool(ParseOption( Options, "WasInvited" ) );
	
    BaseMutator.ModifyLogin(Portal, Options);

    // Get URL options.
	InName = Left(ParseOption(Options, "Name"), 20);

    // Find a start spot.
    StartSpot = FindPlayerStart( None );
    
    if( StartSpot == None )
    {
        Error = GameMessageClass.Default.FailedPlaceMessage;
        return None;
    }
    
    bTryingMap = bool(ParseOption( Options, "TryMap" ));
    Transportation = int(ParseOption( Options, "Transportation" ));
    
    //If the user pressed the "TryMap" button we login a VehicleController instead
    if( bTryingMap )
    {
		PlayerControllerClass = class<PlayerController>(DynamicLoadObject("VehicleGame.VehiclePlayer", class'Class'));
    
    	//This adds the created controller to the list of actors in the level
		NewPlayer = spawn( PlayerControllerClass, , , StartSpot.Location, StartSpot.Rotation );
		
		if( NewPlayer == None )
			log( "ERROR- Failed to spawn the VehiclePlayer" );
		assert( NewPlayer != None );
		
		//Save spawn location
		SpawnLocation = StartSpot.Location;
		
		//Set the pawn type
		NewPlayer.SetPawnClass("VehicleGame.VGPawn", "" );
		
		VehiclePlayer(NewPlayer).LoadPlayerWeapon( class<Weapon>(DynamicLoadObject("VehicleWeapons.VGAssaultRifle", class'Class')), 0 );	
		VehiclePlayer(NewPlayer).bLoadedOut = true;
		VehiclePlayer(NewPlayer).bMiniEdEditing = false;
		VehiclePlayer(NewPlayer).bUse3rdPersonCam = false;
    }
    //Otherwise we login a MiniEdController
    else
    {
		PlayerControllerClass = class<PlayerController>(DynamicLoadObject("MiniEd.MiniEdController", class'Class'));
		
		if( bMenuLevel )
			NewPlayer = spawn(PlayerControllerClass, , , StartSpot.Location, StartSpot.Rotation );
		else
		{
			log( "Spawning editing controller at " $ BirdEyeCameraLoc $ " with rotation " $ BirdEyeCameraRot );
			NewPlayer = spawn(PlayerControllerClass, , , BirdEyeCameraLoc, BirdEyeCameraRot );
		}

		//Set the pawn type
		NewPlayer.SetPawnClass( "MiniEd.MiniEdPawn", "" );
		NewPlayer.bMiniEdEditing = true;
	}

    // Handle spawn failure.
    if( NewPlayer == None )
    {
        log("Couldn't spawn player controller of class "$PlayerControllerClass);
        Error = GameMessageClass.Default.FailedSpawnMessage;
        return None;
    }
    
	// Init player's administrative privileges and log it
    if (AccessControl.AdminLogin(NewPlayer, InAdminName, InPassword))
    {
		AccessControl.AdminEntered(NewPlayer, InAdminName);
    } 

    NewPlayer.StartSpot = StartSpot;

    // Init player's replication info
    NewPlayer.GameReplicationInfo = GameReplicationInfo;

	// Apply security to this controller
	NewPlayer.PlayerSecurity = spawn(SecurityClass,self);
	if (NewPlayer.PlayerSecurity==None)
	{
		log("Could not spawn security for player "$NewPlayer,'Security');
	}
    
    newPlayer.bWasInvited = bInvited;

    if( newPlayer.bWasInvited )
    {
        NumInvitedPlayers++;
    }

    // If we are a server, broadcast a welcome message.
    if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
        BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);

    // if delayed start, don't give a pawn to the player yet
    // Normal for multiplayer games
    if ( bDelayedStart )
    {
        NewPlayer.GotoState('PlayerWaiting');
		return NewPlayer;   
    }

    // Try to match up to existing unoccupied player in level,
    // for savegames and coop level switching.
    /*ForEach DynamicActors(class'Pawn', TestPawn )
    {
        if ( (TestPawn!=None) && (PlayerController(TestPawn.Controller)!=None) && (PlayerController(TestPawn.Controller).Player==None) && (TestPawn.Health > 0)
            &&  (TestPawn.OwnerName~=InName) )
        {
            NewPlayer.Destroy();
            TestPawn.SetRotation(TestPawn.Controller.Rotation);
            TestPawn.bInitializeAnimation = false; // FIXME - temporary workaround for lack of meshinstance serialization
            TestPawn.PlayWaiting();
            return PlayerController(TestPawn.Controller);
        }
    }*/
    return newPlayer;
}


simulated function GetIntoVehicle( string Type, VehiclePlayer P, vector Loc )
{
    local class<VGVehicle>		VehicleClass;

	VehicleClass = class<VGVehicle>(DynamicLoadObject( Type, class'Class') );

	assert( VehicleClass != None );
	assert( P != None );
	assert( P.Pawn != None );
	assert( P.Pawn.IsA('VGPawn') );
	
	if( P.Pawn != None && P.Pawn.IsA('VGPawn') )
	{
		// requires offset so vehicle doesn't spawn at the same place as the player
		TryMapVehicle = spawn( VehicleClass, self, , Loc + vect(0,0,300) );
		
		if( TryMapVehicle == None )
		{
			log("ERROR- Failed to Spawn Vehicle");
			return;
		}
	}
	else
	{
		log( "ERROR- Can't spawn vehicle because the pawn is not of type VGPawn" );
		return;
	}
	
	TryMapVehicle.SetupVehicleWeapons();
	TryMapVehicle.TryToDrive( P.Pawn );
}
			

function RestartPlayer( Controller aPlayer )    
{
	local NavigationPoint startSpot;
	
	if( !bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
        return;

	if( bMenuLevel || bTryingMap )
	{
		//Spawn the pawn at the controllers player start when trying the map
		startSpot = FindPlayerStart( aPlayer );
		aPlayer.StartSpot = startSpot;

		if( startSpot == None )
			return;
	}

	SpawnPlayerPawn(aPlayer);

	if( aPlayer.Pawn == None )
	{
		//cmr - this sometimes happens (safely, it appears).  Handle it.
		return;
	}
	
	aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
	AddDefaultInventory(aPlayer.Pawn);
	
	aPlayer.NotifyRestarted();
	TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);
}


function SpawnPlayerPawn( Controller aPlayer )
{
	local class<Pawn> DefaultPlayerClass;
	local vector Loc, HitNormal, HitLoc;
	local rotator Rot;
    local Actor HitActor;

	if( bMenuLevel || bTryingMap )
	{
		Loc = aPlayer.StartSpot.Location;
		Rot = aPlayer.StartSpot.Rotation;
	}
	else
	{
		log( "Spawning editing pawn at " $ BirdEyeCameraLoc $ " with rotation " $ BirdEyeCameraRot );
		Loc = BirdEyeCameraLoc;
		Rot = BirdEyeCameraRot;
	}

	if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
		BaseMutator.PlayerChangedClass(aPlayer);

    if ( aPlayer.PawnClass != None )
        aPlayer.Pawn = Spawn(aPlayer.PawnClass,,, Loc, Rot );

    if( aPlayer.Pawn == None )
    {
        DefaultPlayerClass = GetDefaultPlayerClass(aPlayer);
        aPlayer.Pawn = Spawn( DefaultPlayerClass,,, Loc, Rot );
    }

	if( aPlayer.pawn == None )
	{
        log( "Couldn't spawn at " $ aPlayer.StartSpot $ "(location = " $ Loc.X $ ", " $ Loc.Y $ ", " $ Loc.Z $ ")" );

        if( bMenuLevel || bTryingMap )
        {
            do
            {
                HitActor = Trace( HitLoc, HitNormal, Loc - vect(0,0,50000), Loc, false );
            }
            until( HitActor.IsA('TerrainInfo') )

            log( "start height - terrain below height = " $ (Loc.Z - HitLoc.Z) );
        }
        aPlayer.GotoState('Dead');
        return;
    }

    aPlayer.Pawn.Anchor = aPlayer.StartSpot;
	aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;
}


/* ParseOption()
 Find an option in the options string and return it.
*/
static function string ParseOption( string Options, string InKey )
{
    local string Pair, Key, Value;
    while( GrabOption( Options, Pair ) )
    {
        GetKeyValue( Pair, Key, Value );
        if( Key ~= InKey )
            return Value;
    }
    return "";
}


event PostInitGame( string Options, out string Error )
{
}


function NavigationPoint FindPlayerStart( Controller Player, optional byte Team, optional string incomingName )
{
    local NavigationPoint N, Picked;
    local int i;

    // always pick StartSpot at start of match
    if ( (Player != None) && (Player.StartSpot != None)
        && (bWaitingToStartMatch || ((Player.PlayerReplicationInfo != None) && Player.PlayerReplicationInfo.bWaitingPlayer))  )
    {
        return Player.StartSpot;
    }   

    if ( GameRulesModifiers != None )
    {
        N = GameRulesModifiers.FindPlayerStart(Player);
        if ( N != None )
            return N;
    }

	//Pick a random player start
	i = 1;
	foreach AllActors( class 'NavigationPoint', N )
	{
		if( !N.IsA('PlayerStart') )
			continue;

		if ( FRand() < (1.0 / float(i++)) )
			Picked = N;
	}
	
	return Picked;
}


event PostLogin( PlayerController NewPlayer )
{
    local class<HUD>	HudClass;
    local class<Menu>	ScoreboardClass;
    local class<Menu>	PersonalStatsClass;
    local String		SongName;
	local String		VehicleClassUsed;
	
    if ( !bDelayedStart )
    {
        // start match, or let player enter, immediately
        bRestartLevel = true;  // let player spawn once in levels that must be restarted after every death
        if ( bWaitingToStartMatch )
			StartMatch();
        else if( NewPlayer.CanRestartPlayer() )  //cmr
            RestartPlayer(NewPlayer);

        bRestartLevel = Default.bRestartLevel;
    }

    SongName = Level.Song;

    if( SongName == "" )
        SongName = "Level"$(Rand(NumMusicFiles) + 1);
    
    if( SongName != "None" )
	{
		NewPlayer.StopAllMusic( 0.0 ); //xmatt: when trying map and coming back audio streams keep adding up otherwise
        NewPlayer.ClientSetMusic( SongName, MTRAN_Fade );
	}
    
	//If the user pressed the "TryMap" button set the HUD to the deathmatch HUD
	if( bTryingMap )
	{	// Weapons take too much memory.
		//NewPlayer.Pawn.GiveWeapon("VehicleWeapons.HealingTool");
		NewPlayer.Pawn.GiveWeapon("VehicleWeapons.VGAssaultRifle");
		//NewPlayer.Pawn.GiveWeapon("VehicleWeapons.FragRifle");
		//NewPlayer.Pawn.GiveWeapon("VehicleWeapons.VGRocketLauncher");
		//NewPlayer.Pawn.GiveWeapon("VehicleWeapons.PlayerPlasmaGun");
		//NewPlayer.Pawn.GiveWeapon("VehicleWeapons.GrenadeLauncher");
		//NewPlayer.Pawn.GiveWeapon("VehicleWeapons.SniperRifle");
		//NewPlayer.Pawn.GiveWeapon("VehicleWeapons.TitansFist");
		//NewPlayer.Pawn.GiveWeapon("VehicleWeapons.BoneSaw");

		//Set what vehicle the player can spawn and give him a weapon
		switch( Transportation )
		{
			case 0:	
				//Tell the VehiclePlayer that we are running the MiniEd. It will skip the loadout
				NewPlayer.GotoState('PlayerWalking');
			break;
			
			case 1:
				if( Level.bNoHavok )
					VehicleClassUsed = "VehicleVehicles.VGWasp";
				else
					VehicleClassUsed = "VehicleVehicles.VGHavokWaspMP";
			break;

			case 2:
				if( Level.bNoHavok )
					VehicleClassUsed = "VehicleVehicles.VGDart";
				else
					VehicleClassUsed = "VehicleVehicles.VGHavokDartMP";
			break;

			case 3:
				if( Level.bNoHavok )
					VehicleClassUsed = "VehicleVehicles.VGBogie";
				else
					VehicleClassUsed = "VehicleVehicles.VGHavokBogieMP";
			break;
		}
		
		//If the player chose a vehicle
		if( VehicleClassUsed != "" )
		{
			log( "VehicleClassUsed: " $ VehicleClassUsed );
			GetIntoVehicle( VehicleClassUsed, VehiclePlayer(NewPlayer), SpawnLocation );
		}

		HudClass = class<HUD>(DynamicLoadObject("MiniEd.MiniEdHud", class'Class'));
		NewPlayer.bNoOverlay = true;
	}
	//Otherwise we use the MiniEdHud
	else
	{
		if( HUDType == "" )
			log( "No HUDType specified in GameInfo", 'Log' );
		else
		{
			HudClass = class<HUD>(DynamicLoadObject(HUDType, class'Class'));

			if( HudClass == None )
				log( "Can't find HUD class "$HUDType, 'Error' );
		}		
	}

    NewPlayer.ClientSetHUD( HudClass, ScoreboardClass, PersonalStatsClass );

    if ( NewPlayer.Pawn != None )
        NewPlayer.Pawn.ClientSetRotation(NewPlayer.Pawn.Rotation);
}


function Logout( Controller Exiting )
{
}

defaultproperties
{
     BirdEyeCameraLoc=(X=-12788.000000,Y=-13929.000000,Z=10670.000000)
     BirdEyeCameraRot=(Pitch=-8192,Yaw=8192)
     DefaultPlayerClassName="VehicleGame.VGPawn"
     HUDType="MiniEd.MiniEdHud"
     PlayerControllerClassName="MiniEd.MiniEdController"
     bDelayedStart=False
}
