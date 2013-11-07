### dev

[full changelog](http://github.com/yolk/pump/compare/v0.6.3...master)

### 0.6.3 / 2013-07-26

[full changelog](http://github.com/yolk/valvat/compare/v0.6.2...v0.6.3)

* Pump::Xml allow partial output with :fields option
* Pump::JSON allow partial output with :fields option

### 0.6.2 / 2013-07-26

[full changelog](http://github.com/yolk/valvat/compare/v0.6.1...v0.6.2)

* Pump::Encoder now forces loading of ActiveRecord::Relation to detect array
* Format times correctly with OJ options alone (does not rely on activesupports to_json)

### 0.6.1 / 2013-07-25

[full changelog](http://github.com/yolk/valvat/compare/v0.6.0...v0.6.1)

* Fixed issues with time/date objects in JSON
* XML defaults now to dasherized key names, JSON to underscores
* Added :xml_key_style & :json_key_style options

### 0.6.0 / 2013-07-24

[full changelog](http://github.com/yolk/valvat/compare/v0.5.1...v0.6.0)

* Added JSON serialization
* Added simple inheritance for encoders