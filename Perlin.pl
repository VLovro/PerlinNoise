use Math::Trig;
use POSIX qw(floor);
use PDL;
use Time::HiRes qw( time );
use GD::Image;

sub permutacijska_tablica {
    my @permutacija = ( 0 .. 255 );
    push @permutacija, @permutacija;
    return @permutacija;
}

sub fade {
    my ($t) = @_;
    return $t * $t 
}

sub lerp {
    my ( $a, $b, $x ) = @_;
     return (1 - $x) * $a + $x * $b;
}

sub gradijent {
    my ( $index, $x, $y ) = @_;
    my @vektor = ( 0, pi / 4, pi / 2, 3 * pi / 4, pi, 5 * pi / 4, 3 * pi / 2, 7 * pi / 4 );
    my $x_komponenta_G = cos( $vektor[ $index % 8 ] );
    my $y_komponenta_G = sin( $vektor[ $index % 8 ] );
    return $x_komponenta_G * $x + $y_komponenta_G * $y;
}

sub noise {
	my ($x, $y, $frek, $ampl) = @_;

    my $x1 = int(floor($x * $frek));
    my $y1 = int(floor($y * $frek));
    my $x2 = $x * $frek - $x1;
    my $y2 = $y * $frek - $y1;
    my $xf = fade($x2);
    my $yf = fade($y2);

    my @p = permutacijska_tablica();
    my @perm_tablica = map { int($_) } @p;

    my $a = gradijent($perm_tablica[$perm_tablica[$x1] + $y1], $x2, $y2);
    my $b = gradijent($perm_tablica[$perm_tablica[$x1] + $y1 + 1], $x2, $y2 - 1);
    my $b1 = gradijent($perm_tablica[$perm_tablica[$x1 + 1] + $y1 + 1], $x2 - 1, $y2 - 1);
    my $a1 = gradijent($perm_tablica[$perm_tablica[$x1 + 1] + $y1], $x2 - 1, $y2);

    my $x3 = lerp($a, $a1, $xf);
    my $x4 = lerp($b, $b1, $xf);
    return lerp($x3, $x4, $yf) * $ampl;
   
}

sub oktaveFunc {
    my ($x, $y, $oktave, $persistence) = @_;
    my $rez = 0;
    my $frek = 0.5;
    my $ampl = 1;
    my $max_vrijednost = 0;

    for (my $i = 0; $i < $oktave; $i++) {
        $rez += noise($x, $y, $frek, $ampl) * $ampl;
        $max_vrijednost += $ampl;
        $ampl *= $persistence;
        $frek *= 2;
    }

    return $rez / $max_vrijednost
}

my $pocetak = time();
my $oktave = 6;
my $persistence = 0.5;
my $n = 200;
my $x = sequence($n) / ($n - 1) * 20;
my $y = sequence($n) / ($n - 1) * 20;
my $x_niz = xvals(sequence($n, $n)) / ($n - 1) * 20;
my $y_niz = yvals(sequence($n, $n)) / ($n - 1) * 20;
print($x);

$y_niz = transpose($y_niz);
my $perlin2d = oktaveFunc( $x_niz, $y_niz, $oktave, $persistence );
$slika = GD::Image->new(200,200);
my $crvenaBoja = $slika->colorAllocate(255, 0, 0);
for my $i (1..255) {
    $slika->colorAllocate($i, 0, 0);
}
$slika->trueColor(0);

for my $y (0..$n-1) {
    for my $x (0..$n-1) {
        my $vrijednost = $perlin2d->at($y, $x);
        $slika->setPixel($x, $y, $vrijednost);
    }
}


open(my $png_datoteka, '>', 'perlinNoise.png') or die "Doslo je do pogreske': $!";
binmode $png_datoteka;
print $png_datoteka $slika->png;
close $png_datoteka;
my $kraj = time();
my $vrijeme_izvodenja = $kraj - $pocetak;
print "Vrijeme izvodenja: $vrijeme_izvodenja sekundi\n";

