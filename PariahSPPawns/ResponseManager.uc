class ResponseManager extends Actor;


#exec OBJ LOAD FILE=PariahPlayerSounds.uax

var AIController ctrl;

enum EResponse
{
    C_Idle,
    C_Bumped,
    C_MasonShootingNothing,
    C_Hiding,
    C_StaredAt,
    C_FriendlyFiredAt,
    C_KillWitnessed,
    C_TakingDamage,
};

struct ResponseType
{
    var Name LSanimName;
    var Name BodyAnimName;
};

struct VocalResponseType
{
    var Name LSanimName;
    var Name BodyAnimName;
    var float weight;
};

struct NonVocalResponseType
{
    var Name BodyAnimName;
    var float weight;
};

//vocal responses
var array<VocalResponseType> VResponses_Idle;
var array<VocalResponseType> VResponses_Bumped;
var array<VocalResponseType> VResponses_MasonShootingNothing;
var array<VocalResponseType> VResponses_Hiding;
var array<VocalResponseType> VResponses_StaredAt;
var array<VocalResponseType> VResponses_FriendlyFiredAt;
var array<VocalResponseType> VResponses_KillWitnessed;
var array<VocalResponseType> VResponses_TakingDamage;
//non vocal responses
var array<NonVocalResponseType> NVResponses_Idle;
var array<NonVocalResponseType> NVResponses_Bumped;
var array<NonVocalResponseType> NVResponses_MasonShootingNothing;
var array<NonVocalResponseType> NVResponses_Hiding;
var array<NonVocalResponseType> NVResponses_StaredAt;
var array<NonVocalResponseType> NVResponses_FriendlyFiredAt;
var array<NonVocalResponseType> NVResponses_KillWitnessed;
var array<NonVocalResponseType> NVResponses_TakingDamage;

var float       OddsOfVocalResponse[8];
var Name        LastResponseAnim;
var EResponse   LastResponseType;
var  float      LastResponseTime;
var  float      LastResponseTypeTime[8];
var  float      LastVocalResponseTypeTime[8];

function Init(AIController c)
{
    ctrl = c;
}

function array<VocalResponseType> getVocalResponseArray(EResponse type)
{
    switch(type)
    {
        case C_Idle:
            return VResponses_Idle;
        case C_Bumped:
            return VResponses_Bumped;
        case C_MasonShootingNothing:
            return VResponses_MasonShootingNothing;
        case C_Hiding:
            return VResponses_Hiding;
        case C_StaredAt:
            return VResponses_StaredAt;
        case C_FriendlyFiredAt:
            return VResponses_FriendlyFiredAt;
        case C_KillWitnessed:
            return VResponses_KillWitnessed;
        case C_TakingDamage:
            return VResponses_TakingDamage;
    }
}
function array<NonVocalResponseType> getnonVocalResponseArray(EResponse type)
{
    switch(type)
    {
        case C_Idle:
            return NVResponses_Idle;
        case C_Bumped:
            return NVResponses_Bumped;
        case C_MasonShootingNothing:
            return NVResponses_MasonShootingNothing;
        case C_Hiding:
            return NVResponses_Hiding;
        case C_StaredAt:
            return NVResponses_StaredAt;
        case C_FriendlyFiredAt:
            return NVResponses_FriendlyFiredAt;
        case C_KillWitnessed:
            return NVResponses_KillWitnessed;
        case C_TakingDamage:
            return NVResponses_TakingDamage;
    }
}

function ResponseType chooseVocalResponse(EResponse type)
{
    local int i;
    local float count;
    local VocalResponseType chosen;
    local array<VocalResponseType> vResponses;
    local ResponseType returnResp;

    vResponses = getVocalResponseArray(type);

    count = 0;
    for(i = 0; i< vResponses.Length; i++)
    {
        if( LastResponseAnim == vResponses[i].LSanimName)
            continue;
        count+=1;
        if( Frand() < 1.0/count )
            chosen = vResponses[i];
    }

    returnResp.LSanimName = chosen.LSanimName;
    returnResp.BodyAnimName = chosen.BodyAnimName;
    return returnResp;
}

