class MaterialSwitch extends Modifier
	editinlinenew
	hidecategories(Modifier)
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

var() int Current;
var() editinlineuse array<Material> Materials;

function SetCurrentMaterial( int cur )
{
	if ( cur < 0 )
	{
		Current = 0;
	}
	else if ( cur >= Materials.Length )
	{
		Current = Materials.Length - 1;
	}
	else
	{
		Current = cur;
	}

	if( Materials.Length > 0 )
		Material = Materials[Current];
	else
		Material = None;
}

function Reset()
{
	SetCurrentMaterial( 0 );

	if( Material != None )
		Material.Reset();
	if( FallbackMaterial != None )
		FallbackMaterial.Reset();
}

function Trigger( Actor Other, Actor EventInstigator )
{
	local int next;

	next = Current + 1;
	if( next >= Materials.Length )
	{
		next = 0;
	}
	SetCurrentMaterial( next );

	if( Material != None )
		Material.Trigger( Other, EventInstigator );
	if( FallbackMaterial != None )
		FallbackMaterial.Trigger( Other, EventInstigator );
}

defaultproperties
{
}
