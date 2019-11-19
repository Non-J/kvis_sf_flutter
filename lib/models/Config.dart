final defaultConfig = <String, dynamic>{
  'scheduleUpcomingEventsDisplayHours': 2,
  'scheduleDayOffsetTime': 1579021200000,
};

class ConfigService {
  Map<String, dynamic> config;

  ConfigService._();

  static ConfigService init() {
    ConfigService newConfigService = ConfigService._();
    newConfigService.config = defaultConfig;
    return newConfigService;
  }

  void setValue(String key, dynamic value) {
    this.config[key] = value;
  }

  dynamic getValue(String key) {
    return this.config[key];
  }
}

final ConfigService configService = ConfigService.init();
