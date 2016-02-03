class AutoHeadLight extends Effects;

#exec OBJ LOAD FILE=..\Textures\PariahVehicleTextures.utx

defaultproperties
{
     DrawScale=0.100000
     CoronaFadeMultiplier=20.000000
     Skins(0)=Texture'PariahVehicleTextures.Shared.headlight_corona'
     LightHue=150
     LightSaturation=210
     bCorona=True
     bCoronaAttenuation=True
}