function ResponseType chooseNonVocalResponse(EResponse type)
{
    local int i;
    local float count;
    local NonVocalResponseType chosen;
    local array<NonVocalResponseType> nvResponses;
    local ResponseType returnResp;

    nvResponses = getNonVocalResponseArray(type);

    count = 0;
    for(i = 0; i< nvResponses.Length; i++)
    {
        count+=1;
        if( Frand() < 1.0/count )
            chosen = nvResponses[i];
    }

    returnResp.BodyAnimName = chosen.BodyAnimName;
    return returnResp;
}


function ResponseType chooseResponse(EResponse type)
{
    if( (TimeElapsed( LastVocalResponseTypeTime[type], 10) )
        &&(FRand() < OddsOfVocalResponse[type]) ) {
        MarkTime( LastVocalResponseTypeTime[type] );
        return chooseVocalResponse(type);
    }
    else {
        return chooseNonVocalResponse(type);
    }
}

/**
 * chance is the odds of actually playing the Response
 * and interval is the time between saying the same thing
 **/
function bool CreateResponse(EResponse type, out ResponseType outResponse, optional float chance, optional float interval)
{
    local ResponseType Response;

    if( chance > 0.0 && Frand() > chance) {
        log( "Chance Exit:"@ ResponseToString(type) );
        return false;
    }

    if(interval > 0.0 && !TimeElapsed( LastResponseTypeTime[type], interval ) ) {
        log( "Interval Exit:"@ ResponseToString(type) );
        return false;
    }
    if( ctrl.Pawn.IsPlayingLIPSincAnim() ) {
        log("Playing Exit:"@ ResponseToString(type));
        return false;
    }

    //if( !TimeElapsed(LastResponseTime, 5.0) )
    //{    return;
    //}

    Response = chooseResponse(type);

    MarkTime( LastResponseTime );
    MarkTime( LastResponseTypeTime[type] );
    LastResponseType = type;
    LastResponseAnim = Response.LSanimName;

    outResponse = Response;
    return true;
}


function String ResponseToString(EResponse type)
{
    switch(type)
    {
        case C_Idle:
            return "C_Idle";
        case C_Bumped:
            return "C_Bumped";
        case C_MasonShootingNothing:
            return "C_MasonShootingNothing";
        case C_Hiding:
            return "C_Hiding";
        case C_StaredAt:
            return "C_StaredAt";
        case C_FriendlyFiredAt:
            return "C_FriendlyFiredAt";
        case C_KillWitnessed:
            return "C_KillWitnessed";
        case C_TakingDamage:
            return "C_TakingDamage";
    }
}

