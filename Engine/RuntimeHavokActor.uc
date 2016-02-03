//
// HavokActor that can be spawned at runtime
//

class RuntimeHavokActor extends HavokActor;

var() bool bFuckPaths;

var() Vector m_LastLocation;
var() Vector m_LastRotation;

var() float FuckRadius;
const MINDISTTHRESHOLD = 10;
const MINROTTHRESHOLD = 0.8;

function Tick(float dt)
{
	local Vector vecRotation;

	if(!bFuckPaths) return;

	//check if we've translated
	if( VSize(m_LastLocation - Location) > MINDISTTHRESHOLD  )
	{
		m_LastLocation = Location;
		class'AIUtil'.static.ModifyPaths(Level, self, FuckRadius);
	}
	else //check if we've rotated
	{
		vecRotation = Vector(Rotation);
		if( (m_LastRotation dot vecRotation) < MINROTTHRESHOLD )
		{
			m_LastRotation = vecRotation;
			class'AIUtil'.static.ModifyPaths(Level, self, FuckRadius);
		}
	}

}

defaultproperties
{
     FuckRadius=100.000000
     bNoDelete=False
}
