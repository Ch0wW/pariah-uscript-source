/*
	Pulsator
	Desc: Scales up and down widgets
	Note: I use that in the minied to show a layer is selected
	xmatt
*/
class Pulsator extends Animator
	native;

var float Accumulator;
var float Speed;
var float MaxScale;
var array<AnimatedInfo> WidgetsCopiesInfo;	//Need a copy of the widget before we start scaling it 
											//so we can reset back the scales of each of its components
											//when done

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

defaultproperties
{
}
