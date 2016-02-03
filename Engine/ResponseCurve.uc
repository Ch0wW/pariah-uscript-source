/**
 * An approximation to a curve.
 *   Input a bunch of sample points (x,y)
 *   Then query for the value f(x)
 *   See AI GameProgrammingWisdom 2.6
 *   
 *   - samples for y are added sequentially
 *   - x is assumed to always be [0,1]
 *   - samples are distributed evenly across x
 **/

class ResponseCurve extends Object
    native;

var array<float>    mValues;
var float   mBucketSize;

native function AddSamplePoint( float y );
native function float GetPointAt( float x );

/*
function testExample(out ResponseCurve rc)
{
    local int i;
   
    rc.AddSamplePoint(2);
    rc.AddSamplePoint(4);
    rc.AddSamplePoint(1);
    rc.AddSamplePoint(1);
    
    log("OutPut:");
    log("-------");
    for(i=0; i< rc.mValues.Length; i++)
        log("m[" $i$ "] =" @ rc.mValues[i] );

    log( "(-1,"     @ rc.GetPointAt(-1) $")"@            "expected: 2" );
    log( "(2,"      @ rc.GetPointAt(2) $")" @            "expected: 1");
    log( "0.3r,"    @ rc.GetPointAt(0.333333333) $")" @  "expected: 4");
    log( "(0.16r,"  @ rc.GetPointAt(0.166666666) $")"@   "expected: 3" );
    log( "(0.5,"    @ rc.GetPointAt(0.5) $")" @          "expected: 2.5");
    log( "(0.83r,"  @ rc.GetPointAt(0.833333333) $")" @  "expected: 1" );
    log("----------");
}
*/

defaultproperties
{
}
