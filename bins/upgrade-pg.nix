{ pkgs, config }:
let
  newPostgres = pkgs.postgresql_16;
in
''
  #!${pkgs.yash}/bin/yash

  set -xe

  if [ pgrep postgres ]; then
    echo "Please exit all postgres services and stop postgres!"
    systemctl list-dependencies postgresql.service --reverse
    exit 1;
  fi

  export NEWDATA="/var/lib/postgresql/${newPostgres.psqlSchema}"
  export OLDDATA="${config.services.postgresql.dataDir}"

  if [ "$NEWDATA" == "$OLDDATA" ]; then
    echo "Nothing to upgrade!"
    exit 1;
  fi

  export NEWBIN="${newPostgres}/bin"
  export OLDBIN="${config.services.postgresql.package}/bin"

  install -d -m 0700 -o postgres -g postgres "$NEWDATA"
  cd "$NEWDATA"

  su - postgres -c "$NEWBIN/initdb -D $NEWDATA"
  su - postgres -c "$NEWBIN/pg_upgrade \
        --old-datadir $OLDDATA --new-datadir $NEWDATA \
        --old-bindir $OLDBIN --new-bindir $NEWBIN \
        $@"
''
