class BreakableGlassWindow extends SimpleDestroyableMesh
	placeable;
	//hidecategories(Havok,HavokProps);

#exec LOAD FILE="DavidTextures.utx"
#exec LOAD FILE="DavidPrefabs.usx"

var Material			Distortion;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Distortion != None )
	{
		bHasPostFXSkins = true;
	}
}

event GetPostFXSkins( out array<Material> PostFXSkins )
{
    PostFXSkins.Length = 1;
	PostFXSkins[0] = Distortion;
}

function GetBent(Pawn instigator,optional Controller ProjOwner)
{
	bHasPostFXSkins=false;
	SetCollision( false, false, false );
	Super.GetBent( instigator, ProjOwner );
}

defaultproperties
{
     Distortion=Texture'DavidTextures.BreakableWindow.GlassDistortion'
     MaxHealth=30
     DestroySound=SoundGroup'HavokObjectSounds.GlassBreak.GlassSmashRandom'
     DestroyedMesh=StaticMesh'DavidPrefabs.BreakableWindow.WindowSmashed'
     DestroyEmitters(0)=(AttachPoint="FX1",EmitterClass=Class'VehicleEffects.BreakableWindowGlass')
     DestroyEmitters(1)=(AttachPoint="FX2",EmitterClass=Class'VehicleEffects.BreakableWindowGlass')
     StaticMesh=StaticMesh'DavidPrefabs.BreakableWindow.WindowClean'
     Tag="BreakableGlassWindow"
     bDirectional=True
}
