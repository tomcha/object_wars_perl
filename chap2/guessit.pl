#!/usr/bin/env perl

use strict;
use warnings;
use List::Util;
use Data::Dumper;

my $action = {};

sub deal{
    my @cards = List::Util::shuffle (1..9);
    my @player0_hand = sort(@cards[0..3]);
    my @player1_hand = sort(@cards[4..7]);
    my $rest_card = $cards[8];
    return \@player0_hand, \@player1_hand, $rest_card;
}

sub get_available_actions{
    my $hand = shift;
    my $prev_action = shift;
    my @actions;
    my @newactions;

    for my $i (1..10){
        push @actions, {kind => "ask", card => $i};
    }
    if (defined($prev_action)){
        for my $action (@actions){
            if ($action->{card} != $prev_action->{card}){
                push @newactions, $action;
            }
        }
#        my $n = List::Util::first {$_ == $prev_action} @newactions;
        for my $i (1..10){
            if (List::Util::none {$_ == $i} @$hand){
                push @newactions, {kind => "guess", card => $i};
            }
        }
    }else{
        @newactions = @actions;
    }
    return \@newactions;
}

sub select_action_human{
    my $hand = shift;
    my $prev_action = shift;
    my $available_actions = get_available_actions($hand, $prev_action);

    my @ask_cards;
    my @guess_cards;
#    print Dumper $available_actions;
    for my $action (@$available_actions){
        if ($action->{kind} eq "ask"){
            push @ask_cards, $action->{card};
        }else{
            push @guess_cards, $action->{card};
        }
    }

    while (1){
        print "Your Hand: @$hand\n";
        print "Available Commands:\n";
        if (scalar @ask_cards){
            print "ask: " . "@ask_cards" . "\n";
        }
        if (scalar @guess_cards){
            print "guess: " . "@guess_cards" . "\n";
        }
        print "exit\n";
        print "player> ";
        chomp(my $args = <STDIN>);
        my ($command, $card) = split(/ /,$args);
        unless ($card) {
            print "Empty Command.\n\n";
            next;
        }
        if ($card !~ /^([1-9]|10)$/){
            $card = undef;
        }
        my $action;
        if ($command eq "ask"){
            unless ($card){
                print "Card is not specified.\n\n";
                next;
            }
            $action = {kind => 'ask', card => $card};
        }elsif ($command eq 'guess'){
            unless($card){
                print "Card is not specified.\n\n";
                next;
            }
            $action = {kind => 'guess', card => $card};
        }elsif ($command eq 'exit'){
            print("Exit game\n");
            die;
        }else{
            print "Unknown command. (command: $command)\n\n";
            next;
        }
        my $is_inclued_available_actions = List::Util::first {$_->{kind} eq $action->{kind} && $_->{card} == $action->{card}} @$available_actions;

        unless ($is_inclued_available_actions){
            print "Unavailable. (action: $action->{kind}:$action->{card})\n\n";
            next;
        }else{
            print "You select $action->{kind}:$action->{card}\n";
            return $action;
        }
    }
}

sub select_action_ai{
    my $hand = shift;
    my $prev_action = shift;

    my $available_actions = get_available_actions($hand, $prev_action);
    my $i = int(rand(scalar @$available_actions));
    my $action = $available_actions->[$i];
    print "AI select $action->{kind}:$action->{card}\n";
    return $action;
}

sub check_action{
    my $player = shift;
    my $action = shift;
    my $opponet_hand = shift;
    my $rest_card = shift;

    my $win_player = undef;
    if ($action->{kind} eq 'ask'){
        my $n = List::Util::first {$_ == $action->{card}} @$opponet_hand;
        if (defined($n)){
            print "Hit.\n";
        }else{
            print "Miss.\n";
        }
    }else{
        if ($action->{card} == $rest_card){
            print "Hit.\n";
            $win_player = $player;
        }else{
            print "Miss.\n";
            my $opponet_player = ($player + 1) % 2;
            $win_player = $opponet_player;
        }
    }
    print "\n";
    return $win_player;
}

sub start_game{
    # action {'kind' => "ask"}, {'card' => 3}
    # first -> 0, second ->1
    my $player0_hand = shift;
    my $player1_hand = shift;
    my $rest_card = shift;

    my $turn_player = 0;
    my $prev_action = undef;

    my $action;
    my $win_player= undef;
    while(1){
        if ($turn_player == 0){
            $action = select_action_human($player0_hand, $prev_action);
            $win_player = check_action(0, $action, $player1_hand, $rest_card);
        }else{
            $action = select_action_ai($player1_hand, $prev_action);
            $win_player = check_action(1, $action, $player0_hand, $rest_card);
        }

        if (defined($win_player)){
            return $win_player;
        }

        $prev_action = $action;
        $turn_player = ($turn_player + 1) % 2;
    }
}

sub show_result{
    my $win_player = shift;
    if ($win_player == 0){
        print "You Won\n";
    }else{
        print "You Lost\n";
    }
}

sub main{
    my ($player0_hand, $player1_hand, $rest_card) = deal();
    my $win_player = start_game($player0_hand, $player1_hand, $rest_card);
    show_result($win_player);
}
main();