{ perl }:
''
  #!${perl}/bin/perl
  ${builtins.readFile ./ix/ix.pl}
''
