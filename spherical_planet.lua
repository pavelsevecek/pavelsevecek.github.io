require("math")

-- Name of this object. This will be the label of the button added to 'Custom objects'.
objectName = "Spherical planet";

-- Table of object parameters that will be shown in the UI.
parameters = {}

parameters.radius = Constants.R_Earth;
parameters.density = 5000;

-- Returns the total volume of the object. This function is used to determine 
-- how many particles are assigned to the object.
function getVolume()
    return 4.0 / 3.0 * math.pi * math.pow(parameters.radius, 3);
end

-- Returns the total mass of the object.
function getTotalMass()
    return getVolume() * parameters.density;
end

local function dot(v1, v2)
    return v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3];
end

local function cross(v1, v2)
    return { v1[2] * v2[3] - v1[3] * v2[2],
             v1[3] * v2[1] - v1[1] * v2[3],
             v1[1] * v2[2] - v1[2] * v2[1] };
end

local function cartesian(r, theta, phi)
    local s = math.sin(theta);
    local c = math.cos(theta);
    return { r * s * math.cos(phi), r * s * math.sin(phi), r * c };
end

local function spherical(v)
    local r = math.sqrt(dot(v, v));
    local phi = math.atan(v[2], v[1]);
    local theta = 0;
    if r > 0 then
        theta = math.acos(v[3] / r);
    end
    return { r, theta, phi };
end

local function normalize(v)
    local l = math.sqrt(dot(v, v));
    return { v[1] / l, v[2] / l, v[3] / l };
end

local function setLength(v, a)
	local u = normalize(v);
    return { u[1] * a, u[2] * a, u[3] * a };
end

-- Main entry point of the script. The function will create a table containing 
-- all particle data of the object.
function generate(n)
    state = {}
    state.position = {};
    state.velocity = {};
    state.mass = {};
    state.density = {};
    state.radius = {};
    state.color = {};
    state.normal = {};
    state.uv = {};
    state.du_dxyz = {};
    state.dv_dxyz = {};

    local radius = parameters.radius;
    local volume = getVolume();
    local mass = getTotalMass();

    local h = math.pow(volume / n, 0.333333333);
    local eta = 1.3;

    local shell_count = math.floor(radius / h);
    local shells = {};
    local total = 0;
    for i = 1, shell_count
    do
        shells[i] = i * i;
        total = total + shells[i];
    end

    local normalization = n / total;
    for i = 1, shell_count
    do
        shells[i] = shells[i] * normalization;
    end

    local h_radial = radius / shell_count;
  
    local index = 1;
    for i = 1, shell_count
    do
        local r = i * h_radial;
        local m = math.ceil(shells[i]);
        local phi = 0;
        for k = 1, m - 1
        do
            local hk = -1 + 2 * k / m;
            local theta = math.acos(hk);
            phi = phi + 3.8 / math.sqrt(m * (1 - hk * hk));
            if phi > math.pi
            then
                phi = phi - 2 * math.pi
            end
            local v = cartesian(r, theta, phi);

            state.position[index] = v;
            state.velocity[index] = { 0, 0, 0};
            state.radius[index] = h * eta;
            state.mass[index] = mass / n;
            state.density[index] = parameters.density;
            state.color[index] = { 0.3, 0.6, 1 };
            
            local n = normalize(v);
            state.normal[index] = n;
            
            state.uv[index] = { 0.5 + phi / (2 * math.pi), theta / math.pi };
            local up = {0, 0, 1};
            local du = setLength(cross(up, n), 1 / radius);
            local dv = setLength(cross(n, du), 1 / radius);
            state.du_dxyz[index] = du;
            state.dv_dxyz[index] = dv;
            index = index + 1;
        end
    end
    
    return state;
end