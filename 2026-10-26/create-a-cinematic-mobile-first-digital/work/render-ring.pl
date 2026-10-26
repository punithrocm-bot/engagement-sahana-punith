use strict;
use warnings;
my $file = 'outputs/assets/SP_faceted_ring.stl';
open my $fh, '<', $file or die $!;
my @faces;
while (my $line = <$fh>) {
  next unless $line =~ /facet normal\s+([\d.eE+-]+)\s+([\d.eE+-]+)\s+([\d.eE+-]+)/;
  my @n = ($1,$2,$3); my @v;
  while (my $l = <$fh>) { if ($l =~ /vertex\s+([\d.eE+-]+)\s+([\d.eE+-]+)\s+([\d.eE+-]+)/) { push @v, [$1+0,$2+0,$3+0]; last if @v==3; } }
  next unless @v==3;
  my @p = map { [$_->[0], -0.45*$_->[1]-0.89*$_->[2], -0.45*$_->[1]+0.89*$_->[2]] } @v;
  push @faces, {n=>\@n,p=>\@p,d=>($p[0][2]+$p[1][2]+$p[2][2])/3};
}
close $fh;
die "No triangles found\n" unless @faces;
my ($minx,$maxx,$miny,$maxy)=(1e9,-1e9,1e9,-1e9);
for my $f (@faces) { for my $p (@{$f->{p}}) { $minx=$p->[0] if $p->[0]<$minx; $maxx=$p->[0] if $p->[0]>$maxx; $miny=$p->[1] if $p->[1]<$miny; $maxy=$p->[1] if $p->[1]>$maxy; } }
my $pad=1.2; $minx-=$pad; $maxx+=$pad; $miny-=$pad; $maxy+=$pad;
my $w=$maxx-$minx; my $h=$maxy-$miny;
@faces=sort {$a->{d}<=>$b->{d}} @faces;
open my $out,'>','outputs/assets/gold-ring.svg' or die $!;
print $out qq{<svg xmlns="http://www.w3.org/2000/svg" viewBox="$minx $miny $w $h" role="img" aria-labelledby="title desc"><title id="title">Faceted gold ring</title><desc id="desc">A gold-toned rendering of the supplied faceted ring model.</desc><defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#f8e8a9"/><stop offset=".5" stop-color="#b38230"/><stop offset="1" stop-color="#fff0b0"/></linearGradient></defs>};
for my $f (@faces) {
  my ($nx,$ny,$nz)=@{$f->{n}}; my $len=sqrt($nx*$nx+$ny*$ny+$nz*$nz)||1; ($nx,$ny,$nz)=($nx/$len,$ny/$len,$nz/$len);
  my $light=0.18*$nx-0.62*$ny+0.76*$nz; $light=0 if $light<0;
  my $t=0.26+0.74*$light; $t=1 if $t>1;
  my @gold=(126+($t*1),78+int(104*$t),22+int(73*$t));
  my $pts=join ' ',map { sprintf('%.3f,%.3f',$_->[0],$_->[1]) } @{$f->{p}};
  printf $out '<polygon points="%s" fill="rgb(%d,%d,%d)"/>\n',$pts,@gold;
}
print $out "</svg>\n"; close $out;
print scalar(@faces), " triangles\n";
