/**
 * PatrolPosition - 
 *
 * @version $Revision: 1.3 $
 * @author  Mike Horgan (mikeh@digitalextremes.com)
 * @date    Dec 2003
 */
class PatrolPosition extends StagePosition
    placeable
    native;

#exec Texture Import File=Textures\PatBall.tga Name=PatrolPositionIcon Mips=Off MASKED=1

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)


var() Name	nextPatrolPosition;
var() bool	bStartPosition;
var() float PauseTimeMin;
var() float PauseTimeMax;

var PatrolPosition  nextPosition;

/**
 */
function PreBeginPlay() 
{
    local PatrolPosition pn;
    ForEach AllActors( class'PatrolPosition', pn )
    {
        if(nextPatrolPosition == pn.Tag && Stage == pn.Stage)
        {	
            nextPosition = pn;
            break;
        }
    }
    if(nextPosition == None)
        log(self@self.tag@"has no NextPosition");       
}

defaultproperties
{
     DrawScale=3.000000
     Texture=Texture'VGSPAI.PatrolPositionIcon'
}
