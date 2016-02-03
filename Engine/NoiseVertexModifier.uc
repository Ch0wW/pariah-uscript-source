class NoiseVertexModifier extends VertexModifier
	native;

var () float	Frequency;
var () vector	Amplitude;
var () float	Speed;

var () vector	AttenuationPoints[4];
var () int		NumAttenuationPts;
var () float	AttenuationDistance;

var () bool		bNoiseAffectsTextureCoords;
var () bool		bNoiseAffectsObjectSpacePoint;

var () enum NoiseAttenuationType
{
	NAT_None,				// the noise isn't attenuated
	NAT_ObjectSpacePoint,	// noise is attenuated based on distance from object space point
	NAT_ObjectSpacePointX,	// noise is attenuated based on distance from object space point in X direction
	NAT_ObjectSpacePointY,	// noise is attenuated based on distance from object space point in Y direction
	NAT_ObjectSpacePointZ	// noise is attenuated based on distance from object space point in Z direction
} NoiseAttenuation;

var () enum NoiseSeedType
{
	NS_ObjectSpacePtXY,		// the seed for the noise is the object space point's x&y values
	NS_ObjectSpacePtXZ,		// the seed for the noise is the object space point's x&z values
	NS_ObjectSpacePtYZ,		// the seed for the noise is the object space point's y&z values
	NS_WorldSpacePtXY,		// the seed for the noise is the world space point's x&y values
	NS_WorldSpacePtXZ,		// the seed for the noise is the world space point's x&z values
	NS_WorldSpacePtYZ		// the seed for the noise is the world space point's y&z values
} NoiseSeed;

defaultproperties
{
     Frequency=3.500000
     Speed=1.000000
     Amplitude=(X=50.000000,Y=50.000000)
     bNoiseAffectsObjectSpacePoint=True
}
