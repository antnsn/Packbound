-- Every plain-word explanation in one place (tooltips show them while "Explain things" is on).
local _, ns = ...
if ns.disabled then return end

ns.Help = {
	callPet = "Your pet fights with you and takes hits for you. Call it whenever it isn't out.",
	revivePet = "Your pet has died. Revive Pet brings it back (it costs mana and takes a few seconds).",
	feedPet = "A hungry pet does less damage and can even run away. Feeding it food it likes makes it happy again.",
	noFood = "Your pet eats only some kinds of food (meat, fish, bread, fruit...). Keep some in your bags.",
	ammo = "Your bow or gun needs arrows or bullets in the ammo slot. Buy more from a general goods or weapon vendor. The card names the nearest one; click it for a waypoint (or type /pack ammo).",
	ammoVendor = "The nearest vendor who sells your kind of ammo: arrows for a bow or crossbow, bullets for a gun. Packbound knows the ones in towns, and remembers every ammo vendor you open.",
	aspect = "An aspect is a stance for hunters: Aspect of the Hawk gives ranged attack power, Monkey dodge. Keep one on while you hunt.",
	trueshot = "Trueshot Aura gives you and your group more attack power. Keep it up.",
	cheetah = "Aspect of the Cheetah makes you run faster, but you are dazed when something hits you. For travel only.",
	pack = "Aspect of the Pack makes your whole group run faster, with the same daze. For travel only.",
	hearthstone = "Your Hearthstone takes you back to the inn you set it to. Talk to an innkeeper to change it.",
}
