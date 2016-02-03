class UtilPostFXStage extends MultiStepPostFXStage
	native
	noteditinlinenew
	hidecategories(Setup);

var HardwareMaterial CopyMaterial;
var HardwareMaterial AfterimageMaterial;
var int HudRefs;

simulated function AddHudRef()
{
    ++HudRefs;
}

simulated function RemoveHudRef()
{
    --HudRefs;
}

defaultproperties
{
     CopyMaterial=HardwareMaterial'VehicleGame.CopyMaterial'
     AfterimageMaterial=HardwareMaterial'VehicleGame.AfterimageMaterial'
     bRuntimeSetup=True
}
