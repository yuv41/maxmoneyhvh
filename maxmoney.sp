#pragma semicolon 1

#include <sdktools>

#define PLUGIN_VERSION	"1.0.1"

public Plugin:myinfo = 
{
	name = "Max Money",
	author = "RedSword edited by yuv",
	description = "",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
};

#define MAX_CASH 16000
#define STR_ACCOUNT_PROP "m_iAccount"

//ConVars
new Handle:g_hMaxMoney;
new Handle:g_hMaxMoney_value;
new Handle:g_hMaxMoney_value_respect16k;
new Handle:g_hMaxRounds;

//Caching
new g_iMaxMoney;
new g_iMaxMoney_value;
new bool:g_bMaxMoney_value_respect16k;
new g_iPistolRound;

//===== Forwards

public OnPluginStart()
{
	//CVars
	CreateConVar( "maxmoneyafterxroundsversion",
	PLUGIN_VERSION, 
	"Different Teams Start Money/Cash version", 
	FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD );
	
	g_hMaxMoney = CreateConVar( "sm_maxmoney",
	"2", 
	"A which round should the players get extra cash upon spawning ? 0=disable plugin, 1=pistol round, 2=after pistol round (default).", 
		FCVAR_PLUGIN | FCVAR_NOTIFY, true, 0.0 );
	
	g_hMaxMoney_value = CreateConVar( "sm_maxmoney_value",
	"16000", 
	"How much to add to the player's money per round when he spawns, after <sm_maxmoney> rounds. Def. 16000.", 
		FCVAR_PLUGIN | FCVAR_NOTIFY, true, 0.0 );
	g_hMaxMoney_value_respect16k = CreateConVar( "sm_maxmoney_value_16k",
	"1", 
	"Respect 16k limit (if unsure, let '1') ?", 
		FCVAR_PLUGIN | FCVAR_NOTIFY, true, 0.0, true, 1.0 );
	
	g_hMaxRounds = FindConVar( "mp_maxrounds" );
	
	AutoExecConfig(true, "maxmoneyafterxrounds");
	
	//Hooks event
	HookEvent( "player_spawn", Event_PlayerSpawn );
	
	//Hooks ConVarChanges (caching)
	g_iMaxMoney = GetConVarInt( g_hMaxMoney );
	g_iMaxMoney_value = GetConVarInt( g_hMaxMoney_value );
	g_bMaxMoney_value_respect16k = GetConVarBool( g_hMaxMoney_value_respect16k );
	g_iPistolRound = RoundToCeil( GetConVarInt( g_hMaxRounds ) / 2.0 );

	HookConVarChange( g_hMaxMoney, ConVarChange_MaxMoney );
	HookConVarChange( g_hMaxMoney_value, ConVarChange_MaxMoney_value );
	HookConVarChange( g_hMaxMoney_value_respect16k, ConVarChange_MaxMoney_value_16k );
	HookConVarChange( g_hMaxRounds, ConVarChange_MaxRounds );
}

//===== Events

public Action:Event_PlayerSpawn( Handle:event, const String:name[], bool:dontBroadcast )
{
	if ( g_iMaxMoney > 0 )
	{
		new iRound = GameRules_GetProp("m_totalRoundsPlayed");
		if ( g_iMaxMoney == 1 || (iRound != 0 && iRound != g_iPistolRound ) )
		{
			new iClient = GetClientOfUserId( GetEventInt( event, "userid" ) );
			if ( iClient && IsClientInGame( iClient ) )
			{
				new shouldHaveCash = GetEntProp( iClient, Prop_Send, STR_ACCOUNT_PROP ) + g_iMaxMoney_value;
				if ( shouldHaveCash > MAX_CASH && g_bMaxMoney_value_respect16k)
				{
					shouldHaveCash = MAX_CASH;
				}
				SetEntProp( iClient, Prop_Send, STR_ACCOUNT_PROP, shouldHaveCash);

			}
		}
	}
	
	return Action:Plugin_Continue;
}

//===== ConVarChanges

public ConVarChange_MaxMoney(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_iMaxMoney = GetConVarInt( g_hMaxMoney );
}
public ConVarChange_MaxMoney_value(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_iMaxMoney_value = GetConVarInt( g_hMaxMoney_value );
}
public ConVarChange_MaxMoney_value_16k(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_bMaxMoney_value_respect16k = GetConVarBool( g_hMaxMoney_value_respect16k );
}
public ConVarChange_MaxRounds(Handle:convar, const String:oldValue[], const String:newValue[])
{
	g_iPistolRound = RoundToCeil( GetConVarInt( g_hMaxRounds ) / 2.0 );
}
