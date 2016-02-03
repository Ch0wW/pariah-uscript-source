/**
 * PatrolStage - 
 *
 * @version $Revision: 1.7 $
 * @author  Mike Horgan (mikeh@digitalextremes.com)
 * @date    Oct 2003
 */
class PatrolStage extends Stage
	placeable;

#exec Texture Import File=Textures\PatrolTower.tga Name=PatrolStageIcon Mips=Off MASKED=1


//===============
// Internal data
//===============
var Array<PatrolPosition> PatrolPositions;

//=============================
// Controller->Stage interface
//=============================

/**
 * Alert other agents of bogie
 **/
function Report_EnemySpotted( Pawn enemy )
{
   local int i;

   Super.Report_EnemySpotted(enemy);

   DebugLog( "enemy (" @ Enemy @ ") spotted " );
   for(i=0; i<StageAgents.length; i++)
   {
      StageAgents[i].controller.StageOrder_None();
   }
}

function joinStage( VGSPAIController c )
{
   super.joinStage( c );
   if( c.Enemy == None )
        Request_IdleOrder( c );
}

/**
 * If a bot find himself with nothing to do, request an order from the stage
 **/
function Request_IdleOrder(VGSPAIController c)
{
    assignPatrol( c );   
}


//================
// Implementation
//================

/**
 */
function PostBeginPlay() {
	local int i, numPatrolPositions;
	local PatrolPosition pn;

	super.PostBeginPlay();
	numPatrolPositions = 0;
	for ( i = 0; i < StagePositions.length; ++i )
	{
		pn = PatrolPosition( StagePositions[i] );
		if ( pn != None )
		{
			PatrolPositions[numPatrolPositions++] = pn;
		}
	}
}

/**
 * Assign a patrol position to the bot, and update our books
 **/
function assignPatrol(VGSPAIController C)
{
    local PatrolPosition node;

	super.joinStage( c );
	if ( c.Tag != '')
		node = pickAssignedPatrolStart(c);
	else
		node = pickRandomPatrolStart();
	if(node != None) {
		c.StageOrder_Patrol( node );
    }  
}

function PatrolPosition pickAssignedPatrolStart( VGSPAIController patroller )
{
	local int i;
	
	for ( i = 0; i < PatrolPositions.length; ++i )
	{
		if ( PatrolPositions[i].Tag == patroller.Tag )
		{
			return PatrolPositions[i];
		}
	}
	return None;
}

function PatrolPosition pickRandomPatrolStart()
{
	local int i, num;
	local PatrolPosition returnPosition;

	returnPosition = None;
	for ( i = 0; i < PatrolPositions.length; ++i )
	{
		if ( PatrolPositions[i].bStartPosition )
		{
			num++;
			if( FRand() < 1.0f/float(num) ) //  odds are  1/1, 1/2, 1/3, 1/4 ...
			{
				returnPosition = PatrolPositions[i];
			}
		}
	}
	return returnPosition;
}


//Doesn't do anything, but we can't have tick ignored
auto state Init
{
}

defaultproperties
{
     DrawScale=3.000000
     Texture=Texture'VGSPAI.PatrolStageIcon'
}
