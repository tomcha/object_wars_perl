#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(shuffle);

sub main(){

}

sub deal(){
    my @all_cards = 1..9;
    my @player0_hand;
    my @player1_hand;
    my $rest_card;
    shuffle(@all_cards);
    $rest_card = $all_cards[0];
    for(my $i = 1;$i<9;$i++){
        if ($i % 2 == 0){
            push(@player0_hand, $all_cards[$i]);
        }else{
            push(@player1_hand, $all_cards[$i]);
        }
    }
    return \@player0_hand, \@player1_hand, $rest_card;
}