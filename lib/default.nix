let
  mkCronScript = name: src: ''
    . /etc/profile;
    set -x
    # autogenreated ${name}
    ${src}
  '';
  jobToService = job: {
    name = "${job.name}";
    value = {
      script = mkCronScript "${job.name}_script" job.script;
      inherit (job) startAt path;
    };
  };

  xinlib = { inherit mkCronScript jobToService; };

in xinlib
