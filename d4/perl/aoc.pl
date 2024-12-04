use strict;
use warnings;

my @fixed_pattern = (
[['S', '.', 'S'], 
['.', 'A', '.'], 
['M', '.', 'M']],

[['M', '.', 'M'], 
['.', 'A', '.'], 
['S', '.', 'S']],

[['M', '.', 'S'], 
['.', 'A', '.'],
 ['M', '.', 'S']],

[['S', '.', 'M'], 
['.', 'A', '.'],
 ['S', '.', 'M']]);

my $filename = 'input';

my @matrix;

open(my $fh, '<', $filename) or die "Could not open file '$filename' $!";

while (my $line = <$fh>) {
    chomp $line; 
    my @row = split //, $line;  
    push @matrix, \@row;
}

close($fh);


sub match_matrices {
    my @pattern_ref = @{$_[0]};
    my @matrix2_ref = @{$_[1]};
    for my $i (0..2) {
        for my $j (0..2) {
            if (($pattern_ref[$i]->[$j] ne $matrix2_ref[$i]->[$j]) and ($pattern_ref[$i]->[$j] ne '.')) {
                return 0;
            }
        }
    }
    return 1;
}



sub extract_submatrix {
    my ($matrix_ref, $row, $col) = @_;
    my @submatrix;
    my $num_rows = scalar @$matrix_ref;
    my $num_cols = scalar @{$matrix_ref->[0]};

    if ($row < 0 || $col < 0 || $row + 2 >= $num_rows || $col + 2 >= $num_cols) {
        die "Invalid position for extracting a 3x3 submatrix.";
    }
    for my $i (0..2) {
        push @submatrix, [ @{$matrix_ref->[$row + $i]}[$col .. $col + 2] ];
    }

    return \@submatrix;
}

sub find_matches {
    my ($matrix, $fixed_pattern) = @_;
    my $num_rows = scalar $#matrix;
    my $num_cols = scalar $#{$matrix[0]};
    for my $i (0..$num_rows - 2) {
        for my $j (0..$num_cols - 2) {
            my $submatrix_ref = extract_submatrix(\@matrix, $i, $j);
            foreach my $pattern_ref (@fixed_pattern) {
                # print "pattern_ref: $pattern_ref\n";
                if (match_matrices(\@$pattern_ref, \@$submatrix_ref)) {
                    $counter++;
                }
            }
        }
    }
    return $counter;
}

my $matches = find_matches(\@matrix, \@fixed_pattern);
print "matches: $matches\n";

