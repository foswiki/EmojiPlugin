# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# EmojiPlugin is Copyright (C) 2021-2025 Michael Daum http://michaeldaumconsulting.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html

package Foswiki::Plugins::EmojiPlugin::Emoji;

use strict;
use warnings;

use Foswiki::Plugins ();
use Foswiki::Plugins::EmojiPlugin ();
use Foswiki::Plugins::JQueryPlugin::Plugin ();
use Error qw(:try);
use JSON ();

our @ISA = qw( Foswiki::Plugins::JQueryPlugin::Plugin );

sub new {
  my $class = shift;
  my $session = shift || $Foswiki::Plugins::SESSION;

  my $this = bless(
    $class->SUPER::new(
      $session,
      name => 'Emoji',
      version => $Foswiki::Plugins::EmojiPlugin::VERSION,
      author => 'Michael Daum',
      homepage => 'http://foswiki.org/Extensions/EmojiPlugin',
      puburl => '%PUBURLPATH%/%SYSTEMWEB%/EmojiPlugin',
      documentation => '%SYSTEMWEB%.EmojiPlugin',
      javascript => ['bundle.js'],
      dependencies => ['JQUERYPLUGIN::FOSWIKI'],
    ),
    $class
  );

  return $this;
}


