use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'SQL::Tidy',
    AUTHOR              => 'Dmitri Tikhonov <dtikhonov@yahoo.com>',
    VERSION_FROM        => 'lib/SQL/Tidy.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'SQL::Tokenizer' => 0,
        'Test::More'     => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'SQL-Tidy-*' },
);
