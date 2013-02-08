# Pump

Fast but inflexible XML encoding for ruby objects.

## Quick benchmark

Serializing an array of 100 random entries 1.000 times.

                                      user     system      total        real
    Pump::Xml#encode                  1.560000   0.020000   1.580000 (  1.581375)
    Pump::Xml#encode (optimized)      1.060000   0.010000   1.070000 (  1.067321)
    Ox                                1.470000   0.000000   1.470000 (  1.467247)
    ActiveModel#serialize            22.840000   0.040000  22.880000 ( 22.871247)
