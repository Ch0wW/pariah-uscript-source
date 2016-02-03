class VGHavokDozerMP extends VGHavokSimpleCar
    placeable;

simulated function DoVehicleDeathEffects()
{
	Super.DoVehicleDeathEffects();

	spawn(class'VehicleEffects.CaboomDistort',,,Location);
	spawn(class'VehicleEffects.CaboomExplosion',,,Location);
	spawn(class'VehicleEffects.DavidVehicleExplosionTiresDozer',,,Location);
}

defaultproperties
{
     FrontRightSuspIndex=1
     RearLeftSuspIndex=2
     RearRightSuspIndex=3
     FrontWheelAlong=257.000000
     FrontWheelAcross=183.500000
     FrontWheelVert=-30.000000
     FrontWheelRadius=90.000000
     FrontWheelWidth=88.000000
     FrontWheelMass=20.000000
     FrontWheelFriction=2.000000
     FrontWheelViscosityFriction=0.050000
     FrontSuspStrength=20.000000
     FrontSuspCompressionDamping=0.500000
     FrontSuspRelaxationDamping=0.500000
     FrontSuspLength=50.000000
     FrontMaxBrakingTorque=8000.000000
     FrontMinPedalInputToBlock=0.700000
     RearWheelAlong=-240.000000
     RearWheelAcross=183.500000
     RearWheelVert=-30.000000
     RearWheelRadius=90.000000
     RearWheelWidth=88.000000
     RearWheelMass=20.000000
     RearWheelFriction=2.000000
     RearWheelViscosityFriction=0.050000
     RearSuspStrength=20.000000
     RearSuspCompressionDamping=0.500000
     RearSuspRelaxationDamping=0.500000
     RearSuspLength=50.000000
     RearMaxBrakingTorque=8000.000000
     RearMinPedalInputToBlock=0.700000
     FrontWheelMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerTire'
     RearWheelMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerTire'
     FourWheelSteering=True
     TiretrackParameterScale=80.000000
     MaxSpeedFullSteeringAngle=1500.000000
     MinRPM=1500.000000
     MaxRPM=8000.000000
     MaxTorque=3000.000000
     TorqueFactorAtMinRPM=1.400000
     TorqueFactorAtMaxRPM=0.600000
     ResistanceFactorAtMinRPM=0.100000
     ResistanceFactorAtOptRPM=0.250000
     ResistanceFactorAtMaxRPM=0.750000
     ClutchSlipRPM=500.000000
     DownshiftRPM=800.000000
     UpshiftRPM=1900.000000
     PrimaryTransmissionRatio=12.000000
     ReverseGearRatio=1.400000
     MinTimeToLockWheels=0.010000
     FrontalArea=20000.000000
     InAirSpinDampingTime=0.100000
     NormalSpinDamping=4.000000
     CollisionSpinDamping=8.000000
     MinSpeedForExtraLinearDamping=1000.000000
     ExtraLinearDampingRate=0.010000
     TorqueRollFactor=0.400000
     TorquePitchFactor=0.600000
     TorqueYawFactor=0.600000
     ExtraSteerTorqueFactor=0.000000
     ChassisUnitInertiaRoll=1.000000
     HitImpulseScale=5.000000
     HitImpulseRadialScale=0.850000
     MaxHitImpulse=270000.000000
     HitImpulseSpinScale=0.500000
     HitImpulseLinearDamping=0.250000
     FlipDropHeight=300.000000
     Begin Object Class=TireEffectInfo Name=TireEffectInfo110
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=15.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirt'
     End Object
     TireEffects(0)=TireEffectInfo'VehicleVehicles.TireEffectInfo110'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo111
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtB'
     End Object
     TireEffects(1)=TireEffectInfo'VehicleVehicles.TireEffectInfo111'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo112
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Water
         SurfaceTypes(1)=EST_Wet
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireWater'
     End Object
     TireEffects(2)=TireEffectInfo'VehicleVehicles.TireEffectInfo112'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo113
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDust'
     End Object
     TireEffects(3)=TireEffectInfo'VehicleVehicles.TireEffectInfo113'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo114
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Metal
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtC'
     End Object
     TireEffects(4)=TireEffectInfo'VehicleVehicles.TireEffectInfo114'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo115
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Metal
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(5)=TireEffectInfo'VehicleVehicles.TireEffectInfo115'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo116
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=100.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Plant
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(6)=TireEffectInfo'VehicleVehicles.TireEffectInfo116'
     Suspensions(0)=(DecoPieces=((BaseOffset=(X=143.442993,Y=73.363998,Z=-45.923000),Target=SPL_Wheel0,TargetOffset=(Y=-100.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerSuspension01')))
     Suspensions(1)=(DecoPieces=((BaseOffset=(X=143.442993,Y=73.363998,Z=-45.923000),Target=SPL_Wheel1,TargetOffset=(Y=-100.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerSuspension02')))
     Suspensions(2)=(DecoPieces=((BaseOffset=(X=-147.330002,Y=73.363998,Z=-45.923000),Target=SPL_Wheel2,TargetOffset=(Y=-100.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerSuspension02')))
     Suspensions(3)=(DecoPieces=((BaseOffset=(X=-147.330002,Y=73.363998,Z=-45.923000),Target=SPL_Wheel3,TargetOffset=(Y=-100.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerSuspension01')))
     Tiretracks(0)=(Surfaces=(EST_Metal,EST_Rock,EST_Plant,EST_Dirt),MinSkidEnergy=50.000000,MaxSkidEnergy=700.000000,Material=Texture'PariahVehicleTextures.Shared.TireTreadColour')
     GearRatios(0)=1.200000
     GearRatios(1)=0.800000
     GearRatios(2)=0.500000
     ExtraGravity=(Z=-250.000000)
     ShiftUpSoundVolume=194
     WeaponMounts=1
     MaxSteerAngle=4300.000000
     ChassisMass=2000.000000
     ChassisFriction=1.000000
     TailLightSeparation=90.000000
     HeadLightProjectorDistance=800.000000
     HeadLightReattachDistance=50.000000
     ShadowDrawScale=4.000000
     campitch=-2000.000000
     camheight=300.000000
     LookAngleForMaxSteer=8192.000000
     LookSteerMaxPitch=6000.000000
     HitSoundMinImpactThreshold=200.000000
     HitSoundMaxImpactThreshold=3000.000000
     EngineSoundPitchScale=2000.000000
     ReverseSoundPitchScale=-4000.000000
     ReverseSoundMinVelocity=300.000000
     TireSlipSoundMinSlipVel=100.000000
     TireSlipSoundMaxSlipVel=800.000000
     TireImpactSoundMinImpactThreshold=100.000000
     TireImpactSoundMaxImpactThreshold=500.000000
     MinRamSpeed=500.000000
     RammingDamage=100.000000
     RammingDamageMultiplier=2.000000
     RammingTimeout=3.000000
     ExitBrakeTime=0.100000
     ShadowTexture=Texture'PariahVehicleEffectsTextures.GroundShadows.DozerShadow'
     EnterVehicleSound=Sound'NewVehicleSounds.Dozer.DozerEngineStartB'
     ExitVehicleSound=Sound'NewVehicleSounds.Dozer.DozerShutDownA'
     EngineSound=Sound'NewVehicleSounds.Dozer.DozerIdleG'
     HitSound=Sound'NewVehicleSounds.Dozer.DozerImpactA'
     DeathSound=Sound'NewVehicleSounds.explosions.VehicleExplosionC'
     ReverseSound=Sound'NewVehicleSounds.Dozer.DozerIdleG'
     TireSlipSound=Sound'NewVehicleSounds.TireSpin.TireSpinGravelC'
     TireImpactSound=Sound'PariahVehicleSounds.Vehicle_Bump.22-Bumps_Road'
     DrivingAnim="Dozer_Driver"
     DrivingAnimR="Dozer_Driver"
     DrivingAnimL="Dozer_Driver"
     WeaponMountName(0)="WP1"
     DriverPointName="PointDriver"
     DriverEntryAnims(0)="Dozer_Driver_In"
     DriverExitAnim="Dozer_Driver_Out"
     RiderAnims(0)="Dozer_Pass_Rear"
     RiderAnims(1)="Dozer_Pass_Rear"
     RiderAnims(2)="Dozer_Pass_Rear"
     DriverEntryNames(0)="PointDriverIn01"
     PassengerPointNames(0)="PointPassenger01"
     PassengerPointNames(1)="PointPassenger02"
     PassengerPointNames(2)="PointPassenger03"
     PassengerPointEntryNames(0)="PointPassengerIn01"
     PassengerPointEntryNames(1)="PointPassengerIn02"
     PassengerPointEntryNames(2)="PointPassengerIn03"
     DefaultWeapons(0)="VehicleWeapons.Puncher"
     PreLoadClasses(0)="VehicleWeapons.DozerLauncher"
     LightOffset=(X=343.000000,Z=-18.400000)
     TailLightOffset=(X=-228.000000,Z=30.000000)
     PassengerCameras(0)=(bLimitYaw=True,CenterYaw=-16384,MaxYaw=10000)
     PassengerCameras(1)=(bLimitYaw=True,CenterYaw=16384,MaxYaw=10000)
     PassengerCameras(2)=(bLimitYaw=True,CenterYaw=32768,MaxYaw=10000)
     VehicleName="Dozer"
     TailLightBrakeSaturation=200
     TailLightBrakeBrightness=150
     TailLightBackupBrightness=0
     TailLightDrivingSaturation=0
     TailLightDrivingBrightness=0
     HeadLightHue=40
     HeadLightBrightness=130
     EngineSoundVolume=160
     DeathSoundVolume=255
     ReverseSoundPitch=74
     ReverseSoundVolume=163
     EngineSoundScaler=ESS_VehicleSpeed
     TireSlipSoundMaxVolume=132
     PassengerPointCount=3
     bEnableHeadLightEmitter=False
     bEnableShadow=True
     Health=900
     HealthMax=900.000000
     CollisionRadius=500.000000
     CollisionHeight=250.000000
     StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerChassisMP'
     Begin Object Class=HavokParams Name=HavokParams23
         LinearDamping=0.100000
         AngularDamping=0.100000
         StartEnabled=True
         Restitution=0.100000
         ImpactThreshold=0.000000
     End Object
     HParams=HavokParams'VehicleVehicles.HavokParams23'
}