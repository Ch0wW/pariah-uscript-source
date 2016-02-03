class MasterServerClient extends ServerQueryClient
	native;

// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)
// (cpptext)

enum EClientToMaster
{
	CTM_Query,
	CTM_GetMOTD,
	CTM_QueryUpgrade,
};

enum EQueryType
{
	QT_Equals,
	QT_NotEquals,
	QT_LessThan,
	QT_LessThanEquals,
	QT_GreaterThan,
	QT_GreaterThanEquals,
};

struct native export QueryData
{
	var() string Key;
	var() string Value;
	var() EQueryType QueryType;
};

enum EResponseInfo
{
	RI_AuthenticationFailed,
	RI_ConnectionFailed,
	RI_ConnectionTimeout,
	RI_Success,	
	RI_MustUpgrade,
};

enum EMOTDResponse
{
	MR_MOTD,
	MR_MandatoryUpgrade,
	MR_OptionalUpgrade,
	MR_NewServer,
	MR_IniSetting,
	MR_Command,
	MR_UpgradeURL
};

struct MOTDResponse
{
    var() EMOTDResponse		MR;
    var() String			Value;
};

// Internal
var native const int MSLinkPtr;

var(Query) array<QueryData> Query;
var(Query) const int ResultCount;

native function StartQuery( EClientToMaster Command );
native function Stop();
native static function LaunchAutoUpdate();
native static function bool MOTDQuerySent();		// returns true if a CTM_GetMOTD query has been sent this session
native static function bool DownloadListValid();	// returns true if a valid downlist has been created this session

delegate OnQueryFinished( EResponseInfo ResponseInfo, int Info );
delegate OnReceivedServer( GameInfo.ServerResponseLine s );
delegate OnReceivedMOTDData( EMOTDResponse Command, string Value );

defaultproperties
{
}
