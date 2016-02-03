class MaterialSwitchTrigger extends NetTrigger;

#exec Texture Import File=Textures\MaterialTrigger.pcx Name=S_MaterialTrigger Mips=Off MASKED=1

var() MaterialSwitch	Materials;
var() int				WhichMaterial;

simulated event PostNetBeginPlay()
{
	GLog( RJ3, "PostNetBeginPlay() called, Materials="$Materials$",WhichMaterial="$WhichMaterial );
	Super.PostNetBeginPlay();
}

simulated function bool EquivalentTrigger( NetTrigger t )
{
	// t is an equivalent trigger if it a MaterialSwitchTrigger affecting the same MaterialSwitch

	local MaterialSwitchTrigger	mst;

	mst = MaterialSwitchTrigger( t );
	return mst != None && mst.Materials == Materials;
}

simulated function Triggered()
{
	GLog( RJ3, "Triggered() called, Materials="$Materials$",WhichMaterial="$WhichMaterial );
	if ( Materials != None )
	{
		Materials.SetCurrentMaterial( WhichMaterial );
	}
}

defaultproperties
{
     bTriggersPersistentState=True
     Texture=Texture'Engine.S_MaterialTrigger'
     bCollideActors=False
}
