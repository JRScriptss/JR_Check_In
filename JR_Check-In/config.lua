Config = {}

-- Check-in locations
Config.CheckInLocations = {
    vector3(312.38, -593.29, 43.26), -- Example location (Pillbox)
    vector3(1839.6, 3672.93, 34.27) -- Example location (Sandy Shores)
}

-- Bed locations (Multiple beds, players will be assigned to the first free one)
Config.BedLocations = {
    vector4(317.63, -585.46, 44.20, 333.06),
    vector4(317.63, -585.46, 44.20, 333.06),
    vector4(317.63, -585.46, 44.20, 333.06)
}

-- Check-in cost
Config.CheckInFee = 500
Config.PaymentMethod = "cash" -- Options: "cash" or "bank"

-- Progress bar settings
Config.CheckInDuration = 5000 -- 5 seconds check-in progress
Config.HealDuration = 10000 -- 10 seconds healing progress
