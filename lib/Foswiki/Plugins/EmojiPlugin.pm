# Plugin for Foswiki - The Free and Open Source Wiki, https://foswiki.org/
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

package Foswiki::Plugins::EmojiPlugin;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Plugins::EmojiPlugin::Core ();
use Foswiki::Plugins::JQueryPlugin ();

our $VERSION = '1.20';
our $RELEASE = '%$RELEASE%';
our $SHORTDESCRIPTION = 'Standard Emoji Support';
our $LICENSECODE = '%$LICENSECODE%';
our $NO_PREFS_IN_TOPIC = 1;
our $core;

sub initPlugin {

  Foswiki::Func::registerTagHandler('EMOJIES', sub { return getCore()->EMOJIES(@_); });
  Foswiki::Plugins::JQueryPlugin::registerPlugin('Emoji', 'Foswiki::Plugins::EmojiPlugin::Emoji');

  if ($Foswiki::cfg{Plugins}{SmiliesPlugin}{Enabled}) {
    if ($Foswiki::cfg{EmojiPlugin}{SmiliesPluginWarning}) {
      my $msg = "WARNING: SmiliesPlugin enabled while using EmojiPlugin";
      Foswiki::Func::writeWarning($msg);
      print STDERR "$msg\n";
    }
  }

  return 1;
}

sub getCore {
  unless (defined $core) {
    my $iconSet = Foswiki::Func::getPreferencesValue("EMOJI_ICONSET") // '';
    $iconSet = Foswiki::Func::expandCommonVariables($iconSet) if $iconSet =~ /%/;
    $core = Foswiki::Plugins::EmojiPlugin::Core->new(
      iconSet => $iconSet
    );
  }
  return $core;
}

sub finishPlugin {
  undef $core;
}

sub preRenderingHandler {
  getCore()->preRenderingHandler($_[0]);
}

1;
