`timescale 1ns / 1ps

module poker(
    //Outputs
    playerout,
    display_value,
    _led,
    //Inputs
    clk,
    valid,
    busy, _sw
    );
    output [23:0] playerout;
    output reg [31:0] display_value = 0;

    input  clk;
    input valid;
    input busy;
    output reg [15:0] _led;



    input [15:0] _sw;



    reg [51:0] card_array;
    integer p1 [1:0];
    integer p2 [1:0];
    integer currp1; //[2:0];
    integer currp2;
    integer currp3;
    reg player;
    integer bet_player1;
    integer bet_player2;
    integer money_p1;
    integer money_p2;
    integer p1_total_bet;
    integer p2_total_bet;

    integer pot;
    integer initialize;


    integer winner;
    integer player;

    integer p11;
    integer p10;
    integer p21;
    integer p20;
    integer c1;
    integer c2;
    integer c3;



     // Winner determination logic
      integer winner_value = 0;
      integer p1_hand_value = 20;
      integer p2_hand_value = 20;

    integer community [4:0];
    integer rndStart = 0;

    integer counter;

    integer seed;

    integer p1_score = 1234;
    integer p2_score = 5678;

//    function randCard;
//        input [51:0] card_array;
//        integer card;
//        integer count;
//        begin
//            card = $random % 52 + 1;
//            //while(card_array[card] == 1 & count < 100) begin
//            //    card = $random % 52 + 1;
//            //    count = count + 1;
//            //end
//            card_array[card] = 1;
//            randCard = card;
//        end
//    endfunction

//    function cardConvert;
//        input integer card;
//        integer value;
//        integer suit;
//        begin
//            value = card % 13;
//            suit = card / 13;
//            $display("%b", {4'b0011, suit[3:0]});
//            cardConvert = {4'b0011, suit[3:0]};//{4'b0001, 4'b0011};//
//        end
//    endfunction






//function integer sortcards;
//            input integer cards [6:0];
//           // input integer [6:0] cards;
//            integer i, j, temp;

//            begin
//                // Sort cards in ascending order
//                for (i = 0; i < 4; i = i + 1) begin
//                    for (j = 0; j < 4 - i; j = j + 1) begin
//                        if (cards[j] > cards[j + 1]) begin
//                            temp = cards[j];
//                            cards[j] = cards[j + 1];
//                            cards[j + 1] = temp;
//                        end
//                    end
//                end
//            end
//            sortcards = cards
//    endfunction

// function to check if there is a royal flush return 20 if not found
    function integer checkroyalflush;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer straightflush;
        integer i;
        integer cards[5:0];

        begin
            // Call checkstraightflush function
            straightflush = checkstraightflush(playercard1, playercard2, community1, community2, community3);

            // Check if it's a straight flush and if any card is an ace (card % 13 = 12)
            if (straightflush != 20) begin

                cards[0] = playercard1;
                cards[1] = playercard2;
                cards[2] = community1;
                cards[3] = community2;
                cards[4] = community3;
                checkroyalflush = 20; // Not a royal flush
                for (i = 0; i < 5; i = i + 1) begin
                    if ((cards[i] % 13) == 12) begin
                        checkroyalflush = 12; // Royal flush found

                    end
                end
            end


        end
    endfunction


//    //function to check if there is a straight flush
    function integer checkstraightflush;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer straight;
        integer flush;

        begin
            // Call checkstraight function
            straight = checkstraight(playercard1, playercard2, community1, community2, community3);
            // Call checkflush function
            flush = checkflush(playercard1, playercard2, community1, community2, community3);

            // Check if it's both a straight and a flush
            if (straight != 20 && flush != 20) begin
                checkstraightflush = straight; // Straight flush found
            end
            else begin
                checkstraightflush = 20; // Not a straight flush
            end
        end
    endfunction


//    // Function to check if there is a 4 of a kind 20 if not found, returns value of 4 of a kind
    function integer check4ofakind;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5:0];
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Perform simple sorting of the cards
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 4 - i; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap values
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end
            check4ofakind = 20; // No 4 of a kind

            // Check if last 4 cards are equal
            if ((cards[1] == cards[2]) && (cards[2] == cards[3]) && (cards[3] == cards[4])) begin
                check4ofakind = cards[2]; // 4 of a kind found
            end

            // Check if first 4 cards are equal
            if ((cards[0] == cards[1]) && (cards[1] == cards[2]) && (cards[2] == cards[3])) begin
                check4ofakind = cards[2]; // 4 of a kind found
            end

        end
    endfunction



//    // Function to check if there is a full house, returns the low 2 cards value else 20
    function integer checkfullhouse;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5:0];
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Perform simple sorting of the cards
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 4 - i; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap values
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end

            checkfullhouse = 20; // No full house

            // Check if first three cards and then the other two cards are equal
            if ((cards[0] == cards[1]) && (cards[1] == cards[2]) && (cards[3] == cards[4])) begin
                checkfullhouse = cards[3]; // Full house found
            end

            // Check if first two cards and then the last three cards are equal
            if ((cards[0] == cards[1]) && (cards[2] == cards[3]) && (cards[3] == cards[4])) begin
                checkfullhouse = cards[1]; // Full house found
            end

        end
    endfunction



   //function to check for a flush
    function integer checkflush;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer suit[5:0];
        integer i;
        begin
            suit[0] = playercard1 / 13;
            suit[1] = playercard2 / 13;
            suit[2] = community1 / 13;
            suit[3] = community2 / 13;
            suit[4] = community3 / 13;

            // Check for flush
            if ((suit[0] == suit[1]) && (suit[1] == suit[2]) && (suit[2] == suit[3]) && (suit[3] == suit[4])) begin
                checkflush = highcardnum(playercard1, playercard2, community1, community2, community3); // Flush found
            end else begin
                checkflush = 20; // No flush
            end
        end
    endfunction

//    //function to check if there is a straight, 20 if no straight found, else return highest value
    function integer checkstraight;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5:0];
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Bubble Sort cards
            for (i = 0; i < 5 - 1; i = i + 1) begin
                for (j = 0; j < 5 - i - 1; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap cards[j] and cards[j+1]
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end
            checkstraight = cards[4];

            // Check if cards are in ascending order
            for (i = 0; i < 4; i = i + 1) begin
                if (cards[i] + 1 != cards[i + 1]) begin
                    checkstraight = 20; // Not in ascending order
                end
            end

 // In ascending order
        end
    endfunction



//    // Function to check if there is a three of a kind, return card value if found, else 20
    function integer checkthreeofakind;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5:0];
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Bubble Sort cards
            for (i = 0; i < 5 - 1; i = i + 1) begin
                for (j = 0; j < 5 - i - 1; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap cards[j] and cards[j+1]
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end
            checkthreeofakind = 20; // No three of a kind

            // Check if first three cards are equal
            if ((cards[0] == cards[1]) && (cards[1] == cards[2])) begin
                checkthreeofakind = cards[2]; // Three of a kind found
            end
            // Check if middle three cards are equal
            if ((cards[1] == cards[2]) && (cards[2] == cards[3])) begin
                checkthreeofakind = cards[2]; // Three of a kind found
            end
            // Check if end three cards are equal
            if ((cards[2] == cards[3]) && (cards[3] == cards[4])) begin
                checkthreeofakind = cards[2]; // Three of a kind found
            end

        end
    endfunction


//        // Function to check if there is a two pair returns highest value of that pair, else 20
  function integer checktwopair;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5:0];
        integer high1;
        integer high2;
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Bubble Sort cards
            for (i = 0; i < 5 - 1; i = i + 1) begin
                for (j = 0; j < 5 - i - 1; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap cards[j] and cards[j+1]
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end
            checktwopair = 20; // No two pair

            // Check if the first pair exists
            if ((cards[0] == cards[1]) || (cards[1] == cards[2])) begin
                high1 = cards[1];
                // Check if there's a second pair
                if ((cards[0] == cards[1] && (cards[2] == cards[3] || cards[3] == cards[4])) ||
                    (cards[1] == cards[2] && cards[3] == cards[4])) begin
                    high2 = cards[3];
                    if (high1 > high2)
                        checktwopair = high1; // Two pair found
                    else
                        checktwopair = high2;
                end
            end


        end
    endfunction


    //Function to check if there is a two of a kind. 20 if not found
    function integer checktwoofakind;
        input integer playercard1;
        input integer playercard2;
        input integer community1;
        input integer community2;
        input integer community3;
        integer cards[5:0];
        integer i, j, temp;

        begin
            // Merge player and community cards
            cards[0] = playercard1 % 13;
            cards[1] = playercard2 % 13;
            cards[2] = community1 % 13;
            cards[3] = community2 % 13;
            cards[4] = community3 % 13;

            // Bubble Sort cards
            for (i = 0; i < 5 - 1; i = i + 1) begin
                for (j = 0; j < 5 - i - 1; j = j + 1) begin
                    if (cards[j] > cards[j + 1]) begin
                        // Swap cards[j] and cards[j+1]
                        temp = cards[j];
                        cards[j] = cards[j + 1];
                        cards[j + 1] = temp;
                    end
                end
            end
            checktwoofakind = 20; // No two of a kind

            // Check adjacent cards for two of a kind
            for (i = 0; i < 4; i = i + 1) begin
                if (cards[i] == cards[i + 1]) begin
                    checktwoofakind = cards[i]; // Two of a kind found
                end
            end


        end
    endfunction



   function integer highcardnum;
    input integer playercard1;
    input integer playercard2;
    input integer community1;
    input integer community2;
    input integer community3;
    integer cards[5:0];
    integer max_card;
    integer i;

    begin
        // Merge player and community cards
        cards[0] = playercard1 % 13;
        cards[1] = playercard2 % 13;
        cards[2] = community1 % 13;
        cards[3] = community2 % 13;
        cards[4] = community3 % 13;

        // Initialize max_card with the first card value
        max_card = cards[0];

        // Loop through the cards to find the highest value
        for (i = 1; i < 5; i = i + 1) begin
            if (cards[i] > max_card) begin
                max_card = cards[i];
            end
        end

        // Return the highest card value
        highcardnum = max_card; // Add 1 to convert back to original card value
    end
endfunction





   function integer randCard;
        input integer s;
        input [51:0] card_array;
        integer card, count;
        begin
            count = 0;
            //card = $random(s) % 52; // Pick a random card
            card = s % 52;
            while ((card_array[card] == 1) && (count < 52)) begin
                card = s % 52; // Pick another if already chosen
                count = count + 1;
            end
            if (count < 52) begin
                card_array[card] = 1; // Mark card as chosen
            end
            else begin
                card = 1; // Indicate failure to find a unique card
            end
             randCard = card;
         end
     endfunction



    //new randcard function:
//    function integer randCard;
//        input integer s;
//        input [51:0] card_array;
//        output [51:0] card_array_out;
//        integer card, count;
//        reg [51:0] card_array_temp;
//        begin
//            count = 0;
//            card = s % 52; // Initial card selection attempt
//            card_array_temp = card_array; // Copy input card_array to a temporary variable for modification

//            // Loop until an unselected card is found or we've attempted all cards
//            while ((card_array_temp[card] == 1) && (count < 52)) begin
//                card = (card + 1) % 52; // Try the next card
//                count = count + 1; // Increment the attempt count
//            end

//            if (count < 52) begin
//                card_array_temp[card] = 1; // Mark card as chosen in the temporary array
//                randCard = card; // Return the chosen card
//            end else begin
//                randCard = -1; // Indicate failure to find a unique card
//            end
//            card_array_out = card_array_temp; // Output the updated card array
//        end
//    endfunction


    function [7:0] cardConvert;
        input integer card;
        integer value, suit;
        begin
        if (card != -1) begin
            value = card % 13;
            suit = card / 13;
            cardConvert = {value[3:0], suit[3:0]};
        end
        else
            cardConvert = 8'b11111111;
        end
    endfunction

    initial begin
        card_array = 0;
        seed = 12345;
        counter = 0;
        player = 1;
        money_p1 = 100;
        money_p2 = 100;
        initialize = 0;
        rndStart = 0;
        p1_total_bet = 0;
        p2_total_bet = 0;
        pot = 0;
    end

    always @ (posedge valid) begin
        if (rndStart == 8)
            rndStart = 0;
            pot = 0;
            p1_total_bet = 0;
            p2_total_bet = 0;
            p1_score = 20;
            p2_score = 20;
            card_array = 0;



        //if (rndStart != 0)
                    //rndStart = rndStart + 1;
        if(rndStart == 0 && initialize == 0) begin

        p10 = 5;//randCard(counter, card_array);
        p11 = 6;//randCard(counter+1, card_array);
        p20 = 3;//randCard(counter+2, card_array);
        p21 = 4;//randCard(counter+3, card_array);
        c1 = 0;//randCard(counter+4, card_array);
        c2 = 1;//randCard(counter+5, card_array);
        c3 = 2;//randCard(counter+6, card_array);
           // p1[0] = 36; //randCard(counter, card_array);
            //p1[1] =43;// randCard(counter + 1, card_array);

           // p2[0] = 34 ;// randCard(counter + 2, card_array);
           // p2[1] = 25;// randCard(counter + 3, card_array);

           // community[0] = 11;// randCard(counter + 4, card_array);
         //   community[1] = 21;//randCard(counter + 5, card_array);
           // community[2] = 31;//randCard(counter + 6, card_array);
            //community[3] = randCard(counter + 7, card_array);
            //community[4] = randCard(counter + 8, card_array);
            //rndStart = 1;
            initialize = 1;
           // $display("rndStart = %d: Community cards after assignment: %d, %d, %d", rndStart, community[0], community[1], community[2]);


        end
                   // $display("Beginning of always block - rndStart = %d, Community: %d, %d, %d", rndStart, community[0], community[1], community[2]);
        case (rndStart)
            0: begin
                bet_player1 = 0;
                bet_player2 = 0;

                currp1 = c1;
                currp2 = c2;
                currp3 = c3;
                display_value = p1_score;
            end
            1: begin
                currp1 = p10;
                currp2 = p11;
                currp3 = -1;
                display_value = p1_score;
            end
            2: begin
               currp1 = c1;
               currp2 = c2;
               currp3 = c3;
               display_value = p2_score;
            end
            3: begin
                currp1 = p20;
                currp2 = p21;
                currp3 = -1;
                display_value = p2_score;
            end
            4 : begin
                currp1 = -1;
                currp2 = -1;
                currp3 = -1;
                player = 1;

                 //initial bet round
                    pot = 0;
                    bet_player1 = 0;
                    bet_player2 = 0;
                    money_p1 = money_p1 - 5; //min bet
                    money_p2 = money_p2 - 5; //min bet
                    pot = pot + 10;
            end
            5:
                begin
                   currp1 = 8'b01011101;
                   currp2 = 8'b01011101; //displays p1
                   currp3 = 8'b01011101;

                    // player 1 turn
                    //bet amount is calculated from switches
                    bet_player1 = _sw[15:0];
                    if(bet_player1 < bet_player2)
                        display_value = bet_player2 - bet_player1; //display the value they have to bet more
                    else
                    display_value = 0; // valid bet?

                    if(money_p1 < bet_player1)begin
                        //if the bet is higher than the money the player has, the player is asked to bet again
                        rndStart = rndStart - 1;
                        display_value = 999; //display error check if this is valid or correct @ justin
                    end
                    else begin
                        //if the bet is valid, the bet is added to the pot and the player's money is updated
                        pot = pot + bet_player1;
                        money_p1 = money_p1 - bet_player1;
                        p1_total_bet = p1_total_bet + bet_player1;
                        if (p1_total_bet < p2_total_bet)begin
                            rndStart = rndStart - 1; //if the total bet of the players is not equal, the player with the lower bet is asked to bet again
                        end
                    end

                end

             6:
                begin
                    currp1 = 8'b01010000; //p2
                   currp2 = 8'b01010000;  //displays p2
                   currp3 =  8'b01010000;

                    // player 2 turn
                    //bet amount is calculated from switches
                    bet_player2 = _sw[15:0];
                    if(bet_player2 < bet_player1)
                        display_value = bet_player1 - bet_player2; //display the value they have to bet more
                    else
                    display_value = 0; // valid bet?


                    if(money_p2 < bet_player2) begin
                        //if the bet is higher than the money the player has, the player is asked to bet again
                        rndStart = rndStart - 1;
                        display_value = 999; //display error check if this is valid or correct @ justin
                     end
                    else begin
                        //if the bet is valid, the bet is added to the pot and the player's money is updated
                        pot = pot + bet_player2;
                        money_p2 = money_p2 - bet_player2;
                        p2_total_bet = p2_total_bet + bet_player2;
                        if(p2_total_bet < p1_total_bet) begin
                           // if the total bet of the players is not equal, the player with the lower bet is asked to bet again
                            rndStart = rndStart - 1;
                        end
                    end


                    //make it go through the loop until both players have the same amount of money,a dnit sohuld go through this once

                end
            7:
            begin
                // Check royal flush first
                p1_score = checkroyalflush(p10, p11, c1, c2, c3);
                p2_score = checkroyalflush(p20, p21, c1, c2, c3);
                if(p1_score == 20 && p2_score == 20) begin
                    // Check straight flush
                    p1_score = checkstraightflush(p10, p11, c1, c2, c3);
                    p2_score = checkstraightflush(p20, p21, c1, c2, c3);
                    if(p1_score == 20 && p2_score == 20) begin
                        // Check 4 of a kind
                        p1_score = check4ofakind(p10, p11, c1, c2, c3);
                        p2_score = check4ofakind(p20, p21, c1, c2, c3);
                        if(p1_score == 20 && p2_score == 20) begin
                            // Check full house
                            p1_score = checkfullhouse(p10, p11, c1, c2, c3);
                            p2_score = checkfullhouse(p20, p21, c1, c2, c3);
                            if(p1_score == 20 && p2_score == 20) begin
                                // Check flush
                                p1_score = checkflush(p10, p11, c1, c2, c3);
                                p2_score = checkflush(p20, p21, c1, c2, c3);
                                if(p1_score == 20 && p2_score == 20) begin
                                    // Check straight
                                    p1_score = checkstraight(p10, p11, c1, c2, c3);
                                    p2_score = checkstraight(p20, p21, c1, c2, c3);
                                    if(p1_score == 20 && p2_score == 20) begin
                                        // Check 3 of a kind
                                        p1_score = checkthreeofakind(p10, p11, c1, c2, c3);
                                        p2_score = checkthreeofakind(p20, p21, c1, c2, c3);
                                        if(p1_score == 20 && p2_score == 20) begin
                                            // Check two pair
                                            p1_score = checktwopair(p10, p11, c1, c2, c3);
                                            p2_score = checktwopair(p20, p21, c1, c2, c3);
                                            if(p1_score == 20 && p2_score == 20) begin
                                                // Check two of a kind
                                                p1_score = checktwoofakind(p10, p11, c1, c2, c3);
                                                p2_score = checktwoofakind(p20, p21, c1, c2, c3);
                                                if(p1_score == 20 && p2_score == 20) begin
                                                    // High card
                                                    p1_score = highcardnum(p10, p11, c1, c2, c3);
                                                    p2_score = highcardnum(p20, p21, c1, c2, c3);
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end

                if(p1_score != 20 || p2_score != 20) begin
                    if(p1_score == 20) winner = 2;
                    else if(p2_score == 20) winner = 1;
                    else if(p1_score > p2_score) winner = 1;
                    else if(p1_score < p2_score) winner = 2;
                    else
                        begin
                            if(p10 > p20 && p10 > p21)
                                winner = 1;
                            else if(p11 > p20 && p11 > p21)
                                winner = 1;
                            if(p20 > p10 && p20 > p11)
                                winner = 2;
                            else if(p21 > p10 && p21 > p11)
                                winner = 2;
                            else winner = 2; // Randomly assign if values are equal should not happen
                    end

                end
                else
                    winner = 1; // Randomly assign if values are equal

               if(winner == 1) begin
                   money_p1 = money_p1 + pot;
                   _led[3:0] <= 4'b0001;
               end
               else begin
                   money_p2 = money_p2 + pot;
                   _led[3:0] <= 4'b0010;                  
               end
               
            end
        endcase
       // $display("End of always block - rndStart = %d, Community: %d, %d, %d", rndStart, community[0], community[1], community[2]);
        rndStart = rndStart + 1;
//        playerout = {cardConvert(currp1), cardConvert(currp2), cardConvert(currp3)};
//        if (rndStart < 2) begin
//            if (rndStart == 0) begin 
//                currp[0] = community[0];
//                currp[1] = community[1];
//                currp[2] = community[2];
//            end
//            else if ()
//                currp[0] = p1[0];
//                currp[1] = p1[1];
//                currp[2] = -1;
//            end
//            //currp[2] = 24;
//        end
//        else begin
//            if (rndStart == 2) begin 
//                currp[0] = community[0];
//                currp[1] = community[1];
//                currp[2] = community[2];
//            end
//            else begin
//                currp[0] = p2[0];
//                currp[1] = p2[1];
//                currp[2] = -1;
//            end
//        end
        
        //currp[1] = player ? p1[1] : p2[1]; 
        //currp[0] = player ? p1[0] : p2[0];
        //player = ~player;
        
//         if(rndStart == 5) begin
              
               
//               // Check royal flush first
//               p1_hand_value = checkroyalflush(p1, community);
//               p2_hand_value = checkroyalflush(p2, community);
               
//               if (p1_hand_value != 20 || p2_hand_value != 20) begin
//                   if (p1_hand_value == 20) winner_value = 2;
//                   else if (p2_hand_value == 20) winner_value = 1;
//                   else if (p1_hand_value > p2_hand_value) winner_value = 1;
//                   else if (p1_hand_value < p2_hand_value) winner_value = 2;
//                   else winner_value = $random % 2 == 0 ? 1 : 2; // Randomly assign if values are equal
//               end
//               else begin
//                   // Check straight flush
//                   p1_hand_value = checkstraightflush(p1, community);
//                   p2_hand_value = checkstraightflush(p2, community);
                   
//                   if (p1_hand_value != 20 || p2_hand_value != 20) begin
//                       if (p1_hand_value == 20) winner_value = 2;
//                       else if (p2_hand_value == 20) winner_value = 1;
//                       else if (p1_hand_value > p2_hand_value) winner_value = 1;
//                       else if (p1_hand_value < p2_hand_value) winner_value = 2;
//                       else winner_value = $random % 2 == 0 ? 1 : 2; // Randomly assign if values are equal
//                   end
//                   else begin
//                       // Add similar checks for other hands...
//                   end
//               end
               
//               // Update winner output
//               winner = winner_value;
//               end
               
        
       end
       
       assign playerout = {cardConvert(currp1), cardConvert(currp2), cardConvert(currp3)};
       
       always @ (posedge clk) begin
        counter = counter + 1;
        if (counter + 10 < 0) begin
            counter = 0;
        end
       end
       
//       reg [23:0] playerout_reg;
//       always @(posedge clk) begin
//           playerout_reg <= {cardConvert(currp1), cardConvert(currp2), cardConvert(currp3)};
//       end
       
//       assign playerout = playerout_reg;
       
endmodule
