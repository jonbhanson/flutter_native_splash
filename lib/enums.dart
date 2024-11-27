enum ArgEnums {
  help(name: 'help', abbr: 'h'),
  path(name: 'path', abbr: 'p'),
  flavor(name: 'flavor', abbr: 'f'),
  flavors(name: 'flavors', abbr: 'F'),
  allFlavors(name: 'all-flavors', abbr: 'A');

  final String name;
  final String abbr;

  const ArgEnums({required this.name, required this.abbr});
}
