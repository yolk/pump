# Pump

[![Build Status](https://travis-ci.org/yolk/pump.png?branch=master)](https://travis-ci.org/yolk/pump)

Fast but inflexible XML and JSON encoding for ruby objects.

## Quick benchmark

Serializing an array of 100 random entries 1.000 times.

                                   user     system      total        real
    Pump::Json#encode              0.600000   0.010000   0.610000 (  0.603469)
    Pump::Xml#encode               1.140000   0.020000   1.160000 (  1.162651)
    Pump::Xml#encode (optimized)   0.830000   0.020000   0.850000 (  0.858750)
    Ox                             1.200000   0.010000   1.210000 (  1.203765)
    Oj                             0.560000   0.000000   0.560000 (  0.566166)
    Yajl                           1.490000   0.000000   1.490000 (  1.493032)
    ActiveModel#to_xml            24.110000   0.050000  24.160000 ( 24.170127)
    ActiveModel#to_json            3.860000   0.010000   3.870000 (  3.866130)
