class VGHavokDozerSP extends VGHavokSimpleCar
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
     MaxTorque=2000.000000
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
     InAirSpinDampingTime=0.001000
     InAirNormalSpinDamping=0.010000
     InAirCollisionSpinDamping=1.500000
     NormalSpinDamping=4.000000
     CollisionSpinDamping=8.000000
     CollisionAngVelThreshold=2.000000
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
     FlipDropHeight=250.000000
     Begin Object Class=TireEffectInfo Name=TireEffectInfo117
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=15.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirt'
     End Object
     TireEffects(0)=TireEffectInfo'VehicleVehicles.TireEffectInfo117'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo118
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtB'
     End Object
     TireEffects(1)=TireEffectInfo'VehicleVehicles.TireEffectInfo118'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo119
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Water
         SurfaceTypes(1)=EST_Wet
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireWater'
     End Object
     TireEffects(2)=TireEffectInfo'VehicleVehicles.TireEffectInfo119'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo120
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDust'
     End Object
     TireEffects(3)=TireEffectInfo'VehicleVehicles.TireEffectInfo120'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo121
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Metal
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtC'
     End Object
     TireEffects(4)=TireEffectInfo'VehicleVehicles.TireEffectInfo121'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo122
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Metal
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(5)=TireEffectInfo'VehicleVehicles.TireEffectInfo122'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo123
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=100.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Plant
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(6)=TireEffectInfo'VehicleVehicles.TireEffectInfo123'
     Suspensions(0)=(DecoPieces=((BaseOffset=(X=143.442993,Y=73.363998,Z=-45.923000),Target=SPL_Wheel0,TargetOffset=(Y=-100.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerSuspension01')))
     Suspensions(1)=(DecoPieces=((BaseOffset=(X=143.442993,Y=73.363998,Z=-45.923000),Target=SPL_Wheel1,TargetOffset=(Y=-100.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerSuspension02')))
     Suspensions(2)=(DecoPieces=((BaseOffset=(X=-147.330002,Y=73.363998,Z=-45.923000),Target=SPL_Wheel2,TargetOffset=(Y=-100.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerSuspension02')))
     Suspensions(3)=(DecoPieces=((BaseOffset=(X=-147.330002,Y=73.363998,Z=-45.923000),Target=SPL_Wheel3,TargetOffset=(Y=-100.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerSuspension01')))
     Tiretracks(0)=(Surfaces=(EST_Metal,EST_Rock,EST_Plant,EST_Dirt),Material=Texture'PariahVehicleTextures.Shared.TireTreadColour')
     GearRatios(0)=1.400000
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
     camheight=350.000000
     LookAngleForMaxSteer=8192.000000
     LookSteerMaxPitch=6000.000000
     HitSoundMinImpactThreshold=200.000000
     HitSoundMaxImpactThreshold=3000.000000
     EngineSoundPitchScale=2000.000000
     ReverseSoundPitchScale=-2000.000000
     ReverseSoundMinVelocity=300.000000
     TireSlipSoundMinSlipVel=100.000000
     TireSlipSoundMaxSlipVel=800.000000
     TireImpactSoundMinImpactThreshold=100.000000
     TireImpactSoundMaxImpactThreshold=500.000000
     MinRamSpeed=300.000000
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
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo134
         DamageRadius=350.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dozer.DozerFront'
         PartMeshes(1)=StaticMesh'PariahVehicleMeshes.Dozer.DozerFrontDamaged'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointFront"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_AttachMesh,IArg1=1)
     End Object
     DamageableParts(0)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo134'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo135
         DamageRadius=350.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dozer.DozerRear'
         PartMeshes(1)=StaticMesh'PariahVehicleMeshes.Dozer.DozerRearDamaged'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointRear"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_AttachMesh,IArg1=1)
     End Object
     DamageableParts(1)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo135'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo136
         DamageRadius=350.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dozer.DozerSide01'
         PartMeshes(1)=StaticMesh'PariahVehicleMeshes.Dozer.DozerSide01Damaged'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointSide01"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_AttachMesh,IArg1=1)
     End Object
     DamageableParts(2)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo136'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo137
         DamageRadius=350.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dozer.DozerSide02'
         PartMeshes(1)=StaticMesh'PariahVehicleMeshes.Dozer.DozerSide02Damaged'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointSide02"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_AttachMesh,IArg1=1)
     End Object
     DamageableParts(3)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo137'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo138
         DamageRadius=300.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dozer.DozerPanel01'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanel01"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(X=20000.000000,Y=-20000.000000,Z=20000.000000))
         DamageSequence(4)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(4)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo138'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo5
         DamageRadius=300.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dozer.DozerPanel02'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanel02"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(X=20000.000000,Y=20000.000000,Z=20000.000000))
         DamageSequence(4)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(5)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo5'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo6
         DamageRadius=300.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dozer.DozerPanel03'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanel03"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(X=-20000.000000,Y=-20000.000000,Z=20000.000000))
         DamageSequence(4)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(6)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo6'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo7
         DamageRadius=300.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dozer.DozerPanel04'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanel04"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(X=-20000.000000,Y=20000.000000,Z=20000.000000))
         DamageSequence(4)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(7)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo7'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo8
         DamageRadius=300.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dozer.DozerPanelRear01'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanelRear01"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=40,RequiredOtherDamage=40,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=40,RequiredOtherDamage=40,Action=DSA_RelMoveMesh,Vec=(Z=5.000000))
         DamageSequence(3)=(RequiredImpactDamage=40,RequiredOtherDamage=40,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=10.000000,Vec=(X=-25000.000000,Y=-35000.000000,Z=35000.000000))
         DamageSequence(4)=(RequiredImpactDamage=40,RequiredOtherDamage=40,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(8)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo8'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo9
         DamageRadius=300.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Dozer.DozerPanelRear02'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanelRear02"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=40,RequiredOtherDamage=40,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=40,RequiredOtherDamage=40,Action=DSA_RelMoveMesh,Vec=(Z=5.000000))
         DamageSequence(3)=(RequiredImpactDamage=40,RequiredOtherDamage=40,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=10.000000,Vec=(X=-25000.000000,Y=35000.000000,Z=35000.000000))
         DamageSequence(4)=(RequiredImpactDamage=40,RequiredOtherDamage=40,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(9)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo9'
     DriverEntryNames(0)="PointDriverIn01"
     PassengerPointNames(0)="PointPassenger01"
     PassengerPointNames(1)="PointPassenger02"
     PassengerPointNames(2)="PointPassenger03"
     PassengerPointEntryNames(0)="PointPassengerIn01"
     PassengerPointEntryNames(1)="PointPassengerIn02"
     PassengerPointEntryNames(2)="PointPassengerIn03"
     DefaultWeapons(0)="VehicleWeapons.Puncher"
     Begin Object Class=VehicleEffectInfo Name=VehicleEffectInfo1
         PPSBase=50.000000
         PPSScale=-1.000000
         ControlRange=(Min=0.000000,Max=250.000000)
         ControlType=VEC_Health
         MaxPPS=30.000000
         EmitterClass=Class'VehicleEffects.DavidEngineSmoke'
     End Object
     CarEffects(0)=(OnWhenCarEmpty=True,Location=(X=300.000000,Z=60.000000),Effects=(VehicleEffectInfo'VehicleVehicles.VehicleEffectInfo1'))
     Begin Object Class=VehicleEffectInfo Name=VehicleEffectInfo2
         PPSBase=50.000000
         PPSScale=-1.000000
         ControlRange=(Min=0.000000,Max=100.000000)
         ControlType=VEC_Health
         MaxPPS=30.000000
         EmitterClass=Class'VehicleEffects.DavidEngineSmoke'
     End Object
     CarEffects(1)=(OnWhenCarEmpty=True,Location=(X=-150.000000,Z=10.000000),Effects=(VehicleEffectInfo'VehicleVehicles.VehicleEffectInfo2'))
     PreLoadClasses(0)="VehicleWeapons.DozerLauncher"
     LightOffset=(X=343.000000,Z=-18.400000)
     TailLightOffset=(X=-228.000000,Z=30.000000)
     PassengerCameras(0)=(bLimitYaw=True,CenterYaw=32768,MaxYaw=10000)
     PassengerCameras(1)=(bLimitYaw=True,CenterYaw=-16384,MaxYaw=10000)
     PassengerCameras(2)=(bLimitYaw=True,CenterYaw=16384,MaxYaw=10000)
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
     Health=1800
     HealthMax=1800.000000
     CollisionRadius=500.000000
     CollisionHeight=250.000000
     StaticMesh=StaticMesh'PariahVehicleMeshes.Dozer.DozerChassisSP'
     Begin Object Class=HavokParams Name=VGHavokDozerHParams
         LinearDamping=0.100000
         AngularDamping=0.100000
         StartEnabled=True
         Restitution=0.100000
     End Object
     HParams=HavokParams'VehicleVehicles.VGHavokDozerHParams'
}
