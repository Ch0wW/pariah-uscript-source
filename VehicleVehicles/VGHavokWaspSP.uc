class VGHavokWaspSP extends VGHavokRaycastVehicle
	placeable;

//ini load out info
//var config				string	BigWeapon1;
var config					string	SmallWeapon1;
//var config				string	SmallWeapon2;

simulated function InitializeVehicle()
{
	Super.InitializeVehicle();
	GiveWeapon(SmallWeapon1);
}

simulated function DoVehicleDeathEffects()
{
	Super.DoVehicleDeathEffects();

	spawn(class'VehicleEffects.CaboomDistort',,,Location);
	spawn(class'VehicleEffects.CaboomExplosion',,,Location);
	spawn(class'VehicleEffects.DavidVehicleExplosionTiresWasp',,,Location);

}

defaultproperties
{
     TiretrackParameterScale=50.000000
     MaxSpeedFullSteeringAngle=4000.000000
     OptRPM=4000.000000
     MaxRPM=8000.000000
     MaxTorque=1000.000000
     TorqueFactorAtMinRPM=1.400000
     ResistanceFactorAtMinRPM=0.100000
     ResistanceFactorAtOptRPM=0.250000
     ResistanceFactorAtMaxRPM=0.750000
     ClutchSlipRPM=500.000000
     DownshiftRPM=800.000000
     UpshiftRPM=2600.000000
     PrimaryTransmissionRatio=8.000000
     ReverseGearRatio=1.400000
     MinTimeToLockWheels=0.100000
     FrontalArea=10000.000000
     DragCoefficient=0.300000
     LiftCoefficient=-0.200000
     InAirSpinDampingTime=0.001000
     InAirNormalSpinDamping=0.010000
     InAirCollisionSpinDamping=1.500000
     NormalSpinDamping=4.000000
     CollisionSpinDamping=8.000000
     CollisionAngVelThreshold=2.000000
     MinSpeedForExtraLinearDamping=1800.000000
     ExtraLinearDampingRate=0.010000
     TorquePitchFactor=0.600000
     TorqueYawFactor=0.600000
     ExtraSteerTorqueFactor=0.000000
     HitImpulseScale=5.000000
     HitImpulseRadialScale=0.850000
     MaxHitImpulse=270000.000000
     FlipDropHeight=200.000000
     Wheels(0)=(Radius=42.000000,Width=42.000000,Mass=9.000000,Friction=0.900000,ViscosityFriction=0.050000,MaxBrakingTorque=8000.000000,HardpointCS=(X=104.424004,Y=-100.000000,Z=-25.000000),DirectionCS=(Z=-1.000000),Length=15.000000,Strength=55.000000,DampingCompression=1.300000,DampingRelaxation=1.300000,TorqueRatio=0.300000,SuspensionIndex=1,Mesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspTire')
     Wheels(1)=(Radius=42.000000,Width=42.000000,Mass=9.000000,Friction=0.900000,ViscosityFriction=0.050000,MaxBrakingTorque=8000.000000,HardpointCS=(X=104.424004,Y=100.000000,Z=-25.000000),DirectionCS=(Z=-1.000000),Length=15.000000,Strength=55.000000,DampingCompression=1.300000,DampingRelaxation=1.300000,TorqueRatio=0.300000,FlipMeshInY=True,NegateSuspOffsetY=True,SuspensionIndex=2,Mesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspTire')
     Wheels(2)=(Axle=1,Radius=47.000000,Width=60.000000,Mass=11.000000,Friction=0.550000,ViscosityFriction=0.050000,MaxBrakingTorque=6000.000000,HardpointCS=(X=-120.525002,Z=-25.000000),DirectionCS=(Z=-1.000000),Length=15.000000,Strength=55.000000,DampingCompression=1.900000,DampingRelaxation=1.900000,TorqueRatio=0.400000,SteeringLocked=True,UsedByHandbrake=True,Mesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspTireRear')
     Begin Object Class=TireEffectInfo Name=TireEffectInfo0
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=15.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirt'
     End Object
     TireEffects(0)=TireEffectInfo'VehicleVehicles.TireEffectInfo0'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo1
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=300.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtB'
     End Object
     TireEffects(1)=TireEffectInfo'VehicleVehicles.TireEffectInfo1'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo2
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Water
         SurfaceTypes(1)=EST_Wet
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireWater'
     End Object
     TireEffects(2)=TireEffectInfo'VehicleVehicles.TireEffectInfo2'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo3
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Dirt
         SurfaceTypes(1)=EST_Rock
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDust'
     End Object
     TireEffects(3)=TireEffectInfo'VehicleVehicles.TireEffectInfo3'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo4
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=10.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Metal
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDirtC'
     End Object
     TireEffects(4)=TireEffectInfo'VehicleVehicles.TireEffectInfo4'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo5
         TireSlipScale=0.500000
         TireSlipRange=(Min=100.000000,Max=300.000000)
         SurfaceTypes(0)=EST_Metal
         MaxPPS=10.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(5)=TireEffectInfo'VehicleVehicles.TireEffectInfo5'
     Begin Object Class=TireEffectInfo Name=TireEffectInfo6
         TireSpeedScale=0.050000
         TireSpeedRange=(Min=100.000000,Max=3000.000000)
         ControlType=TEC_TireSpeed
         SurfaceTypes(0)=EST_Plant
         MaxPPS=20.000000
         EmitterClass=Class'VehicleEffects.DavidTireDustB'
     End Object
     TireEffects(6)=TireEffectInfo'VehicleVehicles.TireEffectInfo6'
     Suspensions(0)=(DecoPieces=((Base=SPL_Wheel,TargetOffset=(X=-37.226002,Z=0.683000),StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspSuspensionRear')))
     Suspensions(1)=(DecoPieces=((BaseOffset=(X=104.714996,Y=-24.374001,Z=-32.264999),Target=SPL_Wheel,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspSuspensionBase01'),(BaseOffset=(X=104.714996,Y=-29.235001,Z=9.626000),Target=SPL_Wheel,TargetOffset=(Y=-26.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspSuspensionSpring01')))
     Suspensions(2)=(DecoPieces=((BaseOffset=(X=104.714996,Y=-24.374001,Z=-32.264999),Target=SPL_Wheel,TargetOffset=(Z=-10.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspSuspensionBase02'),(BaseOffset=(X=104.714996,Y=-29.235001,Z=9.626000),Target=SPL_Wheel,TargetOffset=(Y=-26.000000),StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspSuspensionSpring02')))
     Tiretracks(0)=(Surfaces=(EST_Metal,EST_Rock,EST_Plant,EST_Dirt),MinSkidEnergy=1.000000,MaxSkidEnergy=1000.000000,Material=Texture'PariahVehicleTextures.Shared.TireTreadColour')
     GearRatios(0)=1.400000
     GearRatios(1)=1.000000
     GearRatios(2)=0.600000
     ExtraGravity=(Z=-250.000000)
     ShiftUpSoundVolume=246
     ShiftDownSoundVolume=153
     WeaponMounts=1
     MaxSteerAngle=7000.000000
     ChassisMass=500.000000
     ChassisFriction=1.000000
     TailLightSeparation=32.188999
     HeadLightProjectorDistance=800.000000
     HeadLightReattachDistance=50.000000
     ShadowDrawScale=2.000000
     campitch=-2000.000000
     camdist=600.000000
     camheight=200.000000
     LookAngleForMaxSteer=8192.000000
     HitSoundMinImpactThreshold=100.000000
     HitSoundMaxImpactThreshold=1000.000000
     EngineSoundPitchScale=1500.000000
     ReverseSoundPitchScale=-800.000000
     ReverseSoundMinVelocity=500.000000
     TireSlipSoundMinSlipVel=100.000000
     TireSlipSoundMaxSlipVel=700.000000
     TireImpactSoundMinImpactThreshold=100.000000
     TireImpactSoundMaxImpactThreshold=500.000000
     MinRamSpeed=500.000000
     RammingDamage=50.000000
     RammingDamageMultiplier=2.000000
     RammingTimeout=3.000000
     ExitBrakeTime=0.100000
     ShadowTexture=Texture'PariahVehicleEffectsTextures.GroundShadows.WaspShadow'
     EnterVehicleSound=Sound'NewVehicleSounds.Wasp.WaspEngineStartA'
     ExitVehicleSound=Sound'NewVehicleSounds.Wasp.WaspEngineStopA'
     EngineSound=Sound'NewVehicleSounds.Wasp.WaspEngineIdleA'
     HitSound=Sound'NewVehicleSounds.Dozer.DozerImpactA'
     DeathSound=Sound'NewVehicleSounds.explosions.VehicleExplosionB'
     ReverseSound=Sound'NewVehicleSounds.Wasp.WaspEngineIdleA'
     TireSlipSound=Sound'NewVehicleSounds.TireSpin.TireSpinGravelC'
     TireImpactSound=Sound'PariahVehicleSounds.Vehicle_Bump.22-Bumps_Road'
     DrivingAnim="Wasp_Driver"
     DrivingAnimR="Wasp_SteerR"
     DrivingAnimL="Wasp_SteerL"
     WeaponMountName(0)="WP1"
     DriverPointName="PointDriver"
     DriverEntryAnims(0)="Wasp_Driver_InLeft"
     DriverEntryAnims(1)="Wasp_Driver_InRight"
     DriverExitAnim="Wasp_Driver_OutLeft"
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo99
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Wasp.WaspFrontBad'
         AttachPoints(0)="PointFront"
         DamageSequence(0)=(Action=DSA_AttachMesh)
     End Object
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo0
         DamageRadius=250.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Wasp.WaspFrontClean'
         PartMeshes(1)=StaticMesh'PariahVehicleMeshes.Wasp.WaspFrontDamaged'
         PartMeshes(2)=StaticMesh'PariahVehicleMeshes.Wasp.WaspFrontOff01'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointFront"
         AttachPoints(1)="PointOff01"
         DamageableParts(0)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo99'
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredImpactDamage=10,RequiredOtherDamage=10,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredImpactDamage=20,RequiredOtherDamage=10,Action=DSA_AttachMesh)
         DamageSequence(3)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(4)=(RequiredImpactDamage=20,RequiredOtherDamage=20,Action=DSA_AttachMesh,IArg1=1)
         DamageSequence(5)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_SpawnEmitter)
         DamageSequence(6)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_AttachMesh,IArg1=2)
         DamageSequence(7)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_SpawnEmitter,Vec=(X=41.000000,Y=-40.000000,Z=-17.000000))
         DamageSequence(8)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_SpawnDamageablePart)
         DamageSequence(9)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_AttachMesh,IArg1=2,IArg2=1)
         DamageSequence(10)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_RelMoveMesh)
         DamageSequence(11)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(X=25000.000000,Z=20000.000000))
         DamageSequence(12)=(RequiredImpactDamage=30,RequiredOtherDamage=30,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(0)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo0'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo1
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Wasp.WaspFender01'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointFender01"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredOtherDamage=20,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredOtherDamage=20,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(X=20000.000000,Y=-20000.000000,Z=25000.000000))
         DamageSequence(4)=(RequiredOtherDamage=20,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(1)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo1'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo2
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Wasp.WaspFender02'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointFender02"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredOtherDamage=20,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredOtherDamage=20,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(X=20000.000000,Y=20000.000000,Z=25000.000000))
         DamageSequence(4)=(RequiredOtherDamage=20,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(2)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo2'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo3
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Wasp.WaspPanel01'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanel01"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredOtherDamage=20,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredOtherDamage=20,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(X=20000.000000,Y=-20000.000000,Z=25000.000000))
         DamageSequence(4)=(RequiredOtherDamage=20,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(3)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo3'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo4
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Wasp.WaspPanel02'
         Effects(0)=(EmitterClass=Class'VehicleEffects.DavidDamagePieceShrapnel')
         Effects(1)=(EmitterClass=Class'VehicleEffects.DavidExplosionPieceTrailSmall')
         AttachPoints(0)="PointPanel02"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(RequiredOtherDamage=20,Action=DSA_SpawnEmitter)
         DamageSequence(2)=(RequiredOtherDamage=20,Action=DSA_RelMoveMesh)
         DamageSequence(3)=(RequiredOtherDamage=20,Action=DSA_TurnOnKarmaWithAttachedEmitter,IArg1=1,FArg1=5.000000,Vec=(X=20000.000000,Y=20000.000000,Z=25000.000000))
         DamageSequence(4)=(RequiredOtherDamage=20,Action=DSA_Destroy,IArg1=3)
     End Object
     DamageableParts(4)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo4'
     Begin Object Class=VGDamageablePartInfo Name=VGDamageablePartInfo15
         DamageRadius=200.000000
         PartMeshes(0)=StaticMesh'PariahVehicleMeshes.Wasp.WaspHandlebar'
         AttachPoints(0)="PointHandlebar"
         DamageSequence(0)=(Action=DSA_AttachMesh)
         DamageSequence(1)=(Action=DSA_SteeringMovesMesh,Rot=(Yaw=-4551))
     End Object
     DamageableParts(5)=VGDamageablePartInfo'VehicleVehicles.VGDamageablePartInfo15'
     DriverEntryNames(0)="PointDriverLeft"
     DriverEntryNames(1)="PointDriverRight"
     DefaultWeapons(0)="VehicleWeapons.Puncher"
     Begin Object Class=VehicleEffectInfo Name=VehicleEffectInfo8
         PPSBase=50.000000
         PPSScale=-1.000000
         ControlRange=(Min=0.000000,Max=100.000000)
         StartVelocityRange=(RangeBase=(X=(Min=200.000000,Max=500.000000),Y=(Min=200.000000,Max=500.000000),Z=(Min=50.000000,Max=200.000000)),RangeScale=(X=(Min=5.000000,Max=1.000000),Y=(Min=5.000000,Max=1.000000),Z=(Min=5.000000,Max=1.000000)))
         ControlType=VEC_Health
         MaxPPS=30.000000
         EmitterClass=Class'VehicleEffects.DavidEngineSmoke'
     End Object
     CarEffects(0)=(OnWhenCarEmpty=True,Location=(X=110.000000,Z=30.000000),Effects=(VehicleEffectInfo'VehicleVehicles.VehicleEffectInfo8'))
     PreLoadClasses(0)="VehicleWeapons.Puncher"
     ExitPos(0)=(X=40.000000,Y=-180.000000)
     LightOffset=(X=171.000000,Z=5.000000)
     TailLightOffset=(X=-175.000000,Z=37.000000)
     VehicleName="Wasp"
     VehicleType=VT_Wheeled
     TailLightBrakeSaturation=200
     TailLightBrakeBrightness=150
     TailLightBackupBrightness=0
     TailLightDrivingSaturation=0
     TailLightDrivingBrightness=0
     HeadLightHue=40
     HeadLightBrightness=130
     EngineSoundVolume=195
     DeathSoundVolume=255
     ReverseSoundPitch=15
     ReverseSoundVolume=195
     EngineSoundScaler=ESS_VehicleSpeed
     TireSlipSoundMaxVolume=132
     bEnableHeadLightEmitter=False
     bEnableShadow=True
     HealthMax=300.000000
     CollisionRadius=150.000000
     CollisionHeight=150.000000
     StaticMesh=StaticMesh'PariahVehicleMeshes.Wasp.WaspChassisSP'
     Begin Object Class=HavokParams Name=VGHavokWaspHParams
         LinearDamping=0.100000
         AngularDamping=0.100000
         StartEnabled=True
         Restitution=0.100000
     End Object
     HParams=HavokParams'VehicleVehicles.VGHavokWaspHParams'
}
