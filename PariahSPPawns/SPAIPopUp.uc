class SPAIPopUp extends SPAIController;
	
function Restart()
{
    Super.Restart();
}

function bool MayDive() { return false; }

function configure(OpponentFactory f, Stage initialStage)
{
    Super.configure(f, initialStage);
    ClaimPosition( closestPos() );
}

function StagePosition closestPos()
{
    local int i;
    local float bestDist, dist;
    local StagePosition pos, bestPos;

    bestDist = 9999;
    for( i=0; i < currentStage.StagePositions.Length; i++ )
    {
        pos = currentStage.StagePositions[i];
        dist = VSize(pos.Location - Pawn.Location) ;
        if( dist < bestDist )
        {
            bestPos = pos;
            bestDist = dist;
        }
    }
    return bestPos;
}

function InitAIRole()
{
    if ( myAIRole == None ) {
        if ( AIType == None ) AIType = class'AIRoleWhackAMole';
        myAIRole = Spawn(AIType,self);
    }
    myAIRole.init(self);
    AIRoleWhackAMole(myAIRole).myBot = self;
}


//////////////////////////////

state NotEngaged_AtRest
{
    function setFocus()
    {
        if(claimedPosition != None)
		    SetFocalPointNearLocation( Vector(claimedPosition.Rotation)*2000 + Pawn.Location );
    }
}


//////////////////////////////
function Perform_Engaged_Hide( optional float standTime)
{
	StandGroundTime = standTime;
	if(Focus != Enemy) //not visible
	{
		SetFocalPointNearLocation(LastSeenPos);
	}
	else
		Focus = Enemy;
    curAction = "Hide";
    GotoState('Engaged_HideCrouched');
}

state Engaged_HideCrouched
{
//ignores EnemyNotVisible;

BEGIN:
    Pawn.bWantsToCrouch = true;
    Sleep(standGroundTime);
    myAIRole.HideFromEnemySucceeded();
}
///////////////////////////////


//===================
// Override possible orders that would make us move.
//===================
function bool AdjustAround(Pawn Other) { return false; }

function Perform_Engaged_StrafeMove() {}

function bool ShouldMelee(Pawn Seen){ return false; }

function bool StageOrder_TakeUpPosition( StagePosition pos ) {
    return false;
}


function StageOrder_Patrol(PatrolPosition pos) {}

defaultproperties
{
}
