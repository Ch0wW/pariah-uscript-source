class SkillResponseCurves extends Actor;

var ResponseCurve	mCurve2;
var ResponseCurve	mCurve4;
var ResponseCurve	mCurve6;
var ResponseCurve	mCurveDefault;

static final function float GetPointAt(int skill, float t)
{
    if( skill < 2)
    {
		return(default.mCurve2.GetPointAt(t));
    }
    if( skill < 4)
    {
		return(default.mCurve4.GetPointAt(t));
    }
    if( skill < 6 )
    {
		return(default.mCurve6.GetPointAt(t));   
    }
	return(default.mCurveDefault.GetPointAt(t));
}

defaultproperties
{
     mCurve2=ResponseCurve'VGSPAI.ResponseCurve2'
     mCurve4=ResponseCurve'VGSPAI.ResponseCurve4'
     mCurve6=ResponseCurve'VGSPAI.ResponseCurve6'
     mCurveDefault=ResponseCurve'VGSPAI.ResponseCurveDef'
}
