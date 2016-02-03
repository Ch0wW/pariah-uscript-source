/*
	SpeedMovingAverage: Takes positions and timestamps and maintains a moving distance average
	xmatt
*/

class SpeedMovingAverage extends Object;

var array<vector> Positions;
var array<float> TimeStamps;
var int			 SampleSize;

//Information
var float		 Sum;
var float		 TotalTime;

//Assumption: SampleSize > 0
//
simulated function Add( vector NewPosition, float timestamp )
{
	local float DeltaTime;
	
	if( Positions.Length == SampleSize )
	{
		Sum -= (TimeStamps[1]-TimeStamps[0])*VSize(Positions[1]-Positions[0]);
		Positions.Remove( 0, 1 );
		TimeStamps.Remove( 0, 1 );
	}
	
	//If after putting that value we only have 1 sample point
	if( Positions.Length == 0 )
	{
		Sum = 0;
	}
	else
	{
		DeltaTime = (timestamp - TimeStamps[TimeStamps.Length-1]);
		Sum += DeltaTime*VSize(NewPosition - Positions[Positions.Length-1]);
	}
	if( (timestamp - TimeStamps[TimeStamps.Length-1]) < 0 )
		log("Negative: " $ (timestamp - TimeStamps[TimeStamps.Length-1]));
		
	Positions[Positions.Length] = NewPosition;
	TimeStamps[TimeStamps.Length] = timestamp;
}

simulated function Clear()
{
	Positions.Remove(0,Positions.Length);
	Sum = 0;
}

simulated function float GetAverage()
{
	local float TotalTime;
	
	//Need at least two points to get a delta
	if( Positions.Length < 2 )
		return 0;

	TotalTime = TimeStamps[TimeStamps.Length-1] - TimeStamps[0];
	return Sum/TotalTime;
}

defaultproperties
{
     SampleSize=5
}
