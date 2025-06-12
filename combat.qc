
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;

void() monster_death_use;

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*
============
Killed
============
*/
void(entity attacker) Killed =
{
// why the fuck wasn't this only for the player before
	if (self.health < -99 && (self.flags & FL_CLIENT))
		self.health = -99;		// don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		return;
	}

	self.enemy = attacker;
	
// bump the monster counter
	if ((self.flags & FL_MONSTER) && !(self.deadflag & DEAD_DEAD) )
	{
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}

	ClientObituary(self, attacker);
	
	if(!(self.flags & FL_MONSTER) )
	{
		self.touch = SUB_Null;
		self.takedamage = DAMAGE_NO;
	}

	monster_death_use();
	self.th_die ();
};

void M_React (entity attacker) // q2 port
{	
	if (!(attacker.flags & FL_MONSTER) && !(attacker.flags & FL_CLIENT))
		return;
		
	if (self.flags & FL_TORTURED)
		return;
	
	if (self == attacker && attacker == self.enemy)
		return;
		
	// if attacker is a client, get mad at them because he's good and we're not
	if (attacker.flags & FL_CLIENT)
	{
		if ((self.enemy.flags & FL_CLIENT) && self.enemy)
		{
			if(visible(self, self.enemy))
			{
				self.oldenemy = attacker;
				return;
			}
			self.oldenemy = self.enemy;
		}
		self.enemy = attacker;
		FoundTarget();
		return;
	}

	// get mad unless of the same class (except for soldiers)
	if ( (self.classname != attacker.classname) 
		|| (self.classname == "monster_army" )
		|| (self.classname == "monster_enforcer" ) )
	{
		if (self.enemy.flags & FL_CLIENT)
			self.oldenemy = self.enemy;

		self.enemy = attacker;
		FoundTarget ();
	} 
	else if (attacker.enemy == self) // if they *meant* to shoot us, then shoot back
	{
		if (self.enemy.flags & FL_CLIENT)
			self.oldenemy = self.enemy;

		self.enemy = attacker;
		FoundTarget ();
	}
	else if (attacker.enemy && attacker.enemy != self) // otherwise get mad at whoever they are mad at (help our buddy) unless it is us!
	{
		if ((self.enemy.flags & FL_CLIENT) && self.enemy)
			self.oldenemy = self.enemy;
		self.enemy = attacker.enemy;
		FoundTarget ();
	}
}


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void(entity targ, entity inflictor, entity attacker, float damage, float kick) T_Damage=
{
	local	entity	oldself;
	local	float	save;
	local	float	take;

	if (!targ.takedamage)
		return;

// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

// check for quad damage powerup on the attacker
	if (attacker.super_damage_finished > time)
	{
		damage = damage * 4;
		kick = kick * 4;
	}

// save damage based on the target's armor level

	save = ceil(targ.armortype*damage);
	if (save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;	// lost all armor
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}
	
	targ.armorvalue = targ.armorvalue - save;
	take = ceil(damage-save);

// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

	// figure momentum add
	
	if (targ.mass == 0)
		kick = 0;

	else if ((targ.movetype != MOVETYPE_PUSH) && (targ.movetype != MOVETYPE_NONE))
	{
		if(kick > 0)
		{
			local vector dir = ((targ.maxs - targ.mins) * 0.5 + targ.absmin) - ((inflictor.maxs - inflictor.mins) * 0.5 + inflictor.absmin);
			dir = normalize(dir);

			if((checkbottom(targ)) && (targ.flags & FL_MONSTER))
			{
				targ.flags = targ.flags - (targ.flags & FL_ONGROUND);
				targ.velocity_z = targ.velocity_z + vlen(dir* (500.0 * kick / targ.mass ) )*0.3;
			}

			if ((targ.flags & FL_CLIENT) && attacker == targ)
				targ.velocity = targ.velocity + dir* (1600.0 * kick / targ.mass );	
			else
				targ.velocity = targ.velocity + dir* (500.0 * kick / targ.mass );
		}
	}
	
// check for godmode or invincibility
	if (targ.flags & FL_GODMODE)
		return;
	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

// team play damage avoidance
	if ( (teamplay == 1) && (targ.team > 0)&&(targ.team == attacker.team) )
		return;
		
// do the damage
	if(take > 0)
	{	
		if (attacker.classname == "bfg" && targ.classname == "boss2")
			take = floor(take * 2.5);

		targ.health = targ.health - take;
			
		if (targ.health <= 0)
		{		
			oldself = self;
			self = targ;
	
			if(self.classname == "func_breakable")
				self.enemy = inflictor;

			Killed (attacker);
			self = oldself;
			return;
		}
	}

// react to the damage
	oldself = self;
	self = targ;

	if ((self.flags & FL_MONSTER) && attacker != world)
	{
		M_React (attacker);
		
		if(take > 0)
		{
			self.th_pain (attacker, take);
				// nightmare mode monsters don't make pain noises often	
			if (skill == 3)
				self.pain_finished = time + 4 + random()*2;
			else if (skill == 2)
				self.pain_finished = time + 4;
		}
	}

	else if (take > 0 && self.th_pain)
		self.th_pain (attacker, take);
	
	self = oldself;
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float radius, entity ignore) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, radius);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);

				if (points < 0)
					points = 0;

				points = inflictor.dmg - points;

				if (head == attacker)
					points = points * 0.5;

				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{	// baron takes no damage from all explosions

						if ( (head.classname == "monster_shambler" || 
							head.classname == "monster_boss2") && attacker.classname != "bfg")
					
							T_Damage (head, inflictor, attacker, points*0, 0);
						else 
							T_Damage (head, inflictor, attacker, points, points*0.4);
					}
				}
			}
		}
		head = head.chain;
	}
};

