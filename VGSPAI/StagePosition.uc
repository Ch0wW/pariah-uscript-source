/**
 * A generic position for use with DEBAIT stages.  Marks locations on
 * the map that are significant to the stage.  Replaces StagePathNode,
 * which replaced AnnotatedPathNode.
 *
 * @version $Revision: 1.8 $
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @author  Mike Horgan (mikeh@digitalextremes.com)
 * @date    Dec 2003
 */
class StagePosition extends PathNode
	placeable
    native
	ShowCategories(Movement);

#exec Texture Import File=Textures\BlueBall.tga Name=StagePositionIcon Mips=Off MASKED=1

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

//=====================
// Editable properties
//=====================

// a list of StageNames for the stages this node is part of.
var() Name Stage;
// does this node provide some kind of cover?
enum ECoverType
{
    CA_None,
	CA_Standing,
	CA_Crouching,
	CA_LeanLeft,
	CA_LeanRight,
};

var() ECoverType	CoverType;
// 
var() const int CoverAngle;


//=====================
// Internal properties
//=====================

// These must be updated externally, and are round-robin updated, so
// might be stale.

// Enemy info vectors...
//
// 8-bit mask to keep track of 8 LOS's, should be able to shoot while
// standing.
var byte StandLOF;
// another 8-bit mask for line of fire while crouching
var byte CrouchLOF; 
// yet another, this time for cover
var byte CoverValid;
// another, does it make you hidden?
var byte HidingValid;

// The node is currently assigned to an NPC for LOS or wandering etc.
var bool bIsClaimed;
// This wouldn't be necessary if nodes were guaranteed to be in a
// certain spot above the ground.
var float   OnGroundZ;

var int avoidCount;
var float fDistToBuddies;
var float fProjDistToBuddies;

var float coverAngleCosine;

//
function UpdateStatus(int enemyIdx, Pawn enemy)
{
    local actor HitActor;
    local vector HitLocation, HitNormal, eyeLoc, nodeOnGround;
    local vector X,Y,Z, coverDir, enemyDir;

    if( enemy == None ) return;

    eyeLoc = vect(0,0,1) * enemy.default.BaseEyeHeight;
    GetAxes( Rotator(enemy.Location - Location), X,Y,Z);
    
    nodeOnGround = Location;
    nodeOnGround.Z = OnGroundZ;
    
    //Line of Fire is a bit tricky, since the GUN offset must be considered
    HitActor = Trace( HitLocation, HitNormal, enemy.Location + eyeLoc, 
                      nodeOnGround + vect(0,0,1)*enemy.CollisionHeight 
                         + eyeLoc + 15*Y, false );
    if (HitActor == None || HitActor == enemy) {
        StandLOF = StandLOF | (0x1 << enemyIdx);
    }
    else {
        StandLOF = StandLOF &  (~(0x1 << enemyIdx));
    }
    // now for crouching (line of fire)!
    HitActor = Trace( HitLocation, HitNormal, enemy.Location /*+ eyeLoc*/, 
                      nodeOnGround + vect(0,0,1)*(enemy.CrouchHeight-20) 
                         + eyeLoc + 15*Y, false );
    if (HitActor == None || HitActor == enemy) {
        CrouchLOF = CrouchLOF | (0x1 << enemyIdx);
    }
    else {
        CrouchLOF = CrouchLOF &  (~(0x1 << enemyIdx));
    }

    // update cover state
    if ( CoverType != CA_None) {
        coverDir = Normal( Vector(Rotation) * vect(1,1,0) );
        enemyDir = Normal( enemy.location * vect(1,1,0) 
                           - nodeOnGround * vect(1,1,0) );
        if ( (coverDir Dot enemyDir) > coverAngleCosine ) {
            coverValid = coverValid | (0x1 << enemyIdx);
        }
        else {
            coverValid = coverValid & ~(0x1 << enemyIdx);
        }
    }

    //update hide state
    //We don't want our butts hanging out
    HidingValid = HidingValid | (0x1 << enemyIdx);
    
    HitActor = Trace( HitLocation, HitNormal, enemy.Location + eyeLoc, 
                      Location + eyeLoc + enemy.CollisionRadius*Y, false );
    if(HitActor == None || HitActor == enemy)
    {
        HidingValid = HidingValid & ~(0x1 << enemyIdx);
        return;
    }
    HitActor = Trace( HitLocation, HitNormal, enemy.Location + eyeLoc, 
                      Location + eyeLoc - enemy.CollisionRadius*Y, false );
    if(HitActor == None || HitActor == enemy)
    {
        HidingValid = HidingValid & ~(0x1 << enemyIdx);
        return;
    }
}


//================
// Implementation
//================
function PreBeginPlay() {
    super.PreBeginPlay();
    // convert half the angle (on either side of center) to radians...
    coverAngleCosine = cos( CoverAngle * (pi/360) );
}

event String SuggestedGroup()
{
    return String(Stage) $ "," $ String(Stage)$".Positions";
}

defaultproperties
{
     CoverAngle=90
     DrawScale=2.000000
     Texture=Texture'VGSPAI.StagePositionIcon'
     bDirectional=True
}
