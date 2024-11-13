Config = {}
Config.DisableStress = false      -- If true will disable stress completely for all players
Config.StressChance = 0.1         -- Default: 10% -- Percentage Stress Chance When Shooting (0-1)
Config.MinimumStress = 50         -- Minimum Stress Level For Screen Shaking
Config.MinimumSpeedUnbuckled = 50 -- Going Over This Speed Unbuckled Will Cause Stress
Config.MinimumSpeed = 100         -- Going Over This Speed While Buckled Will Cause Stress

Config.WhitelistedJobs = { -- Disable stress completely for players with matching job or job type
    ['police'] = true,
    ['ambulance'] = true
}

Config.Intensity = {
    ['blur'] = {
        [1] = {
            min = 50,
            max = 60,
            intensity = 1500,
        },
        [2] = {
            min = 60,
            max = 70,
            intensity = 2000,
        },
        [3] = {
            min = 70,
            max = 80,
            intensity = 2500,
        },
        [4] = {
            min = 80,
            max = 90,
            intensity = 2700,
        },
        [5] = {
            min = 90,
            max = 100,
            intensity = 3000,
        },
    }
}

Config.EffectInterval = {
    [1] = {
        min = 50,
        max = 60,
        timeout = math.random(50000, 60000)
    },
    [2] = {
        min = 60,
        max = 70,
        timeout = math.random(40000, 50000)
    },
    [3] = {
        min = 70,
        max = 80,
        timeout = math.random(30000, 40000)
    },
    [4] = {
        min = 80,
        max = 90,
        timeout = math.random(20000, 30000)
    },
    [5] = {
        min = 90,
        max = 100,
        timeout = math.random(15000, 20000)
    }
}

Config.WhitelistedWeaponStress = { -- Disable gaining stress from weapons in this table
    [`weapon_petrolcan`] = true,
    [`weapon_hazardcan`] = true,
    [`weapon_fireextinguisher`] = true
}

Config.VehClassStress = {
    ['0'] = true,         -- Compacts
    ['1'] = true,         -- Sedans
    ['2'] = true,         -- SUVs
    ['3'] = true,         -- Coupes
    ['4'] = true,         -- Muscle
    ['5'] = true,         -- Sports Classics
    ['6'] = true,         -- Sports
    ['7'] = true,         -- Super
    ['8'] = true,         -- Motorcycles
    ['9'] = true,         -- Off Road
    ['10'] = true,        -- Industrial
    ['11'] = true,        -- Utility
    ['12'] = true,        -- Vans
    ['13'] = false,       -- Cycles
    ['14'] = false,       -- Boats
    ['15'] = false,       -- Helicopters
    ['16'] = false,       -- Planes
    ['18'] = false,       -- Emergency
    ['19'] = false,       -- Military
    ['20'] = false,       -- Commercial
    ['21'] = false        -- Trains
}

Config.WhitelistedVehicles = { -- Disable gaining stress from speeding in any vehicle in this table
    --[`adder`] = true
}