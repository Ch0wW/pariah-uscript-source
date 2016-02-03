class SniperLight extends Effects;

simulated function SetEnabled(bool en)
{
    if(en)
        SetDrawScale(0.04);
    else
        SetDrawScale(0.0);
}

defaultproperties
{
     DrawScale=0.040000
     CoronaDrawScale=-1.000000
     CoronaFadeMultiplier=10.000000
     Mass=0.000000
     NetUpdateFrequency=50.000000
     Texture=Texture'MannyTextures.Coronas.lightblue_corona'
     Skins(0)=Texture'MannyTextures.Coronas.lightblue_corona'
     RotationRate=(Yaw=7000000)
     LightHue=150
     LightSaturation=210
     DrawType=DT_None
     RemoteRole=ROLE_SimulatedProxy
     Style=STY_Additive
     bCorona=True
     bCoronaAttenuation=True
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     bFixedRotationDir=True
}
