import 'package:flutter/material.dart';
import 'dart:math';

class FitnessCoachScreen extends StatefulWidget {
  const FitnessCoachScreen({Key? key}) : super(key: key);

  @override
  State<FitnessCoachScreen> createState() => _FitnessCoachScreenState();
}

class _FitnessCoachScreenState extends State<FitnessCoachScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  String? userGoal;

  // ✅ MENU DATA FROM YAML
  final Map<String, Map<String, String>> menuItems = {
    "special green tea": {
      "price": "₹40",
      "description": "Antioxidant rich green tea.",
      "category": "beverages"
    },
    "lemon tea": {
      "price": "₹30",
      "description": "Refreshing lemon infused tea.",
      "category": "beverages"
    },
    "black coffee": {
      "price": "₹35",
      "description": "Strong black coffee.",
      "category": "beverages"
    },
    "abc detox juice": {
      "price": "₹60",
      "description": "Apple + Beetroot + Carrot detox drink.",
      "category": "detox juices"
    },
    "amla juice": {
      "price": "₹50",
      "description": "Vitamin C rich immunity booster.",
      "category": "detox juices"
    },
    "paneer sprouts": {
      "price": "₹70",
      "description": "High protein paneer + sprouts mix.",
      "category": "sprouts & bowls"
    },
    "makhana bowl": {
      "price": "₹80",
      "description": "Protein rich roasted makhana bowl.",
      "category": "sprouts & bowls"
    },
    "chana protein sandwich": {
      "price": "₹90",
      "description": "High protein chana sandwich.",
      "category": "sandwiches"
    },
  };

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        "नमस्कार 👋\nमी तुमचा AI Fitness Coach आहे 💪\n\nतुमचे ध्येय सांगा:\n• Weight Loss\n• Muscle Gain\n• Maintain Fitness\n\nType 'menu' for Healthy Café Items 🍵");
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({"text": message, "isUser": true});
    });
    _scrollToBottom();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add({"text": message, "isUser": false});
    });
    _scrollToBottom();
  }

  void _handleMessage(String message) {
    String msg = message.toLowerCase();

    // ================= MENU INTENTS =================

    if (msg == "hi" || msg == "hello" || msg == "hey" || msg == "namaste") {
      _addBotMessage(
          "👋 Welcome!\nType 'menu' to explore healthy items 🍵\nOr ask fitness questions 💪");
    }

    else if (msg.contains("menu")) {
      _addBotMessage(
          "📋 Categories:\n• Beverages\n• Detox Juices\n• Sprouts & Bowls\n• Sandwiches\n\nType category name.");
    }

    else if (msg.contains("beverages")) {
      _addBotMessage(
          "🥤 Beverages:\n• Special Green Tea\n• Lemon Tea\n• Black Coffee");
    }

    else if (msg.contains("detox")) {
      _addBotMessage("🍹 Detox Juices:\n• ABC Detox Juice\n• Amla Juice");
    }

    else if (msg.contains("sprouts") || msg.contains("bowls")) {
      _addBotMessage("🥗 Sprouts & Bowls:\n• Paneer Sprouts\n• Makhana Bowl");
    }

    else if (msg.contains("sandwich")) {
      _addBotMessage("🥪 Sandwiches:\n• Chana Protein Sandwich");
    }

    else if (menuItems.keys.any((item) => msg.contains(item))) {
      String foundItem =
          menuItems.keys.firstWhere((item) => msg.contains(item));
      var item = menuItems[foundItem]!;

      _addBotMessage(
          "🍽 ${foundItem.toUpperCase()}\nPrice: ${item["price"]}\n${item["description"]}");
    }

    else if (msg.contains("price") || msg.contains("cost")) {
      for (var item in menuItems.keys) {
        if (msg.contains(item)) {
          _addBotMessage(
              "💰 ${item.toUpperCase()} costs ${menuItems[item]!["price"]}");
          return;
        }
      }
    }

    else if (msg.contains("green tea benefits")) {
      _addBotMessage(
          "🍵 Green Tea Benefits:\n• Boost metabolism\n• Fat burning\n• Rich in antioxidants");
    }

    else if (msg.contains("healthy")) {
      _addBotMessage(
          "🥗 Recommended:\n• Paneer Sprouts\n• Makhana Bowl\n• ABC Detox Juice");
    }

    else if (msg.contains("parcel") || msg.contains("takeaway")) {
      _addBotMessage("📦 Parcel charge: ₹10 packaging fee.");
    }

    else if (msg.contains("contact") || msg.contains("phone")) {
      _addBotMessage(
          "📞 Contact: 9876543210\n📍 Location: Near Gym Street\n📸 Instagram: @healthy_cafe");
    }

    else if (msg == "bye" || msg == "goodbye") {
      _addBotMessage("👋 Thank you! Stay healthy 💪");
    }

    // ================= FITNESS LOGIC (UNCHANGED) =================

    else if (msg.contains("weight loss") || msg.contains("वजन कमी")) {
      userGoal = "weight loss";
      _addBotMessage("🔥 तुमचे ध्येय Weight Loss आहे.\nचला सुरुवात करूया 💪");
    }

    else if (msg.contains("muscle gain") || msg.contains("वजन वाढ")) {
      userGoal = "muscle gain";
      _addBotMessage("💪 तुमचे ध्येय Muscle Gain आहे.");
    }

    else if (msg.contains("maintain")) {
      userGoal = "maintain";
      _addBotMessage("🏃‍♂️ Maintain Fitness मोड सुरू.");
    }

    else if (msg.contains("diet") || msg.contains("आहार")) {
      if (userGoal == "weight loss") {
        _addBotMessage(
            "🥗 Weight Loss Diet:\n• Oats\n• 2 Roti + Dal\n• Soup\nAvoid junk.");
      } else if (userGoal == "muscle gain") {
        _addBotMessage(
            "🍗 Muscle Gain Diet:\n• Eggs\n• Rice + Chicken\n• Milk");
      } else {
        _addBotMessage("पहिले तुमचे ध्येय सांगा 😊");
      }
    }

    else if (msg.contains("workout") || msg.contains("exercise")) {
      if (userGoal == "weight loss") {
        _addBotMessage(
            "🔥 Cardio\n• Skipping\n• Squats\n• Plank");
      } else if (userGoal == "muscle gain") {
        _addBotMessage(
            "💪 Pushups\n• Pullups\n• Dumbbell curls");
      } else {
        _addBotMessage("पहिले तुमचे ध्येय सांगा 😊");
      }
    }

    else if (msg.contains("bmi")) {
      _addBotMessage("Weight & Height टाका (Example: 70 5.6)");
    }

    else if (RegExp(r'^\d+\s\d+(\.\d+)?$').hasMatch(msg)) {
      List<String> parts = msg.split(" ");
      double weight = double.parse(parts[0]);
      double heightFeet = double.parse(parts[1]);

      double heightMeter = heightFeet * 0.3048;
      double bmi = weight / pow(heightMeter, 2);

      _addBotMessage(
          "📊 BMI: ${bmi.toStringAsFixed(1)}\nStatus: ${_bmiStatus(bmi)}");
    }

    else {
      _addBotMessage(
          "🤖 समजले नाही.\nTry:\n• Diet\n• Workout\n• BMI\n• Menu");
    }
  }

  String _bmiStatus(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    String message = _controller.text.trim();
    _addUserMessage(message);
    _controller.clear();
    _handleMessage(message);
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUser = message["isUser"];

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: [Color(0xFF00C853), Color(0xFF00BFA5)],
                )
              : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 6,
            )
          ],
        ),
        child: Text(
          message["text"],
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("AI Fitness Coach 💪"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask your coach...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
