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

package Foswiki::Plugins::EmojiPlugin::Core;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Plugins::EmojiPlugin::Mapping ();

my $STARTTOKEN = qr/^|(?<=[\s<>|])/m;
my $ENDTOKEN = qr/$|(?=[\s<>|])/m;

sub new {
  my $class = shift;

  my $this = bless({@_}, $class);

  $this->{iconSet} = _validateIconSet($this->{iconSet}) // ($Foswiki::cfg{EmojiPlugin}{DefaultIconSet} // 'facebook');

  return $this;
}

sub preRenderingHandler {
  my $this = shift;

  $_[0] =~ s/$STARTTOKEN($Foswiki::Plugins::EmojiPlugin::Mapping::EMOJI_PATTERN|$Foswiki::Plugins::EmojiPlugin::Mapping::ALIAS_PATTERN)$ENDTOKEN/$this->formatEmoji($1)/ge;
}

sub EMOJIES {
  my ($this, $session, $params, $topic, $web) = @_;

  my $name = $params->{_DEFAULT};
  my $header = $params->{header};
  my $format = $params->{format};
  my $footer = $params->{footer} || '';
  my $category = $params->{category} // '';
  my $iconSet = _validateIconSet($params->{iconset});
  my $separator = $params->{separator} || '$n';
  my $sort = $params->{sort} // 'order';

  $header = '| *%MAKETEXT{"Image"}%* | *%MAKETEXT{"Shortcut"}%* | *%MAKETEXT{"Description*"}%* | *%MAKETEXT{"Category"}%* |$n'
    unless defined $header;

  $format = '| $image | :<nop>$id: | $name | $category |' unless defined $format;

  my @emojies = ();
  if (defined $name) {
    foreach my $id (split(/\s*,\s*/, $name)) {
      my $entry = $this->getEmoji($id, $iconSet);
      push @emojies, $entry if defined $entry;
    }
  } elsif ($category) {
    push @emojies,
      $this->search({
        iconSet => $iconSet,
        category => $category
      }
      );
  } else {
    @emojies = $this->search({
        iconSet => $iconSet
      }
    );
  }

  if ($sort eq 'order' || $sort eq 'on') {
    @emojies = sort { $a->{order} <=> $b->{order} } @emojies;
  } elsif ($sort eq 'id') {
    @emojies = sort { $a->{id} cmp $b->{id} } @emojies;
  } elsif ($sort eq 'name') {
    @emojies = sort { $a->{name} cmp $b->{name} } @emojies;
  }

  my @result = ();
  my $index = 0;
  foreach my $entry (@emojies) {
    $index++;
    my $line = $this->formatEmoji($entry, $format, $iconSet);
    next unless defined $line && $line ne "";

    $line =~ s/\$index\b/$index/g;
    push @result, $line if $line;
  }

  return '' unless @result;

  my $result = Foswiki::Func::decodeFormatTokens($header . join($separator, @result) . $footer);

  $result =~ s/\$category\b/$category/g;
  $result =~ s/\$total\b/$index/g;
  $result =~ s/\$iconset\b/$iconSet/g;

  return $result;
}

sub formatEmoji {
  my ($this, $id, $format, $iconSet) = @_;

  return "" unless $id;

  $iconSet ||= $this->{iconSet};

  my $entry;
  if (ref($id)) {
    $entry = $id;
    $id = $entry->{id};
  } else {
    $entry = $this->getEmoji($id, $iconSet);
  }

  return "" unless $entry;

  my $image = '<img class=\'emoji\' src=\'$url\' alt=\'$name\' title=\'$name\' loading=\'lazy\' />';
  my $url = $this->getEmojiUrl($entry, $iconSet) // '';
  my $name = _entityEncode($entry->{name});

print STDERR "name=$name\n";

  $format //= '$image';

  $format =~ s/\$image\b/$image/g;
  $format =~ s/\$id\b/$id/g;
  $format =~ s/\$order\b/$entry->{order}/g;
  $format =~ s/\$name\b/$name/g;
  $format =~ s/\$image\b/$entry->{image}/g;
  $format =~ s/\$category\b/$entry->{category}/g;
  $format =~ s/\$url\b/$url/g;

  return $format;
}

sub getEmojiUrl {
  my ($this, $id, $iconSet) = @_;

  $iconSet ||= $this->{iconSet};

  my $entry;
  if (ref($id)) {
    $entry = $id;
    $id = $entry->{id};
  } else {
    $entry = $this->getEmoji($id, $iconSet);
  }

  return unless defined $entry;
  return Foswiki::Func::getPubUrlPath('System', 'EmojiPlugin') . "/img/$iconSet/$entry->{image}";
}

sub getEmoji {
  my ($this, $id, $iconSet) = @_;

  $iconSet ||= $this->{iconSet};

  my $alias = $Foswiki::Plugins::EmojiPlugin::Mapping::ALIASES{$id};
  $id = $alias if defined $alias;
  $id =~ s/^:(.*):$/$1/g;

  my $entry = $Foswiki::Plugins::EmojiPlugin::Mapping::EMOJIES{$id};

  return unless $entry->{$iconSet};
  return $entry;
}

sub search {
  my ($this, $params) = @_;

  my $iconSet = $params->{iconSet} || $this->{iconSet};
  my $limit = $params->{limit};

  my @result = ();
  my $index = 0;
  foreach my $entry (values %Foswiki::Plugins::EmojiPlugin::Mapping::EMOJIES) {
    next unless $entry->{$iconSet};
    next if defined($params->{category}) && $entry->{category} ne $params->{category};
    next
      if defined($params->{include})
      && (((!$params->{property} || $params->{property} =~ /\bid\b/) && !($entry->{id} =~ /$params->{include}/i))
      || ((!$params->{property} || $params->{property} =~ /\bname\b/) && $entry->{name} =~ /$params->{include}/i));
    next
      if defined($params->{exclude})
      && (((!$params->{property} || $params->{property} =~ /\bid\b/) && $entry->{id} =~ /$params->{exclude}/i)
      || ((!$params->{property} || $params->{property} =~ /\bname\b/) && $entry->{name} =~ /$params->{exclude}/i));

    push @result, $entry;
    $index++;
    last if $limit && $index >= $limit;
  }

  return @result;
}

sub _validateIconSet {
  my $iconSet = shift;

  return $iconSet if defined($iconSet) && $iconSet =~ /^(google|apple|twitter|facebook)$/;
  return;
}

sub _entityEncode {
  my $text = shift;

  $text =~ s/([[\x01-\x09\x0b\x0c\x0e-\x1f"%&'*<=>\\@[_\|])/'&#'.ord($1).';'/ge;

  return $text;
}

1;
