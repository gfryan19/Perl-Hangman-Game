#!/usr/bin/perl -w
use strict;
use lib '/Users/Greg/Documents/CS/Perl/lib/perl5';
use Tk; #use the Tk module
use Tree::Ternary_XS; #use the Ternary_XS module

#this is displayed in the terminal, player 1 will type in the word to be guessed 
#We used the code below from our common program 
my $dictTree = new Tree::Ternary_XS;
#read in the file of dictionary.txt and insert into a ternary tree 
open(FILE, "dictionary.txt") or die "The dictionary file is not present.";
    while (<FILE>) {
        s/\s*$//;
        $dictTree -> insert(lc "$_"); #stores each word in the dictionary in lowercase
    }
close(FILE);

#initialize boolean variable so the program will loop until a valid input is given 
my $valid = 0;
#initialize variable to represent the input from player 1
my $word;
#initialize array to store the input from player 1 word by word
my @words;
#initialize array to store the input from player 1 letter by letter
my @letters;
#initialize variable to store the amount of words given by player 1
my $validLength;
#initialize variable to count the amount of valid words checked so far
my $validCount;

print "Welcome to Hangman!\n";
#do while loop to receive input from player 1
#and to check at the same time if the input is valid or not
#and loop until a valid input or exit command(-1) is given
do {
    print "Please type in a valid word or phrase (no numbers) or type -1 to exit: \n";
    $word = <STDIN>; #receives input from player 1 and stores it in $word
    chomp($word); #deletes the return carriage from the end of input

    #if statement for the exit command
    if ($word eq "-1"){
        exit;
    }

    #split up the user input by word, ignoring punctuation and white space
    #and storing each word as an element in array @words
    @words = split (/\s+|\W+/, $word);
    $validCount = 0;
    $validLength = @words; #sets $validLength to be equal to the number of elements in the array

    #foreach loop to check if each word given by player 1 is valid or not
    foreach my $i (@words){
        #converts each word given by player 1 to lowercase and compares to the dictionary
        if ($dictTree -> search(lc $i) == 1){ #does not change the actual case of the word given by player 1
            print "\"$i\" is valid.\n"; #prints the word and correct case given by player 1
            $validCount++; #valid word found

            #if the number of valid words found is equal to the total number of words given
            #$valid is changed to evaluate to true, the loop is exited
            if ($validCount eq $validLength){
                $valid = 1;
            }
        }
        else {
            print "\"$i\" is not valid.\n"; #prints the invalid word given by player 1
        }
    }
}while (!$valid); #loop continues while $valid evaluates to false

