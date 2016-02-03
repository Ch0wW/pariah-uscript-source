class VGHavokDartMP extends VGHavokHovercraft
	placeable;

simulated function DoVehicleDeathEffects()
{
	Super.DoVehicleDeathEffects();

	spawn(class'VehicleEffects.CaboomDistort',,,Location);
	spawn(class'VehicleEffects.CaboomExplosion',,,Location);
}

defaultproperties
{
     HoverStrength=5.000000
     HoverCompressionDamping=0.700000
     HoverReboundDamping=0.700000
     HoverDist=240.000000
     MaxThrust=18000.000000
     MaxSteerTorque=22000.000000
     ForwardDampFactor=5.000000
     VacantForwardDampFactor=30.000000
     LateralDampFactor=75.000000
     PitchDampFactor=5000.000000
     BankTorqueFactor=5000.000000
     BankDampFactor=5000.000000
     UprightTorqueFactor=20000.000000
     Repulsors(0)=(AttachPoint="RP1",bCreateEmitters=True)
     Repulsors(1)=(AttachPoint="RP2")
     FrontalArea=10000.000000
     DragCoefficient=0.300000
     LiftCoefficient=-0.500000
     InAirSpinDampingTime=5.100000
     MinSpeedForExtraLinearDamping=1800.000000
     ExtraLinearDampingRate=0.010000
     HitImpulseScale=5.000000
     HitImpulseRadialScale=0.800000
     MaxHitImpulse=270000.000000
     HitImpulseLinearDamping=0.100000
     FlipDropHeight=250.000000
     Begin Object Class=TireEffectInfo Name=TireEffectInfo72
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=0.000000,Max=2200.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=30.000000
         EmitterClass=Class'VehicleEffects.HoverVehicleDirtDust'
     End Object
     TireEffects(0)=TireEffectInfo'VehicleVehicles.TireEffectInfo72'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo73
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=0.000000,Max=2200.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Water
         MaxPPS=30.000000
         EmitterClass=Class'VehicleEffects.HoverVehicleWater'
     End Object
     TireEffects(1)=TireEffectInfo'VehicleVehicles.TireEffectInfo73'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo74
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=0.000000,Max=2200.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Wood
         SurfaceTypes(1)=EST_Metal
         MaxPPS=30.000000
         EmitterClass=Class'VehicleEffects.HoverVehicleDust'
     End Object
     TireEffects(2)=TireEffectInfo'VehicleVehicles.TireEffectInfo74'
     GearRatios(0)=2.000000
     ExtraGravity=(Z=-50.000000)
     WeaponMounts=1
     ChassisMass=590.000000
     ChassisFriction=0.200000
     TailLightSeparation=32.188999
     HeadLightProjectorDistance=800.000000
     HeadLightReattachDistance=50.000000
     ShadowDrawScale=2.000000
     campitch=-2000.000000
     camdist=600.000000
     camheight=200.000000
     LookAngleForMaxSteer=8192.000000
     LookSteerMaxPitch=6000.000000
     HitSoundMinImpactThreshold=200.000000
     HitSoundMaxImpactThreshold=3000.000000
     EngineSoundPitchScale=4500.000000
     TireSlipSoundMinSlipVel=100.000000
     TireSlipSoundMaxSlipVel=500.000000
     MinRamSpeed=1000.000000
     RammingDamageMultiplier=2.000000
     RammingTimeout=3.000000
     ExitBrakeTime=0.100000
     ShadowTexture=Texture'PariahVehicleEffectsTextures.GroundShadows.DartShadow'
     EnterVehicleSound=Sound'NewVehicleSounds.Dart.DartIgnitionA'
     ExitVehicleSound=Sound'NewVehicleSounds.Dart.DartIgnitionOffA'
     EngineSound=Sound'NewVehicleSounds.Dart.DartEngineA'
     HitSound=Sound'NewVehicleSounds.Dozer.DozerImpactA'
     DeathSound=Sound'NewVehicleSounds.explosions.DartExplosionA'
     DrivingAnim="Dart_Driver"
     DrivingAnimR="Dart_SteerR"
     DrivingAnimL="Dart_SteerL"
     WeaponMountName(0)="WP1"
     DriverPointName="PointDriver"
     DriverEntryAnims(0)="Dart_Driver_InLeft"
     DriverEntryAnims(1)="Dart_Driver_InRight"
     DriverExitAnim="Dart_Driver_OutLeft"
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo82
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dart.DartHandlebar'
         AttachPoints(0)="PointHandlebar"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(Action=DSA_SteeringMovesMesh,Rot=(Yaw=-1820))
     End Object
     DamageableParts(5)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo82'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo83
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dart.DartRudder'
         AttachPoints(0)="PointRudder"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(Action=DSA_SteeringMovesMesh,Rot=(Yaw=6000))
     End Object
     DamageableParts(8)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo83'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo84
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dart.DartThrusters'
         AttachPoints(0)="PointThrusters"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(Action=DSA_ThrottleMovesMesh,Rot=(Pitch=-5000))
     End Object
     DamageableParts(9)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo84'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo85
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dart.DartFlap01'
         AttachPoints(0)="PointFlap01"
         DamageSequence(0)=(Action=DSA_AttachMesh,Rot=(Pitch=2000,Yaw=-7000,Roll=3800))
         DamageSequence(1)=(Action=DSA_SteeringMovesMesh,FArg1=-1.000000,Rot=(Pitch=2000,Yaw=-7000))
     End Object
     DamageableParts(10)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo85'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo86
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dart.DartFlap02'
         AttachPoints(0)="PointFlap02"
         DamageSequence(0)=(Action=DSA_AttachMesh,Rot=(Pitch=2000,Yaw=7000,Roll=-3800))
         DamageSequence(1)=(Action=DSA_SteeringMovesMesh,FArg1=1.000000,Rot=(Pitch=-2000,Yaw=-7000))
     End Object
     DamageableParts(11)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo86'
     DriverEntryNames(0)="PointDriverIn01"
     DriverEntryNames(1)="PointDriverIn02"
     DefaultWeapons(0)="VehicleWeapons.Puncher"
     Begin Object Class=VehicleEffectInfo Name=VehicleEffectInfo11
         PPSBase=50.000000
         PPSScale=-1.000000
         ControlRange=(Min=0.000000,Max=42.000000)
         ControlType=VEC_Health
         MaxPPS=30.000000
         EmitterClass=Class'VehicleEffects.DavidEngineSmoke'
     End Object
     CarEffects(0)=(OnWhenCarEmpty=True,Location=(X=110.000000,Z=30.000000),Effects=(VehicleEffectInfo'VehicleVehicles.VehicleEffectInfo11'))
     PreLoadClasses(0)="VehicleWeapons.DartGun"
     LightOffset=(X=171.218002,Z=1.261000)
     TailLightOffset=(X=-125.365997,Z=35.891998)
     VehicleName="Dart"
     TailLightBrakeSaturation=200
     TailLightBrakeBrightness=100
     TailLightBackupBrightness=110
     TailLightDrivingSaturation=200
     TailLightDrivingBrightness=70
     HeadLightHue=40
     HeadLightBrightness=130
     EnterVehicleSoundVolume=219
     EngineSoundVolume=214
     DeathSoundVolume=255
     ReverseSoundPitch=64
     EngineSoundScaler=ESS_VehicleSpeed
     TireSlipSoundMaxVolume=132
     bEnableHeadLightEmitter=False
     bEnableShadow=True
     HealthMax=300.000000
     CollisionRadius=75.000000
     CollisionHeight=75.000000
     StaticMesh=StaticMesh'PariahVehicleMeshes.Dart.DartChassisMP'
     Begin Object Class=HavokParams Name=HavokParams17
         LinearDamping=0.100000
         AngularDamping=0.100000
         StartEnabled=True
         Restitution=0.100000
         ImpactThreshold=0.000000
     End Object
     HParams=HavokParams'VehicleVehicles.HavokParams17'
}
