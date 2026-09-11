import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// Dimension physique d'une unité : seules les unités d'une même dimension
/// peuvent être additionnées (liste de courses).
enum UnitDimension { mass, volume, count }

enum IngredientUnit {
  gram(UnitDimension.mass, 1),
  kilogram(UnitDimension.mass, 1000),
  milliliter(UnitDimension.volume, 1),
  liter(UnitDimension.volume, 1000),
  piece(UnitDimension.count, 1),
  tablespoon(UnitDimension.count, 1),
  teaspoon(UnitDimension.count, 1),
  pinch(UnitDimension.count, 1),
  clove(UnitDimension.count, 1),
  slice(UnitDimension.count, 1);

  const IngredientUnit(this.dimension, this.toBaseFactor);

  final UnitDimension dimension;

  /// Facteur de conversion vers l'unité de base de la dimension (g ou ml).
  final double toBaseFactor;

  /// Unité de base de la dimension ; pour les unités « comptées »,
  /// l'unité elle-même (on n'additionne pas des gousses et des tranches).
  IngredientUnit get baseUnit => switch (dimension) {
    UnitDimension.mass => gram,
    UnitDimension.volume => milliliter,
    UnitDimension.count => this,
  };

  bool get isCountable => dimension == UnitDimension.count;

  static IngredientUnit fromName(String name) {
    return IngredientUnit.values.firstWhere(
      (unit) => unit.name == name,
      orElse: () => throw FormatException('Unité inconnue : $name'),
    );
  }
}

/// Une quantité associée à une unité, avec les règles d'arrondi et
/// d'affichage de l'application.
class Quantity extends Equatable {
  const Quantity(this.value, this.unit);

  final double value;
  final IngredientUnit unit;

  /// Convertit vers l'unité de base (g, ml) pour pouvoir additionner.
  Quantity toBase() =>
      Quantity(value * unit.toBaseFactor / unit.baseUnit.toBaseFactor, unit.baseUnit);

  Quantity scale(double factor) => Quantity(value * factor, unit);

  /// Ramène la quantité vers l'unité la plus lisible et arrondit :
  /// 1250 g → 1,25 kg ; 0,3 kg → 300 g ; 1,6 œuf → 1½.
  Quantity normalized() {
    final base = toBase();
    switch (unit.dimension) {
      case UnitDimension.mass:
      case UnitDimension.volume:
        final large = unit.dimension == UnitDimension.mass
            ? IngredientUnit.kilogram
            : IngredientUnit.liter;
        final step = base.value >= 100 ? 5.0 : 1.0;
        final rounded = _roundTo(base.value, step);
        if (rounded >= 1000) {
          return Quantity(_roundTo(base.value / 1000, 0.01), large);
        }
        return Quantity(rounded == 0 ? 1 : rounded, base.unit);
      case UnitDimension.count:
        final rounded = _roundTo(value, 0.25);
        return Quantity(rounded == 0 ? 0.25 : rounded, unit);
    }
  }

  static double _roundTo(double value, double step) {
    final rounded = (value / step).round() * step;
    // Évite les artefacts binaires du type 1.2500000000000002.
    return double.parse(rounded.toStringAsFixed(2));
  }

  /// Formate la valeur selon la langue (`1,5` en français, `1.5` en anglais)
  /// et avec des fractions typographiques pour les unités comptées (`1½`).
  String formatValue(String locale) {
    final whole = value.truncate();
    final glyph = switch (((value - whole) * 100).round()) {
      25 => '¼',
      50 => '½',
      75 => '¾',
      _ => null,
    };
    if (unit.isCountable && glyph != null) {
      return whole == 0 ? glyph : '$whole$glyph';
    }
    return NumberFormat('#,##0.##', locale).format(value);
  }

  @override
  List<Object?> get props => [value, unit];
}