#splits up the input from player 1 by letter and stores in array @letters
@letters = split(//, $word);
print "Your word/phrase \"$word\" is valid.\n";
print "The game will now begin.\n";


#GUI begins
my $mw = MainWindow->new;
$mw->title("Welcome to Hangman!");
my $c = $mw->Canvas(-background => 'DeepSkyBlue1')->pack(-anchor => 'c')->pack();
$mw-> Label(-text => "Hangman")-> pack();
$mw->configure(-background=> 'BlueViolet');

#create hangman hanger
my $line = $c->createLine(40,240,160,240, -fill=>'BlueViolet', -width => 2.0);
my $line2 = $c->createLine(100,240,100,100, -fill=>'BlueViolet', -width => 2.0);
my $line3 = $c->createLine(100,100,190,100, -fill=>'BlueViolet', -width => 2.0);
my $line4 = $c->createLine(190,100,190,120, -fill=>'BlueViolet', -width => 2.0);


#Creates Buttons for all letters of the alphabet 
my $letter_frame = $mw->Frame()->pack(-side => "bottom");
my $bottom = $letter_frame->Frame()->pack(-side =>"bottom");
#create top row of buttons
foreach my $abc ('a' .. 'm'){
    $letter_frame->Button(-text=> $abc, 
        -background => 'DeepSkyBlue1', 
        -command => [\&CheckLetter,$abc, $c, $mw])->pack(-side => "left");
}#create bottom row of buttons
foreach my $abc ('n' .. 'z'){
        $bottom->Button(-text=> $abc, 
            -background => 'DeepSkyBlue1', 
            -command => [\&CheckLetter,$abc, $c, $mw])->pack(-side => "left");
}

#initialize array for incorrect guesses
my @wrongLetters;
#initialize variable for length of incorrect guesses
my $wrong_count = 0;
#initialize variable for revealed word/phrase
my $revealed = 0;
#initialize array for hidden word/phrase
my @hidden;
#initialize variable for length of word/phrase
my $word_length = @letters;
#initialize boolean variable for a match
my $match;
#initialize variable for match count
my $match_count;
#initialize a variable for single letter matches
my $letter_match;

#make array @hidden same as array @letters
@hidden = split(//, $word);
map { $_ =~ s/\w+/_/ } @hidden; #replace each alphabet character in array with underscore

#First text box, displays hidden word and any revealed letters
my $text = $mw->Text(qw/-width 50 -height 3/)->pack;
$text->insert('end', "The mystery word has this many letters: \n");
$text->insert('end', "@hidden\n");
tie *STDOUT, 'Tk::Text', $text;

#Second text box, displays incorrect letters
my $text2 = $mw->Text(qw/-width 50 -height 3/)->pack;
$text2->insert('end', "@wrongLetters");
$text2->insert ('end',"Incorrrect Guesses Are: ");

#GUI is event driven, so this is the function called when a button is pressed
sub CheckLetter{
        
    do { 
        my $response = @_[0]; #$response is equal to the letter shown on the pressed button
        chomp($response);
        my $count = 0; #counter to keep track of location in the arrays
        $letter_match = 0; #keeps track of how many array elements have matched if any

        #foreach loop to check if the guess matches any letters in the hidden word/phrase
        foreach my $j (@letters){ #goes through every letter in the array
            if ((lc $j) eq $response){ #compares as lowercase to avoid case errors
                $match = 1; #sets match to evaluate to be true because a match has been found
                $letter_match++; #array element has been matched
                $hidden[$count] = $letters[$count]; #reveal matched array element
                print"\n";
                foreach my $h (@hidden){ #loop to re-print each element in the array with the revealed letter
                    print "$h ";
                }
                
                print "\n";
                $match_count = 0; #another counter set to 0 to check win

                #checking to see if the player2 won the game 
                do {
                    if ($hidden[$match_count] eq $letters[$match_count]){
                        $match_count++;

                        #if the amount of matches is equal to the amount of hidden letters
                        #then player 2 has won the game
                        if ($match_count eq $word_length){ 
                            $mw->messageBox(-message => "Congratulations, you win!",
                             -type => "Exit", 
                             -command => sub {exit} );
                        }
                    }
                    else {
                        $match = 0; #exit loop if there is no match
                    }
                } while ($match); #loop while the arrays match
            }
            $count++; #counter keeping track of which location in the arrays we are
        }
        #if the guess does not match any array element
        #add guess to array of incorrect guesses @wrongLetters
        #increment amount of wrong guesses to draw hangman parts
        if ($letter_match == 0){
            push(@wrongLetters, $response);
            $wrong_count = @wrongLetters;
            $text2->insert('end', "$response "); #print the latest wrong guess to GUI

            #create Body of hangman 
            if($wrong_count == 1){
                return my $circle = $_[1]->createOval(176,120,205,150, -outline=>'yellow', -width => 2.0);
            }
            elsif($wrong_count == 2){
                return my $body = $_[1]->createLine(190,150,190,197, -fill=>'yellow', -width => 2.0);
            }
            elsif($wrong_count == 3){
                return my $arm1 = $_[1]->createLine(190,174,205,165, -fill=>'yellow', -width => 2.0);
            }
            elsif($wrong_count == 4){
                return my $arm2 = $_[1]->createLine(190,174,175,165, -fill=>'yellow', -width => 2.0);
            }
            elsif($wrong_count == 5){
                return my $leg1 = $_[1]->createLine(190,197,205,206, -fill=>'yellow', -width => 2.0);
            }
            elsif($wrong_count == 6){
                return my $leg2 = $_[1]->createLine(190,197,175,206, -fill=>'yellow', -width => 2.0);
            }
            elsif($wrong_count == 7){
                return my $hand1 = $_[1]->createOval(205,160,210,165, -outline=>'yellow', -width => 2.0);
            }
            elsif($wrong_count == 8){
                return my $hand2 = $_[1]->createOval(170,160,175,165, -outline=>'yellow', -width => 2.0);
            }
            elsif($wrong_count == 9){
                return my $foot1 = $_[1]->createLine(205,206,215,206, -fill=>'yellow', -width => 2.0);
            }
            elsif($wrong_count == 10){
                my $foot2 = $_[1]->createLine(175,206,165,206, -fill=>'yellow', -width => 2.0);
                my $lose = $_[2]->messageBox(-message => "You Lose!", -type => "Exit", -command => sub {exit} );
                return $foot2, $lose;
            }
        }
        return;
    } while (!$revealed && $wrong_count <= 10); #loop until there have been 10 incorrect guesses
}                                               #and the word/phrase has not been revealed
MainLoop;