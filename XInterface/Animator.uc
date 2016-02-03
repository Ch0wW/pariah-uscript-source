/*
	Animator
	Desc: Takes care of animating widgets
	xmatt
*/

class Animator extends Object
	exportstructs
	native;

struct AnimatedInfo
{
	var int ptr;
	var Name Type; //Type is lost using INT as pointers and we need it to call the proper move function	
};

var array<AnimatedInfo> WidgetsToAnimateInfo;
var int CreatorPtr; //Ptr to the menu who created it
var int Id; //Id that identifies this animator so that when the completion event happens, the script class can know which one it is
var bool bDelete;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
}
