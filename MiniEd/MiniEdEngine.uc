class MiniEdEngine extends Engine
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

var object				m_MiniEd;
var bool				m_bLiveMap;
var bool				m_bLoadedMap;
var bool				m_bMapDirty;
var bool                m_bDeferredLiveMap;
var const level			Level;
var const level			GEntry;
var URL					LastURL;
var URL					PostInitURL;
var bool				FramePresentPending;
var const class			CurrentClass;
var const textbuffer	Results;
var int					PaintingLayerIndex;
var const object		ParentContext;
var const array<Object> Tools;
var(Advanced) config	array<string> EditPackages;
var config String		LoadingVignette;
var config String		UnloadingVignette;
var Object				TerrainInfo;
var bool				bTryingMap;
var bool				bGoingIn;
var bool				bGoingOut;
var int					TransportationType;
var vector				PrevLookAt;
var vector				m_LookAtXY;
var vector				LookAtDirection;
var bool				bLookAtChanged;
var string				SavedMenuEditorArgs;

//------------------------------------------

defaultproperties
{
     LoadingVignette="XInterfaceHuds.VignetteLoading"
     UnloadingVignette="XInterfaceHuds.VignetteMiniEd"
}
