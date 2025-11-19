import 'dart:math';
import 'package:flutter/material.dart';

// --- Models ---

enum Suit { spades, hearts, diamonds, clubs }
enum Rank { two, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace }

class PlayingCard {
  final Suit suit;
  final Rank rank;

  PlayingCard({required this.suit, required this.rank});

  String get rankSymbol {
    switch (rank) {
      case Rank.two: return '2';
      case Rank.three: return '3';
      case Rank.four: return '4';
      case Rank.five: return '5';
      case Rank.six: return '6';
      case Rank.seven: return '7';
      case Rank.eight: return '8';
      case Rank.nine: return '9';
      case Rank.ten: return '10';
      case Rank.jack: return 'J';
      case Rank.queen: return 'Q';
      case Rank.king: return 'K';
      case Rank.ace: return 'A';
    }
  }

  Color get color {
    return (suit == Suit.hearts || suit == Suit.diamonds) ? Colors.red : Colors.black;
  }
  
  // Helper for better suit display using text/emoji characters
  String get suitSymbol {
    switch (suit) {
      case Suit.spades: return '♠';
      case Suit.hearts: return '♥';
      case Suit.diamonds: return '♦';
      case Suit.clubs: return '♣';
    }
  }
}

class Deck {
  List<PlayingCard> cards = [];

  Deck() {
    _initDeck();
  }

  void _initDeck() {
    cards.clear();
    for (var suit in Suit.values) {
      for (var rank in Rank.values) {
        cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
  }

  void shuffle() {
    cards.shuffle(Random());
  }

  PlayingCard draw() {
    if (cards.isEmpty) _initDeck();
    return cards.removeLast();
  }
}

// --- Widgets ---

class CardWidget extends StatelessWidget {
  final PlayingCard? card;
  final bool isFaceUp;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    this.card,
    this.isFaceUp = true,
    this.width = 60,
    this.height = 85,
  });

  @override
  Widget build(BuildContext context) {
    if (!isFaceUp || card == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.blue[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[800]!, Colors.blue[900]!],
          ),
        ),
        child: Center(
          child: Container(
            width: width * 0.8,
            height: height * 0.8,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Icon(Icons.casino, color: Colors.white24, size: 20),
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 2),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                card!.rankSymbol,
                style: TextStyle(
                  color: card!.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Text(
            card!.suitSymbol,
            style: TextStyle(
              color: card!.color,
              fontSize: 24,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 2),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Transform.rotate(
                angle: pi,
                child: Text(
                  card!.rankSymbol,
                  style: TextStyle(
                    color: card!.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Game Screen ---

class PokerGameScreen extends StatefulWidget {
  const PokerGameScreen({super.key});

  @override
  State<PokerGameScreen> createState() => _PokerGameScreenState();
}

class _PokerGameScreenState extends State<PokerGameScreen> {
  late Deck deck;
  List<PlayingCard> communityCards = [];
  List<PlayingCard> playerHand = [];
  List<PlayingCard> opponentHand = [];
  
  int potSize = 0;
  int playerChips = 1000;
  int currentBet = 0;
  String gameStatus = "准备开始"; // Ready to start

  @override
  void initState() {
    super.initState();
    deck = Deck();
    deck.shuffle();
  }

  void startNewHand() {
    setState(() {
      deck = Deck();
      deck.shuffle();
      communityCards.clear();
      playerHand.clear();
      opponentHand.clear();
      potSize = 0;
      currentBet = 0;
      
      // Deal initial cards
      playerHand.add(deck.draw());
      opponentHand.add(deck.draw());
      playerHand.add(deck.draw());
      opponentHand.add(deck.draw());
      
      gameStatus = "翻牌前 (Pre-Flop)";
    });
  }

  void dealFlop() {
    if (communityCards.isNotEmpty) return;
    setState(() {
      communityCards.add(deck.draw());
      communityCards.add(deck.draw());
      communityCards.add(deck.draw());
      gameStatus = "翻牌 (Flop)";
    });
  }

  void dealTurn() {
    if (communityCards.length != 3) return;
    setState(() {
      communityCards.add(deck.draw());
      gameStatus = "转牌 (Turn)";
    });
  }

  void dealRiver() {
    if (communityCards.length != 4) return;
    setState(() {
      communityCards.add(deck.draw());
      gameStatus = "河牌 (River)";
    });
  }

  void placeBet(int amount) {
    if (playerChips >= amount) {
      setState(() {
        playerChips -= amount;
        potSize += amount * 2; // Simulating opponent calling
        currentBet += amount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('德州扑克房间 #888'),
        backgroundColor: const Color(0xFF0D3312),
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '\$$playerChips',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // --- Opponent Area ---
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text("对手 (Opponent)", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CardWidget(isFaceUp: false), // Hidden cards
                      const SizedBox(width: 8),
                      CardWidget(isFaceUp: false),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- Table / Community Cards ---
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: const Color(0xFF2E7D32), width: 8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pot
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '底池 Pot: \$$potSize',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Community Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < 5; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: i < communityCards.length
                              ? CardWidget(card: communityCards[i])
                              : Container(
                                  width: 60,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white24),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    gameStatus,
                    style: const TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),

          // --- Player Area ---
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Player Hand
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (playerHand.isNotEmpty) ...[
                      Transform.translate(
                        offset: const Offset(10, 0),
                        child: Transform.rotate(
                          angle: -0.1,
                          child: CardWidget(card: playerHand[0], width: 80, height: 110),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-10, 0),
                        child: Transform.rotate(
                          angle: 0.1,
                          child: CardWidget(card: playerHand[1], width: 80, height: 110),
                        ),
                      ),
                    ] else 
                      const Text("等待发牌...", style: TextStyle(color: Colors.white38)),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Controls
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.black26,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (playerHand.isEmpty)
                        ElevatedButton.icon(
                          onPressed: startNewHand,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("发牌 (Deal)"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                        )
                      else ...[
                        _ActionButton(
                          label: "弃牌 Fold",
                          color: Colors.red[900]!,
                          onTap: () {
                            // Reset for demo
                            startNewHand();
                          },
                        ),
                        _ActionButton(
                          label: "过牌 Check",
                          color: Colors.blue[800]!,
                          onTap: () {
                            if (communityCards.isEmpty) dealFlop();
                            else if (communityCards.length == 3) dealTurn();
                            else if (communityCards.length == 4) dealRiver();
                            else startNewHand(); // End hand
                          },
                        ),
                        _ActionButton(
                          label: "加注 Raise",
                          color: Colors.green[700]!,
                          onTap: () => placeBet(50),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
