use 5.010_001;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Merenda::Paste',
  VERSION_FROM => 'lib/Merenda/Paste.pm',
  ABSTRACT     => 'Integrated pastebin',
  AUTHOR       => 'Nic Sandfield <niczero@cpan.org>',
  LICENSE      => 'artistic_2',
  META_MERGE   => {
    requires  => {perl => 5.010001},
    resources => {
      homepage    => 'http://niczero.github.com/merenda',
      license     => 'http://www.opensource.org/licenses/artistic-license-2.0',
      repository  => 'http://github.com/niczero/merenda-paste',
      bugtracker  => 'http://github.com/niczero/merenda-paste/issues'
    },
    no_index => {directory => [qw(cfg data test)]}
  },
  BUILD_REQUIRES => {'Test::More' => 0},
  CONFIGURE_REQUIRES => {'ExtUtils::MakeMaker' => '6.30'},
  PREREQ_PM => {Mojolicious => 5},
  EXE_FILES => [],
  test => {TESTS => 'test/*.t'}
);
