#include <sourcemod>
#include <tf2_stocks>
#include <tf2>
#include <sdktools>

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
	name = "Assister Dominations",
	author = "Powerlord",
	description = "Play domination lines when assister gets a domination",
	version = "1.0",
	url = "<- URL ->"
}

public OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath);
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new deathflags = GetEventInt(event, "deathflags");
	
	if (dontBroadcast || deathflags & TF_DEATHFLAG_DEADRINGER)
	{
		return;
	}

	new victim = GetClientUserId(GetEventInt(event, "userid"));
//	new attacker = GetClientUserId(GetEventInt(event, "attacker"));
	new assister = GetClientUserId(GetEventInt(event, "assister"));
	
	if (victim < 1 || victim > MaxClients || assister < 1 || assister > MaxClients || !IsClientInGame(assister) || !IsPlayerAlive(assister) ||
		TF2_IsPlayerInCondition(assister, TFCond_Cloaked) || TF2_IsPlayerInCondition(assister, TFCond_Disguised))
	{
		return;
	}

	if (deathflags & TF_DEATHFLAG_ASSISTERDOMINATION)
	{
		new TFClassType:victimClass = TF2_GetPlayerClass(victim);
		
		new String:victimClassContext[64];
		Format(victimClassContext, sizeof(victimClassContext), "victimclass:%s", g_ClassNames[victimClass]);
		
		SetVariantString("domination:dominated");
		AcceptEntityInput(assister, "AddContext");
		
		SetVariantString(victimClassContext);
		AcceptEntityInput(assister, "AddContext");
		
		SetVariantString("TLK_KILLED_PLAYER");
		AcceptEntityInput(assister, "SpeakResponseConcept");
		
		AcceptEntityInput(assister, "ClearContext");
	}
	
	if (deathflags & TF_DEATHFLAG_ASSISTERREVENGE)
	{
		SetVariantString("domination:revenge");
		AcceptEntityInput(assister, "AddContext");
		
		SetVariantString("TLK_KILLED_PLAYER");
		AcceptEntityInput(assister, "SpeakResponseConcept");
		
		AcceptEntityInput(assister, "ClearContext");
	}

}
