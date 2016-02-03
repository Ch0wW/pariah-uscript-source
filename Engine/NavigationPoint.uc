//=============================================================================
// NavigationPoint.
//
// NavigationPoints are organized into a network to provide AIControllers 
// the capability of determining paths to arbitrary destinations in a level
//
//=============================================================================
class NavigationPoint extends Actor
	hidecategories(Lighting,LightColor,Karma,Force)
	native;

#exec Texture Import File=Textures\S_Pickup.pcx Name=S_Pickup Mips=Off MASKED=1
#exec Texture Import File=Textures\SpwnAI.pcx Name=S_NavP Mips=Off MASKED=1

// not used currently
#exec Texture Import File=Textures\SiteLite.pcx Name=S_Alarm Mips=Off MASKED=1

//------------------------------------------------------------------------------
// NavigationPoint variables
var const array<ReachSpec> PathList; //index of reachspecs (used by C++ Navigation code)
var() name ProscribedPaths[4];	// list of names of NavigationPoints which should never be connected from this path
var() name ForcedPaths[4];		// list of names of NavigationPoints which should always be connected from this path

var int visitedWeight;
var const int HeuristicCost;

var const NavigationPoint nextNavigationPoint;
var const NavigationPoint nextOrdered;	// for internal use during route searches
var const NavigationPoint prevOrdered;	// for internal use during route searches
var const NavigationPoint previousPath;
var int cost;					// added cost to visit this pathnode
var() int ExtraCost;			// Extra weight added by level designer
var transient int TransientCost;	// added right before a path finding attempt, cleared afterward.
var	transient int FearCost;		// extra weight diminishing over time (used for example, to mark path where bot died)

var transient bool bEndPoint;	// used by C++ navigation code
var transient bool bTransientEndPoint; // set right before a path finding attempt, cleared afterward.
var bool taken;					// set when a creature is occupying this spot
var() bool bBlocked;			// this path is currently unuseable 
var() bool bPropagatesSound;	// this navigation point can be used for sound propagation (around corners)
var() bool bOneWayPath;			// reachspecs from this path only in the direction the path is facing (180 degrees)
var() bool bNeverUseStrafing;	// shouldn't use bAdvancedTactics going to this point
var() bool bAlwaysUseStrafing;	// shouldn't use bAdvancedTactics going to this point
var const bool bForceNoStrafing;// override any LD changes to bNeverUseStrafing
var const bool bAutoBuilt;		// placed during execution of "PATHS BUILD"
var	bool bSpecialMove;			// if true, pawn will call SuggestMovePreparation() when moving toward this node
var bool bNoAutoConnect;		// don't connect this path to others except with special conditions (used by LiftCenter, for example)
var	const bool	bNotBased;		// used by path builder - if true, no error reported if node doesn't have a valid base
var const bool  bPathsChanged;	// used for incremental path rebuilding in the editor
var bool		bDestinationOnly; // used by path building - means no automatically generated paths are sourced from this node
var	bool		bSourceOnly;	// used by path building - means this node is not the destination of any automatically generated path
var bool		bSpecialForced;	// paths that are forced should call the SpecialCost() and SuggestMovePreparation() functions
var bool		bMustBeReachable;	// used for PathReview code

var Pickup	InventoryCache;		// used to point to dropped weapons
var float	InventoryDist;

function PostBeginPlay()
{
	ExtraCost = Max(ExtraCost,0);
	Super.PostBeginPlay();
}

event int SpecialCost(Pawn Seeker, ReachSpec Path);

// Accept an actor that has teleported in.
// used for random spawning and initial placement of creatures
event bool Accept( actor Incoming, actor Source )
{
	// Move the actor here.
	taken = Incoming.SetLocation( Location );
	if (taken)
	{
		Incoming.Velocity = vect(0,0,0);
		Incoming.SetRotation(Rotation);
	}
	Incoming.PlayTeleportEffect(true, false);
	TriggerEvent(Event, self, Pawn(Incoming));
	return taken;
}

/* DetourWeight()
value of this path to take a quick detour (usually 0, used when on route to distant objective, but want to grab inventory for example)
*/
event float DetourWeight(Pawn Other,float PathWeight);
 
/* SuggestMovePreparation()
Optionally tell Pawn any special instructions to prepare for moving to this goal
(called by Pawn.PrepareForMove() if this node's bSpecialMove==true
*/
event bool SuggestMovePreparation(Pawn Other)
{
	return false;
}

/* ProceedWithMove()
Called by Controller to see if move is now possible when a mover reports to the waiting
pawn that it has completed its move
*/
function bool ProceedWithMove(Pawn Other)
{
	return true;
}

/* MoverOpened() & MoverClosed() used by NavigationPoints associated with movers */
function MoverOpened();
function MoverClosed();

defaultproperties
{
     bPropagatesSound=True
     CollisionRadius=55.000000
     CollisionHeight=100.000000
     Texture=Texture'Engine.S_NavP'
     SoundVolume=0
     bStatic=True
     bHidden=True
     bNoDelete=True
     bCollideWhenPlacing=True
}
