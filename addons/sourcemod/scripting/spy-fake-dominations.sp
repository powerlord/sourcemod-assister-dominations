/**
 * vim: set ts=4 :
 * =============================================================================
 * Spy Fake Domination Quotes
 * Description
 *
 * Spy Fake Domination Quotes (C)2014 Powerlord (Ross Bemrose).
 * All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: 1.0
 */
#include <sourcemod>
#include <tf2_stocks>
#include <tf2>
#include <sdktools>

#define VERSION "1.0"

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
	name = "Spy Fake Domination Quotes",
	author = "Powerlord",
	description = "If a Spy fakes his death and a someone \"dominates\" them, play a domination quote",
	version = VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=222455"
}

new Handle:g_Cvar_Enabled;
new Handle:g_Cvar_Assister;

public OnPluginStart()
{
	CreateConVar("spyfakedominationquotes_version", VERSION, "Spy Fake Domination Quotes version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_Cvar_Enabled = CreateConVar("spyfakedominationquotes_enabled", "1", "Enable Spy Fake Domination Quotes?", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	HookEvent("player_death", Event_PlayerDeath);
}

public OnAllPluginsLoaded()
{
	g_Cvar_Assister = FindConVar("assisterdomination_enabled");
}

// In case the plugin is loaded during a map, check on map start.
// Convar handles don't need to be closed, so overwriting is OK
public OnMapStart()
{
	g_Cvar_Assister = FindConVar("assisterdomination_enabled");
}

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (!GetConVarBool(g_Cvar_Enabled))
	{
		return;
	}
	
	new deathflags = GetEventInt(event, "death_flags");
	new bool:silentKill = GetEventBool(event, "silent_kill");
	
	if (silentKill || dontBroadcast || deathflags & TF_DEATHFLAG_DEADRINGER != TF_DEATHFLAG_DEADRINGER)
	{
		return;
	}

	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new assister = GetClientOfUserId(GetEventInt(event, "assister"));
	
	if (victim < 1 || victim > MaxClients)
	{
		return;
	}

	// The class check is here for Randomizer support... in case it supports cloaking devices/disguise kits (I forget if it does)
	new TFClassType:victimClass = TF2_GetPlayerClass(victim);
	
	if (victimClass == TFClass_Spy && TF2_IsPlayerInCondition(victim, TFCond_Disguised))
	{
		new team = GetClientTeam(victim);
		new disguiseTeam = GetEntProp(victim, Prop_Send, "m_nDisguiseTeam");
		if (team == disguiseTeam)
		{
			victimClass = TFClassType:GetEntProp(victim, Prop_Send, "m_nDisguiseClass");
		}
	}
	
	if (deathflags & TF_DEATHFLAG_KILLERDOMINATION)
	{
		if (CheckAttacker(attacker))
		{
			PlayDominationSound(attacker, victimClass);
		}
	}
	else if (deathflags & TF_DEATHFLAG_KILLERREVENGE)
	{
		if (CheckAttacker(attacker))
		{
			PlayDominationSound(attacker, victimClass, true);
		}
	}
	
	if (g_Cvar_Assister != INVALID_HANDLE && GetConVarBool(g_Cvar_Assister))
	{
		if (deathflags & TF_DEATHFLAG_ASSISTERDOMINATION)
		{
			if (CheckAttacker(assister))
			{
				PlayDominationSound(assister, victimClass);
			}
		}
		else if (deathflags & TF_DEATHFLAG_ASSISTERREVENGE)
		{
			if (CheckAttacker(assister))
			{
				PlayDominationSound(assister, victimClass, true);
			}
		}
	}
}

bool:CheckAttacker(client)
{
	if (client < 1 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client) ||
	TF2_IsPlayerInCondition(client, TFCond_Cloaked) || TF2_IsPlayerInCondition(client, TFCond_Disguised) || 
	TF2_IsPlayerInCondition(client, TFCond_CloakFlicker))
	{
		return false;
	}
	
	return true;
}

PlayDominationSound(client, TFClassType:victimClass, bool:revenge=false)
{
	if (revenge)
	{
		SetVariantString("domination:revenge");
	}
	else
	{
		SetVariantString("domination:dominated");
	}
	
	AcceptEntityInput(client, "AddContext");

	new String:victimClassContext[64];
	Format(victimClassContext, sizeof(victimClassContext), "victimclass:%s", g_ClassNames[victimClass]);
	
	SetVariantString(victimClassContext);
	AcceptEntityInput(client, "AddContext");
	
	SetVariantString("TLK_KILLED_PLAYER");
	AcceptEntityInput(client, "SpeakResponseConcept");
	
	AcceptEntityInput(client, "ClearContext");
}