#include <sourcemod>
#include <tf2_stocks>
#include <tf2>
#include <sdktools>

#define VERSION "1.2"

#define LOGFILE "assister-dominations.log"

/*
	TFClass_Unknown = 0,
	TFClass_Scout,
	TFClass_Sniper,
	TFClass_Soldier,
	TFClass_DemoMan,
	TFClass_Medic,
	TFClass_Heavy,
	TFClass_Pyro,
	TFClass_Spy,
	TFClass_Engineer
	*/
new String:g_ClassNames[TFClassType][16] = { "Unknown", "Scout", "Sniper", "Soldier", "Demoman", "Medic", "Heavy", "Pyro", "Spy", "Engineer"};

public Plugin:myinfo = 
{
	name = "Assister Domination Quotes",
	author = "Powerlord",
	description = "Play domination and revenge lines when an assister gets a domination or revenge",
	version = VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=215449"
}

public OnPluginStart()
{
	CreateConVar("assisterdomination_version", VERSION, "Assister Domination Quotes version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	HookEvent("player_death", Event_PlayerDeath);
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new deathflags = GetEventInt(event, "deathflags");
	new bool:silentKill = GetEventBool(event, "silent_kill");
	
	new victimUser = GetEventInt(event, "userid");
	new assisterUser = GetEventInt(event, "assister");
	
	new victim = GetClientOfUserId(victimUser);
//	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new assister = GetClientOfUserId(assisterUser);
	
	if (deathflags & TF_DEATHFLAG_ASSISTERDOMINATION)
	{
		LogToFile(LOGFILE, "Detected assister domination: victim userId: %d, client: %d, assister userid: %d, client %d", victimUser, victim, assisterUser, assister);
	}
	
	if (deathflags & TF_DEATHFLAG_ASSISTERREVENGE)
	{
		LogToFile(LOGFILE, "Detected assister revenger: victim userId: %d, client: %d, assister userid: %d, client %d", victimUser, victim, assisterUser, assister);
	}
	
	if (silentKill || dontBroadcast || deathflags & TF_DEATHFLAG_DEADRINGER)
	{
		return;
	}

	if (victim < 1 || victim > MaxClients || assister < 1 || assister > MaxClients || !IsClientInGame(assister) || !IsPlayerAlive(assister) ||
		TF2_IsPlayerInCondition(assister, TFCond_Cloaked) || TF2_IsPlayerInCondition(assister, TFCond_Disguised))
	{
		return;
	}

	new TFClassType:victimClass = TF2_GetPlayerClass(victim);
	
	if (deathflags & TF_DEATHFLAG_ASSISTERDOMINATION)
	{
		LogToFile(LOGFILE, "Attempting to play Assister Domination for %N for class %s", assister, g_ClassNames[victimClass]);
		
		new String:victimClassContext[64];
		Format(victimClassContext, sizeof(victimClassContext), "victimclass:%s", g_ClassNames[victimClass]);
		
		SetVariantString(victimClassContext);
		AcceptEntityInput(assister, "AddContext");
		
		SetVariantString("domination:dominated");
		AcceptEntityInput(assister, "AddContext");
		
		SetVariantString("TLK_KILLED_PLAYER");
		AcceptEntityInput(assister, "SpeakResponseConcept");
		
		AcceptEntityInput(assister, "ClearContext");
	}
	else if (deathflags & TF_DEATHFLAG_ASSISTERREVENGE)
	{
		LogToFile(LOGFILE, "Attempting to play Assister Revenge for %N for class %s", assister, g_ClassNames[victimClass]);
		
		new String:victimClassContext[64];
		Format(victimClassContext, sizeof(victimClassContext), "victimclass:%s", g_ClassNames[victimClass]);
		
		SetVariantString(victimClassContext);
		AcceptEntityInput(assister, "AddContext");
		
		SetVariantString("domination:revenge");
		AcceptEntityInput(assister, "AddContext");
		
		SetVariantString("TLK_KILLED_PLAYER");
		AcceptEntityInput(assister, "SpeakResponseConcept");
		
		AcceptEntityInput(assister, "ClearContext");
	}

}
