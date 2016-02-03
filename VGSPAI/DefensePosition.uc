/**
 * DefensePosition - positions designated in a DefenseStage as points
 * that are good for positioning bots.
 *
 * @version $Revision: 1.4 $
 * @author  Neil Gower (neilg@digitalextremes.com)
 * @date    June 2003
 */
class DefensePosition extends StagePathNode
   placeable;

#exec Texture Import File=Textures\DefBall.tga Name=DefensePositionIcon Mips=Off MASKED=1

defaultproperties
{
     DrawScale=3.000000
     Texture=Texture'VGSPAI.DefensePositionIcon'
}
