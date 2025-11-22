require("math")

-- Simple system that explodes the largest object in the simulation.

-- Initialize all quantities used by the script.
-- These quantities will be updated by the simulation every time the script is run.
-- All quantities are in SI units (meters, kilograms, Kelvins, ...).
-- For the list of available quantities, see https://pavelsevecek.github.io/lua.html
-- This is a mandatory field.
particles = {};
particles.mass = {}
particles.position = {}
particles.velocity = {}
particles.island_index = {}
particles.temperature = {}

-- Names of all quantities changed by the script.
-- These quantities are copied back to the simulation after the script returns.
-- This is a mandatory field.
update_quantities = {"velocity", "temperature" }; 

-- Optional parameters of the system.
-- The parameters can be changed in the simulation settings after compiling the script.
parameters = {}
parameters.explosion_velocity = 0.005;
parameters.heating = 2000;

-- Main entry point of the script.

-- Called with period set in the simulation settings. If the period is 0,
-- the function is called every time step.
-- Parameters:
-- t - Current simulation time (in seconds)
-- dt - Current time step (in seconds);
function onTimeStep(t, dt)
	local island_counts = {};
	for i = 1, #particles.island_index
	do
		local island = particles.island_index[i];
		if island_counts[island] == nil then
			island_counts[island] = 1;
		else
			island_counts[island] = island_counts[island] + 1;
		end
	end
	local largest_island = 0;
	local max_count = 0;
	for island, count in pairs(island_counts) do
		if count > max_count then
			largest_island = island;
			max_count = count;
		end
	end
	
	local x_com = 0;
	local y_com = 0;
	local z_com = 0;
	local mass = 0;
	for i = 1, #particles.island_index
	do
		if particles.island_index[i] == largest_island then
			local m = particles.mass[i];
			local r = particles.position[i];
			x_com = x_com + m * r[1];
			y_com = y_com + m * r[2];
			z_com = z_com + m * r[3];
			mass = mass + m;
		end
	end
	x_com = x_com / mass;
	y_com = y_com / mass;
	z_com = z_com / mass;
	local v = parameters.explosion_velocity;
	for i = 1, #particles.island_index
	do
		if particles.island_index[i] == largest_island then
			local r = particles.position[i];
			particles.velocity[i] = { (r[1] - x_com) * v, (r[2] - y_com) * v, (r[3] - z_com) * v };
			particles.temperature[i] = particles.temperature[i] + parameters.heating;
		end
	end
end