defaultproperties
{
     OddsOfVocalResponse(0)=0.250000
     OddsOfVocalResponse(1)=0.200000
     OddsOfVocalResponse(2)=0.500000
     OddsOfVocalResponse(3)=1.000000
     OddsOfVocalResponse(4)=0.100000
     OddsOfVocalResponse(5)=0.250000
     OddsOfVocalResponse(6)=1.000000
     OddsOfVocalResponse(7)=1.000000
     VResponses_Idle(0)=(LSanimName="KARINA_GEN_01",Weight=0.100000)
     VResponses_Idle(1)=(LSanimName="KARINA_GEN_03",Weight=0.100000)
     VResponses_Idle(2)=(LSanimName="KARINA_GEN_04",Weight=0.100000)
     VResponses_Idle(3)=(LSanimName="KARINA_GEN_05",Weight=0.100000)
     VResponses_Idle(4)=(LSanimName="KARINA_GEN_06",Weight=0.300000)
     VResponses_Idle(5)=(LSanimName="KARINA_GEN_07",Weight=0.100000)
     VResponses_Idle(6)=(LSanimName="KARINA_GEN_08",Weight=0.100000)
     VResponses_Bumped(0)=(LSanimName="KARINA_GEN_09",Weight=0.200000)
     VResponses_Bumped(1)=(LSanimName="KARINA_GEN_10",Weight=0.200000)
     VResponses_Bumped(2)=(LSanimName="KARINA_GEN_11",Weight=0.150000)
     VResponses_Bumped(3)=(LSanimName="KARINA_GEN_12",Weight=0.200000)
     VResponses_Bumped(4)=(LSanimName="KARINA_GEN_13",Weight=0.200000)
     VResponses_Bumped(5)=(LSanimName="KARINA_GEN_15",Weight=0.050000)
     VResponses_MasonShootingNothing(0)=(LSanimName="KARINA_GEN_16",Weight=0.500000)
     VResponses_MasonShootingNothing(1)=(LSanimName="KARINA_GEN_17",Weight=0.200000)
     VResponses_MasonShootingNothing(2)=(LSanimName="KARINA_GEN_18",Weight=0.100000)
     VResponses_MasonShootingNothing(3)=(LSanimName="KARINA_GEN_19",Weight=0.100000)
     VResponses_MasonShootingNothing(4)=(LSanimName="KARINA_GEN_20",Weight=0.100000)
     VResponses_Hiding(0)=(LSanimName="KARINA_GEN_21")
     VResponses_Hiding(1)=(LSanimName="KARINA_GEN_22")
     VResponses_Hiding(2)=(LSanimName="KARINA_GEN_24")
     VResponses_StaredAt(0)=(LSanimName="KARINA_GEN_26")
     VResponses_StaredAt(1)=(LSanimName="KARINA_GEN_27")
     VResponses_StaredAt(2)=(LSanimName="KARINA_GEN_28")
     VResponses_StaredAt(3)=(LSanimName="KARINA_GEN_29")
     VResponses_FriendlyFiredAt(0)=(LSanimName="KARINA_GEN_30",Weight=0.200000)
     VResponses_FriendlyFiredAt(1)=(LSanimName="KARINA_GEN_31",Weight=0.200000)
     VResponses_FriendlyFiredAt(2)=(LSanimName="KARINA_GEN_32",Weight=0.200000)
     VResponses_FriendlyFiredAt(3)=(LSanimName="KARINA_GEN_33",Weight=0.200000)
     VResponses_FriendlyFiredAt(4)=(LSanimName="KARINA_GEN_34",Weight=0.200000)
     VResponses_KillWitnessed(0)=(LSanimName="KARINA_GEN_35")
     VResponses_KillWitnessed(1)=(LSanimName="KARINA_GEN_36")
     VResponses_KillWitnessed(2)=(LSanimName="KARINA_GEN_37")
     VResponses_KillWitnessed(3)=(LSanimName="KARINA_GEN_38")
     VResponses_KillWitnessed(4)=(LSanimName="KARINA_GEN_39")
     VResponses_KillWitnessed(5)=(LSanimName="KARINA_GEN_40")
     VResponses_KillWitnessed(6)=(LSanimName="KARINA_GEN_41")
     VResponses_TakingDamage(0)=(LSanimName="KARINA_GEN_47")
     VResponses_TakingDamage(1)=(LSanimName="KARINA_GEN_48")
     VResponses_TakingDamage(2)=(LSanimName="KARINA_GEN_49")
     VResponses_TakingDamage(3)=(LSanimName="KARINA_GEN_50")
     NVResponses_Idle(0)=(Weight=0.500000)
     NVResponses_Idle(1)=(Weight=0.500000)
     NVResponses_Idle(2)=(Weight=0.500000)
     NVResponses_Idle(3)=(Weight=0.500000)
     NVResponses_Idle(4)=(BodyAnimName="IdleStretch",Weight=0.500000)
     NVResponses_Idle(5)=(Weight=0.500000)
     NVResponses_Bumped(0)=(BodyAnimName=")",Weight=0.300000)
     NVResponses_Bumped(1)=(BodyAnimName=")",Weight=0.700000)
     NVResponses_MasonShootingNothing(0)=(BodyAnimName="IdleAlert",Weight=0.500000)
     NVResponses_MasonShootingNothing(1)=(Weight=0.500000)
     NVResponses_StaredAt(0)=(Weight=0.700000)
     NVResponses_StaredAt(1)=(Weight=0.130000)
     NVResponses_StaredAt(2)=(Weight=0.130000)
     NVResponses_StaredAt(3)=(Weight=0.040000)
     NVResponses_FriendlyFiredAt(0)=(BodyAnimName=")",Weight=1.000000)
     bHidden=True
}
