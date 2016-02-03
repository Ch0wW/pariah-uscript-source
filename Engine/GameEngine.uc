//=============================================================================
// GameEngine: The game subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class GameEngine extends Engine
	native
	noexport
	transient;

// URL structure.
struct URL
{
	var string			Protocol,	// Protocol, i.e. "unreal" or "http".
						Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var int				Port;		// Optional host port.
	var string			Map;		// Map name, i.e. "SkyCity", default is "Index".
	var array<string>	Op;			// Options.
	var string			Portal;		// Portal to enter through, default is "".
	var bool			Valid;
};

var Level			GLevel,
					GEntry;
var PendingLevel	GPendingLevel;
var URL				LastURL;
var URL             PostInitURL; // sjs
var config array<string>	ServerActors,
					ServerPackages;

var array<object> DummyArray;	// Do not modify	

// gam ---
var config String LoadingVignette;
var config String UnloadingVignette;
var config String MiniEdVignette;
var config String SinglePlayerVignette;
var config String ConnectingVignette;

var config String DisconnectMenuClass;
var config String DisconnectMenuArgs;

enum EGeographicArea
{
    GA_NorthAmerica,
    GA_SouthAmerica,
    GA_Europe,
    GA_CentralAsia,
    GA_SouthEastAsia,
    GA_Africa,
    GA_Australia
};

var(Settings) config EGeographicArea GeographicArea;

// --- gam

// rj ---
var string LoadMapMenuClassName;
var string LoadMapMenuArgs;
// --- rj

var bool			FramePresentPending;

defaultproperties
{
     ServerActors(0)="IpDrv.UdpBeacon"
     ServerActors(1)="IpDrv.MasterServerUplink"
     ServerActors(2)="UWeb.WebServer"
     ServerPackages(0)="Core"
     ServerPackages(1)="Engine"
     ServerPackages(2)="Fire"
     ServerPackages(3)="Editor"
     ServerPackages(4)="IpDrv"
     ServerPackages(5)="GamePlay"
     ServerPackages(6)="UnrealGame"
     ServerPackages(7)="VehicleEffects"
     ServerPackages(8)="XGame"
     ServerPackages(9)="MiniEdPawns"
     ServerPackages(10)="XInterface"
     ServerPackages(11)="XInterfaceHuds"
     ServerPackages(12)="XInterfaceCommon"
     ServerPackages(13)="XInterfaceMP"
     ServerPackages(14)="XInterfaceSettings"
     ServerPackages(15)="XInterfaceLive"
     ServerPackages(16)="VehicleGame"
     ServerPackages(17)="VehiclePickups"
     ServerPackages(18)="VehicleWeapons"
     ServerPackages(19)="VehicleVehicles"
     ServerPackages(20)="VehicleInterface"
     ServerPackages(21)="VGSPAI"
     ServerPackages(22)="PariahSP"
     ServerPackages(23)="PariahSPPawns"
     ServerPackages(24)="MiniEd"
     LoadingVignette="XInterfaceHuds.VignetteLoading"
     UnloadingVignette="XInterfaceHuds.VignetteUnloading"
     MiniEdVignette="XInterfaceHuds.VignetteMiniEd"
     SinglePlayerVignette="XInterfaceHuds.VignetteSinglePlayer"
     ConnectingVignette="XInterfaceHuds.VignetteConnecting"
     DisconnectMenuClass="XInterfaceCommon.MenuMain"
     GeographicArea=GA_Europe
     AudioDevice=None
     Console=None
     NetworkDevice=None
     CacheSizeMegs=32
     UseStaticMeshBatching=False
}
