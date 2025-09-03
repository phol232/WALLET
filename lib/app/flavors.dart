enum Flavor {
  dev,
  stg,
  prod,
}

extension FlavorExtension on Flavor {
  String get name {
    switch (this) {
      case Flavor.dev:
        return 'dev';
      case Flavor.stg:
        return 'stg';
      case Flavor.prod:
        return 'prod';
    }
  }

  String get title {
    switch (this) {
      case Flavor.dev:
        return 'Mart Wallet (Dev)';
      case Flavor.stg:
        return 'Mart Wallet (Staging)';
      case Flavor.prod:
        return 'Mart Wallet';
    }
  }

  bool get isDev => this == Flavor.dev;
  bool get isStg => this == Flavor.stg;
  bool get isProd => this == Flavor.prod;
}

class FlavorConfig {
  static Flavor? _flavor;

  static Flavor get flavor {
    if (_flavor == null) {
      throw Exception('Flavor not initialized');
    }
    return _flavor!;
  }

  static void setFlavor(Flavor flavor) {
    _flavor = flavor;
  }
}
