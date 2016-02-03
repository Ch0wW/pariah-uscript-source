/*
	Average: Takes data and maintains a moving average of it
	xmatt
*/

class Average extends Object;

var array<float>	Data;
var int				SampleSize;

//Information
var float			Sum;

//Assumption: SampleSize > 0
//
simulated function Add( float x )
{
	if( Data.Length == SampleSize )
	{
		Sum -= Data[0];
		Data.Remove( 0, 1 );
	}
	
	Data[Data.Length] = x;
	Sum += x;
}

simulated function Clear()
{
	Data.Remove(0,Data.Length);
	Sum = 0;
}

simulated function float GetAverage()
{
	return Sum/SampleSize;
}

defaultproperties
{
     SampleSize=5
}
