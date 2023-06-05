#!/usr/bin/env perl
use strict;
use warnings;
use List::Util qw(shuffle);
use Data::Dumper;

sub main(){
#    my $ans = get_available_actions([1, 2, 3], {'kind' => 'ask', 'card' =>5});
#    print Dumper $ans;
}

main();

sub deal(){
    my @all_cards = 1..9;
    my @player0_hand;
    my @player1_hand;
    my $rest_card;
    @all_cards = shuffle(@all_cards);
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

sub get_available_actions(){
    my $now_players_hand = shift;
    my $prev_action = shift;
    my @actions;
    for my $i (1..9){
        push(@actions, {'kind' => 'ask', 'card' => $i});
    }

    my @new_actions;
    if (%$prev_action != {}){
        my $card_num = $prev_action->{'card'};
        for my $action (@actions){
            if ($action->{'card'} != $card_num){
                push(@new_actions, $action);
            }
        }
        for my $i (1..9){
            unless (grep{$_ == $i} @$now_players_hand){
                push(@new_actions, {'kind' => 'guess', 'card' => $i});
            }
        }
    }
    return \@new_actions;
};