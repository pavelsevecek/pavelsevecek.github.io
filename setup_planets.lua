require("math")
 
function generate()
    local counter = 1;
    for i = 1,10
    do
        for j = 1,10
        do
		    -- Create Earth
            earth = newObject("Earth");
            earth.name = "planet " .. counter;
			-- Adjust the parameters
            earth.position = { i * 1.2e7, j * 1.2e7, 0};
            earth.radius = 5e6 * i / 10;
            earth.surface_temperature = (j - 1) * 500;
            earth.deformable = false;
			
			-- Add the planet to the simulation
            addObject(earth);
			
			counter = counter + 1;
        end
    end
end