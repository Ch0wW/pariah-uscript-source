class TailLight extends Effects;

#exec OBJ LOAD FILE=..\textures\PariahVehicleTextures.utx

defaultproperties
{
     DrawScale=0.100000
     CoronaFadeMultiplier=20.000000
     Skins(0)=Texture'PariahVehicleTextures.Shared.taillight_corona'
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=9
     LightSaturation=255
     bCorona=True
     bCoronaAttenuation=True
     bHidden=True
}
