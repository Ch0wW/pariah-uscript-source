class Shader extends RenderedMaterial
	editinlinenew
	native;

// faces of the normalization cubemap
#exec Texture Import file=Textures\NormFace0.pcx Name=NormFace0 Mips=Off
#exec Texture Import file=Textures\NormFace1.pcx Name=NormFace1 Mips=Off
#exec Texture Import file=Textures\NormFace2.pcx Name=NormFace2 Mips=Off
#exec Texture Import file=Textures\NormFace3.pcx Name=NormFace3 Mips=Off
#exec Texture Import file=Textures\NormFace4.pcx Name=NormFace4 Mips=Off
#exec Texture Import file=Textures\NormFace5.pcx Name=NormFace5 Mips=Off

var() editinlineuse Material Diffuse;
var() editinlineuse Material Opacity;

var() editinlineuse Material Specular;
var() editinlineuse Material SpecularityMask;

var() editinlineuse Material SelfIllumination;
var() editinlineuse Material SelfIlluminationMask;

var() editinlineuse Material Detail;
var() float DetailScale;

var(Bump) editinlineuse Material Bump;
var(Bump) editinlineuse Material BumpSpecularMask;

var() enum EOutputBlending
{
	OB_Normal,
	OB_Masked,
	OB_Modulate,
	OB_Translucent,
	OB_Invisible,
	OB_Brighten,
	OB_Darken
} OutputBlending;

var() bool TwoSided;
var() bool Wireframe;
var   bool ModulateStaticLighting2X;
var() bool PerformLightingOnSpecularPass;
var() bool ModulateSpecular2X; // sjs

var(Bump) bool BumpUseCompositeLight;
var(Bump) bool BumpUseTangentSpace;
var(Bump) enum EBumpSpecular
{
	BS_None,
	BS_SpecularFalloff1,
	BS_SpecularFalloff2,
	BS_SpecularFalloff4,
	BS_SpecularFalloff8,
	BS_SpecularFalloff16,
	BS_SpecularFalloff32,
	BS_CustomFalloff
} BumpSpecular;
var(Bump) float BumpSpecularFalloff;
var(Bump) float BumpSpecularScale;
var(Bump) vector BumpLightDirScale;
var(Bump) int BumpPasses;

var Cubemap BumpSpecularNormalizer;
var(Bump) bool BumpNormalizeSpecular;

function Reset()
{
	if(Diffuse != None)
		Diffuse.Reset();
	if(Opacity != None)
		Opacity.Reset();
	if(Specular != None)
		Specular.Reset();
	if(SpecularityMask != None)
		SpecularityMask.Reset();
	if(SelfIllumination != None)
		SelfIllumination.Reset();
	if(SelfIlluminationMask != None)
		SelfIlluminationMask.Reset();
	if(Bump != None)
		Bump.Reset();
	if(FallbackMaterial != None)
		FallbackMaterial.Reset();
}

function Set( Shader Other )
{
	Diffuse=Other.Diffuse;
	Opacity=Other.Opacity;
	Specular=Other.Specular;
	SpecularityMask=Other.SpecularityMask;
	SelfIllumination=Other.SelfIllumination;
	SelfIlluminationMask=Other.SelfIlluminationMask;
	Detail=Other.Detail;
	DetailScale=Other.DetailScale;
	Bump=Other.Bump;
	BumpSpecularMask=Other.BumpSpecularMask;
	OutputBlending=Other.OutputBlending;
	TwoSided=Other.TwoSided;
	Wireframe=Other.Wireframe;
	ModulateStaticLighting2X=Other.ModulateStaticLighting2X;
	PerformLightingOnSpecularPass=Other.PerformLightingOnSpecularPass;
	ModulateSpecular2X=Other.ModulateSpecular2X;
	BumpUseCompositeLight=Other.BumpUseCompositeLight;
	BumpUseTangentSpace=Other.BumpUseTangentSpace;
	BumpSpecular=Other.BumpSpecular;
	BumpSpecularFalloff=Other.BumpSpecularFalloff;
	BumpSpecularScale=Other.BumpSpecularScale;
	BumpLightDirScale=Other.BumpLightDirScale;
	BumpPasses=Other.BumpPasses;
	BumpSpecularNormalizer=Other.BumpSpecularNormalizer;
	BumpNormalizeSpecular=Other.BumpNormalizeSpecular;
}

function Trigger( Actor Other, Actor EventInstigator )
{
	if(Diffuse != None)
		Diffuse.Trigger(Other,EventInstigator);
	if(Opacity != None)
		Opacity.Trigger(Other,EventInstigator);
	if(Specular != None)
		Specular.Trigger(Other,EventInstigator);
	if(SpecularityMask != None)
		SpecularityMask.Trigger(Other,EventInstigator);
	if(SelfIllumination != None)
		SelfIllumination.Trigger(Other,EventInstigator);
	if(SelfIlluminationMask != None)
		SelfIlluminationMask.Trigger(Other,EventInstigator);
	if(FallbackMaterial != None)
		FallbackMaterial.Trigger(Other,EventInstigator);
	if(Bump != None)
		Bump.Trigger(Other,EventInstigator);
}

defaultproperties
{
     BumpPasses=1
     DetailScale=8.000000
     BumpSpecularFalloff=1.000000
     BumpSpecularScale=1.000000
     BumpSpecularNormalizer=Cubemap'Engine.NormalizerCubemap'
     BumpLightDirScale=(X=1.000000,Y=1.000000,Z=1.000000)
     ModulateStaticLighting2X=True
     BumpUseCompositeLight=True
     BumpNormalizeSpecular=True
}
