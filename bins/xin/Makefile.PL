use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'xin',
    VERSION_FROM     => 'xin.pl',
    EXE_FILES        => [qw(xin.pl)],
    LICENSE          => 'MIT',
    MIN_PERL_VERSION => '5.0038',
    META_MERGE       => {
        'meta-spec' => { version => 2 },
        resources   => {
            repository => {
                type => 'git',
                url  => 'https://github.com/qbit/xin.git',
                web  => 'https://github.com/qbit/xin',
            },
        },
    },
    PREREQ_PM => {
        'JSON' => '0',
    },
);
