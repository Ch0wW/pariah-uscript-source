class SPMercExclaim extends SPHumanExclaim;


#exec OBJ LOAD FILE=AIStateDialogueGroups.uax

defaultproperties
{
     sndIdle=SoundGroup'AIStateDialogueGroups.AIStateMerc.AIStateMercIdles'
     sndNotice=SoundGroup'AIStateDialogueGroups.AIStateMerc.AIStateMercAlert'
     sndLost=SoundGroup'AIStateDialogueGroups.AIStateMerc.AIStateMercLost'
     sndAttacking=SoundGroup'AIStateDialogueGroups.AIStateMerc.AIStateMercCombat'
     sndFriendlyFire=SoundGroup'AIStateDialogueGroups.AIStateMerc.AIStateMercFriendly'
     sndKilledEnemy=SoundGroup'AIStateDialogueGroups.AIStateMerc.AIStateMercGloat'
}
