# Pump

Fast but inflexible XML encoding for ruby objects.

## Quick benchmark

Serializing an array of 100 random entries 1.000 times.

                                   user     system      total        real
Pump::Xml#encode               1.450000   0.010000   1.460000 (  1.466962)
Pump::Xml#encode (optimized)   1.100000   0.010000   1.110000 (  1.110234)
Ox                             1.490000   0.000000   1.490000 (  1.483275)
ActiveModel#serialize         23.280000   0.060000  23.340000 ( 23.333999)
