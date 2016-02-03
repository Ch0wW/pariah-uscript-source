class SPMilitaryExclaim extends SPHumanExclaim;

#exec OBJ LOAD FILE=AIStateDialogueGroups.uax

defaultproperties
{
     sndIdle=SoundGroup'AIStateDialogueGroups.AIStateMAS.AIStateMASIdles'
     sndNotice=SoundGroup'AIStateDialogueGroups.AIStateMAS.AIStateMASAlert'
     sndLost=SoundGroup'AIStateDialogueGroups.AIStateMAS.AIStateMASLost'
     sndAttacking=SoundGroup'AIStateDialogueGroups.AIStateMAS.AIStateMASCombat'
     sndFriendlyFire=SoundGroup'AIStateDialogueGroups.AIStateMAS.AIStateMASFriendly'
     sndKilledEnemy=SoundGroup'AIStateDialogueGroups.AIStateMAS.AIStateMASGloat'
}
