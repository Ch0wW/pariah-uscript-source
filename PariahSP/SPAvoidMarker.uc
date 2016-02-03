/** 
 * Used to alert bots of dangerous things
 **/
 
class SPAvoidMarker extends AvoidMarker;


function StartleOtherThings()
{
    local int i;
    
    for(i=0; i< SinglePlayer(Level.Game).Stages.Length; i++)
    {
        SinglePlayer(Level.Game).Stages[i].AddAvoid(Location, CollisionRadius);
    }
}

function Destroyed()
{
    local int i;
    
    for(i=0; i< SinglePlayer(Level.Game).Stages.Length; i++)
    {
        SinglePlayer(Level.Game).Stages[i].RemoveAvoid(Location, CollisionRadius);
    }  
}

function Touch( actor Other )
{
    //if ( (Pawn(Other) != None) && (Pawn(Other).Controller != None) )
	//	Pawn(Other).Controller.FearThisSpot(self);
}

defaultproperties
{
}
